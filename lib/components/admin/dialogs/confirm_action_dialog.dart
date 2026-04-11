import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color actionColor;
  final Color actionContainerColor;
  final String actionText;
  final bool isDestructive;
  final void Function() onConfirm;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.actionColor,
    required this.actionContainerColor,
    required this.actionText,
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: actionContainerColor.withAlpha(76),
          shape: BoxShape.circle,
          border: Border.all(
            color: actionColor.withAlpha(25),
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: actionColor,
        ),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Row(
          children: [
            DialogButton(
              onTap: () => Navigator.pop(context),
              text: 'Abbrechen',
            ),
            DialogButton(
              onTap: () {
                onConfirm();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              text: actionText,
              isDestructive: isDestructive,
            ),
          ],
        ),
      ],
    );
  }
}
