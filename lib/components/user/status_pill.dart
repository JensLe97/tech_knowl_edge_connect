import 'package:flutter/material.dart';
import 'user_constants.dart';

class StatusPill extends StatelessWidget {
  final String status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (status) {
      case UserConstants.statusApproved:
        bgColor = Colors.green.withAlpha(38); // 15% opacity
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
        borderColor = Colors.green.withAlpha(76); // 30% opacity
        break;
      case UserConstants.statusRejected:
        bgColor = cs.errorContainer;
        textColor = cs.onErrorContainer;
        borderColor = cs.error.withAlpha(76);
        break;
      case UserConstants.statusPending:
        bgColor = Colors.orange.withAlpha(38);
        textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        borderColor = Colors.orange.withAlpha(76);
        break;
      default: // statusPrivate or draft
        bgColor = cs.surfaceContainerHighest;
        textColor = cs.onSurfaceVariant;
        borderColor = cs.outlineVariant.withAlpha(128);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        UserConstants.statusLabels[status] ?? status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
