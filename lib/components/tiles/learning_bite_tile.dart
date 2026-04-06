import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:tech_knowl_edge_connect/models/learning/learning_bite.dart";

class LearningBiteTile extends StatelessWidget {
  final LearningBite learningBite;
  final void Function()? onTap;
  final void Function()? onEdit;
  final bool completed;

  const LearningBiteTile({
    super.key,
    required this.learningBite,
    required this.onTap,
    this.onEdit,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 160,
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withAlpha(76),
            )),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      learningBite.iconData,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Spacer(),
                    Text(
                      learningBite.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: FaIcon(
                    completed || learningBite.completed
                        ? FontAwesomeIcons.circleCheck
                        : FontAwesomeIcons.circle,
                    size: 24,
                    color: completed || learningBite.completed
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                if (onEdit != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Theme.of(context).colorScheme.primary,
                      tooltip: 'Learning Bite bearbeiten',
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
