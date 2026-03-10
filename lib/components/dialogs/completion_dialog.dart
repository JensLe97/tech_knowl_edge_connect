import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Confetti completion dialog shown when a user finishes all learning bites
/// of a concept or a journey.
///
/// Set [isJourney] to `true` for journey completions (uses "Lernreise" wording),
/// or `false` (default) for concept/topic completions.
class CompletionDialog extends StatefulWidget {
  final String conceptName;
  final bool isJourney;

  const CompletionDialog({
    super.key,
    required this.conceptName,
    this.isJourney = false,
  });

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 300),
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  widget.isJourney
                      ? 'Du hast alle Lektionen der Lernreise "${widget.conceptName}" abgeschlossen!'
                      : 'Du hast alle Lektionen zum Thema "${widget.conceptName}" abgeschlossen!',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
