import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';

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
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
              child: Column(
            children: [
              const SizedBox(height: 200),
              Builder(builder: (context) {
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
                    Icon(headerIcon, size: 72, color: iconColor),
                    const SizedBox(height: 12),
                    Text(
                      '$emoji  $headerText',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      maxPoints > 0
                          ? 'Du hast $points von $maxPoints Punkten erhalten.'
                          : 'Diese Lektion wurde als abgeschlossen markiert.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                          ),
                    ),
                  ],
                );
              }),
            ],
          )),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Wrap(direction: Axis.horizontal, children: [
            LessonButton(
              onTap: onComplete,
              text: "Lektion abschließen",
            )
          ]),
        ),
      ],
    );
  }
}
