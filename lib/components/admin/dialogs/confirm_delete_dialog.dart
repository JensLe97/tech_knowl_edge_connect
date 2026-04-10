import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final Future<void> Function() onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.errorContainer.withAlpha(76),
          shape: BoxShape.circle,
          border: Border.all(
            color: cs.error.withAlpha(25),
          ),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 32,
          color: cs.error,
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Row(
          children: [
            DialogButton(
              onTap: () => Navigator.pop(context),
              text: 'Abbrechen',
            ),
            DialogButton(
              onTap: () async {
                await onConfirm();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              text: 'Löschen',
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }
}
