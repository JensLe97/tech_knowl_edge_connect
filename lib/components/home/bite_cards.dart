import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

/// A small card showing a single learning bite's title and completion status.
class UnitBiteCard extends StatelessWidget {
  final UnitBiteProgress bite;
  final String? authoritativeTitle;
  final VoidCallback onTap;

  const UnitBiteCard({
    super.key,
    required this.bite,
    required this.onTap,
    this.authoritativeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = authoritativeTitle ?? bite.biteId;
    final completed = (bite.progress >= 100) || bite.status == 'completed';

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(51),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A card for a learning bite that has no progress yet (shown as 0%).
class NewBiteCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const NewBiteCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(51),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: colorScheme.outline,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
