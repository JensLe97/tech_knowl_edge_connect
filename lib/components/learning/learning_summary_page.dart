import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tech_knowl_edge_connect/components/buttons/bottom_action_bar.dart';

class LearningSummaryPage extends StatelessWidget {
  final int points;
  final int maxPoints;
  final VoidCallback onComplete;

  const LearningSummaryPage({
    super.key,
    required this.points,
    required this.maxPoints,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 80, bottom: 120),
            child: Center(
              child: Builder(builder: (context) {
                final double ratio = maxPoints > 0 ? points / maxPoints : 1.0;
                final String headerText;
                final IconData headerIcon;
                final Color iconColor;

                // Emoji pools for each result state
                final completedEmojis = ['✅', '🏁', '✔️', '🟢', '🎓'];
                final excellentEmojis = ['🎉', '🏆', '🥇', '🎖️', '🌟'];
                final greatEmojis = ['👍', '🙌', '✨', '💯', '🥈'];
                final practiceEmojis = ['💪', '🔁', '📈', '🛠️', '🤓'];

                final rand = Random();
                final String emoji;

                if (maxPoints == 0) {
                  headerText = 'Absolviert!';
                  headerIcon = Icons.task_alt;
                  iconColor = Colors.green;
                  emoji = completedEmojis[rand.nextInt(completedEmojis.length)];
                } else if (ratio >= 0.9) {
                  headerText = 'Super gemacht!';
                  headerIcon = Icons.rocket_launch;
                  iconColor = Colors.amber.shade700;
                  emoji = excellentEmojis[rand.nextInt(excellentEmojis.length)];
                } else if (ratio >= 0.5) {
                  headerText = 'Gut gemacht!';
                  headerIcon = Icons.thumb_up;
                  iconColor = Theme.of(context).colorScheme.primary;
                  emoji = greatEmojis[rand.nextInt(greatEmojis.length)];
                } else {
                  headerText = 'Übe weiter!';
                  headerIcon = Icons.fitness_center;
                  iconColor = Colors.orange;
                  emoji = practiceEmojis[rand.nextInt(practiceEmojis.length)];
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withAlpha(40),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(headerIcon, size: 84, color: iconColor),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '$emoji  $headerText',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        maxPoints > 0
                            ? 'Du hast $points von $maxPoints Punkten erhalten.'
                            : 'Diese Lektion wurde als abgeschlossen markiert.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomActionBar(
            text: "Lektion abschließen",
            onPressed: onComplete,
          ),
        ),
      ],
    );
  }
}

