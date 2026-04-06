import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final bool isDestructive;

  const DialogButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? cs.error : cs.secondaryContainer,
            foregroundColor:
                isDestructive ? cs.onError : cs.onSecondaryContainer,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
