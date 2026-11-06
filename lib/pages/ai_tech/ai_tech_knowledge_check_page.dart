import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:tech_knowl_edge_connect/components/buttons/bottom_action_bar.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:record/record.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_knowledge_check_prompt.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/learning_journey_agent.dart';

class AiTechKnowledgeCheckPage extends StatefulWidget {
  final String title;
  final List<Part> fileParts;
  final String? additionalText;
  final AiTechGenService aiTechGenService;
  final String? sessionId;
  final String? journeyId;
  final String? journeySessionId;
  final List<Map<String, dynamic>> sourceMaterialReferences;

  const AiTechKnowledgeCheckPage({
    super.key,
    required this.title,
    this.fileParts = const [],
    this.additionalText,
    required this.aiTechGenService,
    this.sessionId,
    this.journeyId,
    this.journeySessionId,
    this.sourceMaterialReferences = const [],
  });

  @override
  State<AiTechKnowledgeCheckPage> createState() =>
      _AiTechKnowledgeCheckPageState();
}

class _AiTechKnowledgeCheckPageState extends State<AiTechKnowledgeCheckPage> {
  static const _maxRecordingDuration = Duration(seconds: 45);
  static const _speechSampleRate = 24000;

  late final Future<List<AiTechKnowledgeCheckPrompt>> _sessionFuture;
  final AudioRecorder _recorder = AudioRecorder();
  final SoLoud _audioOutput = SoLoud.instance;
  final List<String> _responses = [];
  final List<String> _answerFeedback = [];
  final List<String> _nextActions = [];
  final List<String> _sessionTranscript = [];
  final List<Part> _journeySourceParts = [];
  final Map<String, Uint8List> _spokenQuestionAudio = {};

