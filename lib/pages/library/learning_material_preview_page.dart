import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/pages/library/gen_learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/pages/library/summary_page.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningMaterialPreviewPage extends StatefulWidget {
  final String url;
  final String type;
  final String name;

  const LearningMaterialPreviewPage({
    Key? key,
    required this.url,
    required this.type,
    required this.name,
  }) : super(key: key);

  @override
  State<LearningMaterialPreviewPage> createState() =>
      _LearningMaterialPreviewPageState();
}

class _LearningMaterialPreviewPageState
    extends State<LearningMaterialPreviewPage> {
  final AiTechGenService _aiTechGenService = AiTechGenService();

  void _summarizeMaterial() async {
    final url = widget.url;
    final type = widget.type;
    final mimeType = LearningMaterialType.getMimeType(type);
    final List<Part> fileParts = [];
    try {
      final data = await FirebaseStorage.instance.refFromURL(url).getData();
      if (data != null) fileParts.add(InlineDataPart(mimeType, data));
    } catch (_) {}
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(
          name: widget.name,
          fileParts: fileParts,
          aiTechGenService: _aiTechGenService,
        ),
      ),
    );
  }

  void _generateLearningBite() async {
    final url = widget.url;
    final type = widget.type;
    final mimeType = LearningMaterialType.getMimeType(type);
    final List<Part> fileParts = [];
    try {
      final data = await FirebaseStorage.instance.refFromURL(url).getData();
      if (data != null) fileParts.add(InlineDataPart(mimeType, data));
    } catch (_) {}
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenLearningBitePage(
          name: widget.name,
          fileParts: fileParts,
          aiTechGenService: _aiTechGenService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final type = widget.type;
    final name = widget.name;
    if (LearningMaterialType.pdfTypes.contains(type.toLowerCase())) {
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: true,
          actions: [
            IconButton(
              // Create AI summary action
              icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles),
              // Open new page to show AI summary
              onPressed: _summarizeMaterial,
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.schoolCircleCheck),
              onPressed: _generateLearningBite,
            ),
          ],
        ),
        body: PdfViewer.uri(
          Uri.parse(url),
          params: PdfViewerParams(
              backgroundColor: Theme.of(context).colorScheme.surface),
        ),
      );
    } else if (LearningMaterialType.imageTypes.contains(type.toLowerCase())) {
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles),
              onPressed: _summarizeMaterial,
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.schoolCircleCheck),
              onPressed: _generateLearningBite,
            ),
          ],
        ),
        body: Center(
          child: GestureDetector(
            child: Image.network(url),
            onTap: () {
              showImageViewer(
                context,
                NetworkImage(url),
                swipeDismissible: true,
                doubleTapZoomable: true,
                useSafeArea: true,
                backgroundColor: Colors.black,
                immersive: false,
              );
            },
          ),
        ),
      );
    } else if (LearningMaterialType.videoTypes.contains(type.toLowerCase())) {
      return _VideoPreview(
        url: url,
        name: name,
        summarizeMaterial: _summarizeMaterial,
        generateLearningBite: _generateLearningBite,
      );
    } else if (LearningMaterialType.textTypes.contains(type.toLowerCase())) {
      return _TextPreview(
        url: url,
        name: name,
        summarizeMaterial: _summarizeMaterial,
        generateLearningBite: _generateLearningBite,
      );
    } else {
      // Fallback: just show the URL
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Dateityp wird nicht unterstützt.\n$url'),
        ),
      );
    }
  }
}

class _TextPreview extends StatefulWidget {
  final String url;
  final String name;
  final Function() summarizeMaterial;
  final Function() generateLearningBite;
  const _TextPreview(
      {Key? key,
      required this.url,
      required this.name,
      required this.summarizeMaterial,
      required this.generateLearningBite})
      : super(key: key);

  @override
  State<_TextPreview> createState() => _TextPreviewState();
}

class _TextPreviewState extends State<_TextPreview> {
  String? _content;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  Future<void> _loadText() async {
    try {
      final data =
          await FirebaseStorage.instance.refFromURL(widget.url).getData();
      if (data != null) {
        setState(() {
          _content = utf8.decode(data, allowMalformed: true);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Datei konnte nicht geladen werden.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fehler beim Laden: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles),
            onPressed: widget.summarizeMaterial,
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.schoolCircleCheck),
            onPressed: widget.generateLearningBite,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _content!,
                    style: GoogleFonts.robotoMono(
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                  ),
                ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String url;
  final String name;
  final Function() summarizeMaterial;
  final Function() generateLearningBite;
  const _VideoPreview(
      {Key? key,
      required this.url,
      required this.name,
      required this.summarizeMaterial,
      required this.generateLearningBite})
      : super(key: key);

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showPlayPause = false;
  late VoidCallback _hideOverlayCallback;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setVolume(0);
        _controller.setLooping(true);
        _controller.play();
      });
    _hideOverlayCallback = () {
      if (mounted) {
        setState(() {
          _showPlayPause = false;
        });
      }
    };
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showPlayPause = true;
    });
    Future.delayed(const Duration(seconds: 2), _hideOverlayCallback);
  }

  Widget _buildPlayPauseButton(BuildContext context) {
    const textColor = Colors.white;
    final bgColor = Colors.black.withAlpha(80);
    final outlineColor = Colors.white.withAlpha(40);

    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: _togglePlayPause,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: outlineColor),
          ),
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: textColor,
            size: 28,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        actions: [
          IconButton(
            // Create AI summary action
            icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles),
            // Open new page to show AI summary
            onPressed: widget.summarizeMaterial,
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.schoolCircleCheck),
            onPressed: widget.generateLearningBite,
          ),
        ],
      ),
      body: Center(
        child: _initialized
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlayPause,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: IgnorePointer(child: VideoPlayer(_controller)),
                    ),
                    IgnorePointer(
                      ignoring: !_showPlayPause,
                      child: AnimatedOpacity(
                        opacity: _showPlayPause ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: AnimatedScale(
                          scale: _showPlayPause ? 1.4 : 1.2,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          child: _buildPlayPauseButton(context),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
