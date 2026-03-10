import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

/// A small card showing a single learning bite's title and completion status.
class UnitBiteCard extends StatelessWidget {
  final UnitBiteProgress bite;
  final VoidCallback onTap;

  const UnitBiteCard({super.key, required this.bite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = bite.biteTitle ?? bite.biteId;
    final completed = (bite.progress >= 100) || bite.status == 'completed';
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                  Row(children: [
                    const Expanded(child: SizedBox()),
                    Icon(
                        completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Theme.of(context).colorScheme.primary),
                  ])
                ]),
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
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                  Row(children: [
                    const Expanded(child: SizedBox()),
                    Icon(
                      Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ])
                ]),
          ),
        ),
      ),
    );
  }
}
