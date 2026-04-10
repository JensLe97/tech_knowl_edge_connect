import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Confetti completion dialog shown when a user finishes all learning bites
/// of a concept or a journey.
///
/// Set [isJourney] to `true` for journey completions (uses "Lernreise"
/// wording), or `false` (default) for concept/topic completions.
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
    final cs = Theme.of(context).colorScheme;
    final titleText = widget.isJourney
        ? 'Du hast alle Lektionen der Lernreise "${widget.conceptName}" abgeschlossen!'
        : 'Du hast alle Lektionen zum Thema "${widget.conceptName}" abgeschlossen!';
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: math.pi / 2,
              emissionFrequency: 0.06,
              numberOfParticles: 28,
              gravity: 0.36,
              colors: [
                cs.primary,
                cs.secondary,
                cs.tertiary,
                cs.primary.withValues(alpha: 0.9),
              ],
              createParticlePath: (Size size) {
                final path = Path();
                final rrect = RRect.fromRectAndRadius(
                    Rect.fromLTWH(0, 0, size.width, size.height),
                    Radius.circular(size.height * 0.4));
                path.addRRect(rrect);
                return path;
              },
              particleDrag: 0.08,
              minimumSize: const Size(12, 6),
              maximumSize: const Size(26, 12),
              strokeWidth: 0,
              strokeColor: cs.surface,
            ),
          ),
        ),
        Center(
          child: AlertDialog(
            scrollable: false,
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 36,
                color: cs.onPrimaryContainer,
              ),
            ),
            title: Text(
              titleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: cs.surface,
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            actions: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 240, maxWidth: 360),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Zurück zur Übersicht'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
