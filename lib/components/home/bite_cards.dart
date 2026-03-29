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
    final title = authoritativeTitle ?? bite.biteId;
    final completed = (bite.progress >= 100) || bite.status == 'completed';

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                      completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.primary),
                )
              ]),
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
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
