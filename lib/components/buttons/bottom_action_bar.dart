import 'dart:ui';
import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Widget? child;

  const BottomActionBar({
    super.key,
    this.text,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(230),
            border: Border(
              top: BorderSide(
                color:
                    Theme.of(context).colorScheme.outlineVariant.withAlpha(100),
                width: 1,
              ),
            ),
          ),
          child: child ??
              FilledButton(
                onPressed: onPressed,
                child: Text(
                  text ?? "Weiter",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