  BytesBuilder _audioBuffer = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _audioSubscription;
  StreamIterator<Uint8List>? _speechIterator;
  SoundHandle? _activeSpeechHandle;
  Timer? _recordingLimitTimer;
  int _currentIndex = 0;
  int _completedQuestionCount = 0;
  int _followUpCount = 0;
  bool _isComplete = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _isSpeaking = false;
  bool _isFinishing = false;
  bool _speechStopRequested = false;
  bool _askedFollowUp = false;
  bool _awaitingContinuation = false;
  bool _hasCurrentAnswer = false;
  String? _activeFollowUp;
  String? _pendingFollowUpQuestion;
  String _lastSpokenPrompt = '';
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    final journeyId = widget.journeyId;
    if (journeyId != null) {
      _sessionFuture = _generateJourneyPrompts(journeyId);
    } else {
      _sessionFuture = widget.aiTechGenService
          .generateAiTechKnowledgeCheckPrompts(
            subject: widget.title,
            additionalText: widget.additionalText ?? '',
            fileParts: widget.fileParts,
            useGoogleSearchTool: true,
            maxQuestions: 3,
          );
    }
  }

  Future<List<AiTechKnowledgeCheckPrompt>> _generateJourneyPrompts(
    String journeyId,
  ) async {
    final journeyData = await AiTechService().getJourneyById(journeyId);
    final storedReferences =
        (journeyData?['sourceMaterials'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((source) => Map<String, dynamic>.from(source));
    final references = [
      ...storedReferences,
      ...widget.sourceMaterialReferences,
    ];
    _journeySourceParts.addAll(await _loadSourceMaterialParts(references));
    return LearningJourneyAgent(
      AiTechService(),
    ).generateAiTechKnowledgeCheckForJourney(
      journeyId: journeyId,
      subject: widget.title,
      sourceMaterials: [...widget.fileParts, ..._journeySourceParts],
      useGoogleSearchTool: true,
      maxQuestions: 3,
    );
  }

  Future<List<Part>> _loadSourceMaterialParts(
    List<Map<String, dynamic>> references,
  ) async {
    const maxTotalBytes = 20 * 1024 * 1024;
    final sourceParts = <Part>[];
    final errors = <String>[];
    final seenUrls = <String>{};
    var totalBytes = 0;

    for (final source in references) {
      final url = source['url'] as String?;
      if (url == null || url.isEmpty || !seenUrls.add(url)) continue;
      final name = (source['name'] as String?) ?? 'Lernmaterial';
      final extension = (source['ext'] as String?)?.toLowerCase() ?? '';
      final mimeType = LearningMaterialType.getMimeType(extension);
      final remainingBytes = maxTotalBytes - totalBytes;
      if (mimeType == 'application/octet-stream' || remainingBytes <= 0) {
        errors.add(name);
        continue;
      }

      try {
        final bytes = await FirebaseStorage.instance
            .refFromURL(url)
            .getData(remainingBytes);
        if (bytes == null || bytes.isEmpty) {
          throw StateError('Datei ist leer oder nicht verfügbar.');
        }
        sourceParts.add(InlineDataPart(mimeType, bytes));
        totalBytes += bytes.length;
      } catch (_) {
        errors.add(name);
      }
    }

    if (errors.isNotEmpty && mounted) {
      setState(() {
        _statusMessage =
            '${errors.length} Quelldatei(en) konnten nicht geladen werden. '
            'Der AI Tech Wissenscheck nutzt weiterhin die Lerneinheiten der Reise.';
      });
    }
    return sourceParts;
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    final speechIterator = _speechIterator;
    if (speechIterator != null) {
      unawaited(_stopSpeechPlayback(speechIterator));
    }
    _recordingLimitTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String _questionText(List<AiTechKnowledgeCheckPrompt> prompts) =>
      _activeFollowUp ?? prompts[_currentIndex].prompt;

  void _continueAfterAnswer(List<AiTechKnowledgeCheckPrompt> prompts) {
    if (!_awaitingContinuation ||
        _isAnalyzing ||
        _isRecording ||
        _isFinishing) {
      return;
    }

    final followUpQuestion = _pendingFollowUpQuestion;
    if (followUpQuestion != null) {
      setState(() {
        _completedQuestionCount++;
        _followUpCount++;
        _activeFollowUp = followUpQuestion;
        _pendingFollowUpQuestion = null;
        _askedFollowUp = true;
        _awaitingContinuation = false;
        _hasCurrentAnswer = false;
        _statusMessage = null;
      });
      return;
    }

    if (_currentIndex < prompts.length - 1) {
      setState(() {
        _completedQuestionCount++;
        _currentIndex++;
        _activeFollowUp = null;
        _askedFollowUp = false;
        _awaitingContinuation = false;
        _hasCurrentAnswer = false;
        _statusMessage = null;
      });
      return;
    }

    unawaited(_finishSession());
  }

  Future<void> _speakText(String text) async {
    if ((kDebugMode && !kUseRealAiInDebug) ||
        text.trim().isEmpty ||
        _isSpeaking ||
        _isRecording ||
        _isAnalyzing) {
      return;
    }

    setState(() {
      _isSpeaking = true;
      _speechStopRequested = false;
    });
    try {
      final cachedAudio = _spokenQuestionAudio[text];
      final generatedAudio = BytesBuilder(copy: false);
      final audioStream = cachedAudio == null
          ? widget.aiTechGenService.generateAiTechKnowledgeCheckSpeech(text)
          : Stream<Uint8List>.value(cachedAudio);
      await _playSpeechStream(
        audioStream,
        onAudioChunk: cachedAudio == null ? generatedAudio.add : (_) {},
      );
      if (cachedAudio == null && !_speechStopRequested) {
        _spokenQuestionAudio[text] = generatedAudio.takeBytes();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Die Frage konnte nicht vorgelesen werden: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _playSpeechStream(
    Stream<Uint8List> audioStream, {
    required void Function(Uint8List) onAudioChunk,
  }) async {
    AudioSource? source;
    SoundHandle? handle;
    Future<void>? playbackFinished;
    final iterator = StreamIterator<Uint8List>(audioStream);
    _speechIterator = iterator;

    try {
      final firstChunkFuture = _nextSpeechChunk(iterator);
      final audioOutputReady = _initializeAudioOutput();
      await Future.wait<void>([
        firstChunkFuture.then<void>((_) {}),
        audioOutputReady,
      ]);
      if (!mounted) return;

      final firstChunk = await firstChunkFuture;
      if (firstChunk == null) {
        throw StateError('The speech model returned no audio.');
      }

      source = _audioOutput.setBufferStream(
        bufferingType: BufferingType.released,
        bufferingTimeNeeds: 0,
        sampleRate: _speechSampleRate,
        channels: Channels.mono,
        format: BufferType.s16le,
      );
      playbackFinished = source.allInstancesFinished.first;
      handle = _audioOutput.play(source);
      _activeSpeechHandle = handle;
      _audioOutput.addAudioDataStream(source, firstChunk);
      onAudioChunk(firstChunk);

      while (await iterator.moveNext()) {
        final chunk = iterator.current;
        if (chunk.isEmpty) continue;
        _audioOutput.addAudioDataStream(source, chunk);
        onAudioChunk(chunk);
      }

      _audioOutput.setDataIsEnded(source);
      await playbackFinished.timeout(
        const Duration(minutes: 2),
        onTimeout: () => throw TimeoutException(
          'Die Audiowiedergabe wurde nicht rechtzeitig abgeschlossen.',
        ),
      );
    } finally {
      if (identical(_speechIterator, iterator)) _speechIterator = null;
      await iterator.cancel();
      if (source != null) {
        if (handle != null && _audioOutput.getIsValidVoiceHandle(handle)) {
          await _audioOutput.stop(handle);
        }
        if (_audioOutput.isInitialized) {
          await _audioOutput.disposeSource(source);
        }
      }
      if (identical(_activeSpeechHandle, handle)) {
        _activeSpeechHandle = null;
      }
    }
  }

  Future<void> _initializeAudioOutput() async {
    if (_audioOutput.isInitialized) return;
    await _audioOutput.init(
      sampleRate: _speechSampleRate,
      channels: Channels.mono,
    );
  }

  Future<Uint8List?> _nextSpeechChunk(
    StreamIterator<Uint8List> iterator,
  ) async {
    while (await iterator.moveNext()) {
      final chunk = iterator.current;
      if (chunk.isNotEmpty) return chunk;
    }
    return null;
  }

  Future<void> _stopSpeechPlayback(StreamIterator<Uint8List> iterator) async {
    final handle = _activeSpeechHandle;
    _activeSpeechHandle = null;
    if (handle != null &&
        _audioOutput.isInitialized &&
        _audioOutput.getIsValidVoiceHandle(handle)) {
      await _audioOutput.stop(handle);
    }
    await iterator.cancel();
  }

  Future<void> _stopSpeaking() async {
    final iterator = _speechIterator;
    if (iterator == null) return;

    _speechStopRequested = true;
    await _stopSpeechPlayback(iterator);
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  Uint8List _pcmToWav(Uint8List pcm, {int sampleRate = 24000}) {
    const channels = 1;
    const bitsPerSample = 16;
    final header = ByteData(44);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(
      28,
      sampleRate * channels * bitsPerSample ~/ 8,
      Endian.little,
    );
    header.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);

    return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
  }

  Future<void> _toggleRecording(
    List<AiTechKnowledgeCheckPrompt> prompts,
  ) async {
    if (_isAnalyzing || _isSpeaking) return;
    if (_isRecording) {
      await _stopAndAnalyzeAnswer(prompts);
      return;
    }

    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw StateError('Mikrofonzugriff wurde nicht erteilt.');
      }
      _audioBuffer = BytesBuilder(copy: false);
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );
      _audioSubscription = stream.listen(
        _audioBuffer.add,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _statusMessage = 'Audioaufnahme fehlgeschlagen: $error';
            _isRecording = false;
          });
        },
      );
      _recordingLimitTimer = Timer(_maxRecordingDuration, () {
        if (_isRecording) unawaited(_stopAndAnalyzeAnswer(prompts));
      });
      if (mounted) {
        setState(() {
          _isRecording = true;
          _statusMessage =
              'Ich höre zu. Tippe auf „Antwort auswerten“, wenn du fertig bist.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _statusMessage = 'Mikrofon konnte nicht gestartet werden: $error';
        });
      }
    }
  }

  Future<void> _stopAndAnalyzeAnswer(
    List<AiTechKnowledgeCheckPrompt> prompts,
  ) async {
    _recordingLimitTimer?.cancel();
    _recordingLimitTimer = null;
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _statusMessage = 'Die Aufnahme wird abgeschlossen...';
    });
    try {
      try {
        await _recorder.stop().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
            'Die Audioaufnahme konnte nicht beendet werden.',
          ),
        );
      } finally {
        final subscription = _audioSubscription;
        _audioSubscription = null;
        await subscription?.cancel();
      }
      final audio = _audioBuffer.takeBytes();
      _validateRecordedAudio(audio);

      if (mounted) {
        setState(() {
          _statusMessage = 'Die Antwort wird transkribiert und ausgewertet...';
        });
      }
      final feedback = await widget.aiTechGenService
          .analyzeAiTechKnowledgeCheckAudio(
            question: _questionText(prompts),
            subject: widget.title,
            audioData: _pcmToWav(audio, sampleRate: 16000),
            mimeType: 'audio/wav',
            isFollowUp: _askedFollowUp,
            additionalText: widget.additionalText,
            fileParts: [...widget.fileParts, ..._journeySourceParts],
          );
      if (feedback.transcript.trim().isEmpty) {
        throw StateError(
          'Die gesprochene Antwort konnte nicht erkannt werden.',
        );
      }

      final feedbackText = feedback.isCorrect
          ? '${feedback.feedback}\n\nKurzantwort: ${feedback.correctAnswer}'
          : _askedFollowUp
          ? '${feedback.feedback}\n\nKorrekte Antwort: ${feedback.correctAnswer}'
          : feedback.feedback;
      _responses.add(feedback.transcript);
      _answerFeedback.add(feedbackText);
      _nextActions.add(feedback.nextAction);
      _sessionTranscript.add(
        'Frage: ${_questionText(prompts)}\n'
        'Antwort: ${feedback.transcript}\n'
        'Rückmeldung: $feedbackText',
      );
      final hasFollowUp =
          feedback.needsFollowUp &&
          feedback.followUpQuestion.trim().isNotEmpty &&
          !_askedFollowUp;

      if (mounted) {
        setState(() {
          _pendingFollowUpQuestion = hasFollowUp
              ? feedback.followUpQuestion
              : null;
          _awaitingContinuation = true;
          _hasCurrentAnswer = true;
          _statusMessage = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Antwort konnte nicht ausgewertet werden: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _validateRecordedAudio(Uint8List audio) {
    const sampleRate = 16000;
    if (audio.lengthInBytes < sampleRate) {
      throw StateError(
        'Die Aufnahme ist zu kurz. Bitte sprich mindestens eine halbe '
        'Sekunde und versuche es erneut.',
      );
    }
    if (audio.lengthInBytes.isOdd) {
      throw StateError('Die Audioaufnahme ist unvollständig. Bitte erneut.');
    }

    final data = ByteData.sublistView(audio);
    var sumSquares = 0.0;
    for (var offset = 0; offset < audio.lengthInBytes; offset += 2) {
      final sample = data.getInt16(offset, Endian.little) / 32768.0;
      sumSquares += sample * sample;
    }
    final meanSquare = sumSquares / (audio.lengthInBytes ~/ 2);
    if (meanSquare < 0.000001) {
      throw StateError(
        'Es wurde keine verständliche Sprache aufgenommen. Bitte prüfe '
        'dein Mikrofon und versuche es erneut.',
      );
    }
  }

  Future<void> _finishSession() async {
    if (_isFinishing) return;
    _isFinishing = true;
    if (mounted) setState(() => _isAnalyzing = true);
    final summary = _buildSummary();
    try {
      final sessionId = widget.journeySessionId ?? widget.sessionId;
      if (sessionId != null && sessionId.isNotEmpty) {
        await AiTechService().addAiTechKnowledgeCheckResultToSession(
          sessionId: sessionId,
          journeyId: widget.journeyId,
          summary: summary,
        );
      }
      if (!mounted) return;
      setState(() {
        _isComplete = true;
        _statusMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Das Ergebnis konnte nicht gespeichert werden: $error';
      });
    } finally {
      _isFinishing = false;
      if (mounted && !_isComplete) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  String _buildSummary() {
    final assessment = _answerFeedback.isNotEmpty
        ? _answerFeedback.last
        : 'Bitte wiederhole die wichtigsten Punkte des Materials.';
    final nextAction = _nextActions.isNotEmpty
        ? _nextActions.last
        : 'Wiederhole die Kernaussage und vertiefe den Themenbereich mit einem passenden Lernbite.';
    return '$assessment\n\n'
        'Empfohlene nächste Maßnahme: $nextAction\n\n'
        '${_sessionTranscript.join('\n\n')}';
  }

  bool _isErrorStatusMessage(String message) {
    return message.contains('fehl') || message.contains('nicht');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AiTechKnowledgeCheckPrompt>>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title), centerTitle: true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title), centerTitle: true),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Der AI Tech Wissenscheck konnte nicht erstellt werden. '
                  'Bitte versuche es erneut.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final prompts = snapshot.data!;
        final progressValue = _isComplete
            ? 1.0
            : _completedQuestionCount / (prompts.length + _followUpCount);
        final question = _questionText(prompts);
        if (!_isComplete &&
            _lastSpokenPrompt != question &&
            !_isSpeaking &&
            !_isRecording &&
            !_isAnalyzing) {
          _lastSpokenPrompt = question;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isComplete) _speakText(question);
          });
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 0,
            centerTitle: true,
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: const [SizedBox(width: 48)],
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(begin: 0, end: progressValue),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primary,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom: 120,
                  ),
                  child: _isComplete
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'AI TECH WISSENSCHECK',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLowest,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant.withAlpha(50),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'AI Tech Wissenscheck abgeschlossen',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withAlpha(50),
                                ),
                              ),
                              child: MarkdownBody(
                                data: _buildSummary(),
                                extensionSet: getMarkdownExtensionSet(),
                                builders: getMarkdownColorBuilders(),
                                styleSheet: createMarkdownStyleSheet(context)
                                    .copyWith(
                                      p: Theme.of(context).textTheme.bodyLarge
                                          ?.copyWith(height: 1.5),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'AI-generierte Rückmeldung ist beratend und '
                              'ersetzt keine Einschätzung durch Menschen.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'AI TECH WISSENSCHECK',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Höre zu und antworte in deinen eigenen Worten.',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withAlpha(50),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MarkdownBody(
                                    data: question,
                                    extensionSet: getMarkdownExtensionSet(),
                                    builders: getMarkdownColorBuilders(),
                                    styleSheet:
                                        createMarkdownStyleSheet(
                                          context,
                                        ).copyWith(
                                          p: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                height: 1.6,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (_isSpeaking || _isAnalyzing)
                                        _AiTechKnowledgeCheckActivityIndicator(
                                          analyzing: _isAnalyzing,
                                        ),
                                      if (_isSpeaking || _isAnalyzing)
                                        const SizedBox(width: 8),
                                      IconButton.filledTonal(
                                        onPressed: _isRecording || _isAnalyzing
                                            ? null
                                            : _isSpeaking
                                            ? _stopSpeaking
                                            : () => _speakText(question),
                                        icon: Icon(
                                          _isSpeaking
                                              ? Icons.stop
                                              : Icons.volume_up,
                                        ),
                                        tooltip: _isSpeaking
                                            ? 'Vorlesen stoppen'
                                            : 'Frage erneut vorlesen',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_statusMessage != null && !_isAnalyzing) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _isErrorStatusMessage(_statusMessage!)
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.errorContainer
                                      : Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusMessage!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color:
                                            _isErrorStatusMessage(
                                              _statusMessage!,
                                            )
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onErrorContainer
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ],
                            if (_hasCurrentAnswer && _responses.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                'DEINE ANTWORT',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant.withAlpha(50),
                                  ),
                                ),
                                child: MarkdownBody(
                                  data: _responses.last,
                                  extensionSet: getMarkdownExtensionSet(),
                                  builders: getMarkdownColorBuilders(),
                                  styleSheet: createMarkdownStyleSheet(context)
                                      .copyWith(
                                        p: Theme.of(context).textTheme.bodyLarge
                                            ?.copyWith(height: 1.5),
                                      ),
                                ),
                              ),
                            ],
                            if (_hasCurrentAnswer &&
                                _answerFeedback.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withAlpha(80),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RÜCKMELDUNG',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    MarkdownBody(
                                      data: _answerFeedback.last,
                                      extensionSet: getMarkdownExtensionSet(),
                                      builders: getMarkdownColorBuilders(),
                                      styleSheet:
                                          createMarkdownStyleSheet(
                                            context,
                                          ).copyWith(
                                            p: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(height: 1.5),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              'Die Audioaufnahme wird zur Auswertung an '
                              'Firebase AI gesendet und nicht als Audiodatei '
                              'in der App gespeichert.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI-generierte Rückmeldung ist beratend und '
                              'ersetzt keine Einschätzung durch Menschen.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomActionBar(
                  child: _isComplete
                      ? FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Zurück zur Übersicht'),
                        )
                      : _awaitingContinuation
                      ? FilledButton(
                          onPressed: _isAnalyzing || _isSpeaking || _isRecording
                              ? null
                              : () => _continueAfterAnswer(prompts),
                          child: Text(
                            _pendingFollowUpQuestion != null
                                ? 'Rückfrage beantworten'
                                : _currentIndex < prompts.length - 1
                                ? 'Nächste Frage'
                                : 'Ergebnis anzeigen',
                          ),
                        )
                      : FilledButton(
                          onPressed: _isAnalyzing || _isSpeaking
                              ? null
                              : () => _toggleRecording(prompts),
                          child: Text(
                            _isAnalyzing
                                ? 'Antwort wird ausgewertet…'
                                : _isRecording
                                ? 'Antwort auswerten'
                                : _isSpeaking
                                ? 'Frage wird vorgelesen…'
                                : 'Antwort sprechen',
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AiTechKnowledgeCheckActivityIndicator extends StatefulWidget {
  final bool analyzing;

  const _AiTechKnowledgeCheckActivityIndicator({required this.analyzing});

  @override
  State<_AiTechKnowledgeCheckActivityIndicator> createState() =>
      _AiTechKnowledgeCheckActivityIndicatorState();
}

class _AiTechKnowledgeCheckActivityIndicatorState
    extends State<_AiTechKnowledgeCheckActivityIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.analyzing) {
      return Tooltip(
        message: 'Antwort wird transkribiert und ausgewertet',
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    return Tooltip(
      message: 'AI Tech liest die Frage vor',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 28,
            height: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                final phase = (_controller.value + index / 3) % 1;
                final height = 8 + math.sin(phase * math.pi * 2).abs() * 14;
                return Container(
                  width: 5,
                  height: height,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
