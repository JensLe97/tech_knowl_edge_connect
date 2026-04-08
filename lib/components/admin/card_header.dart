import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  final Widget? trailing;

  const CardHeader({
    super.key,
    required this.title,
    this.onAdd,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // text-xl
            color: cs.onSurface,
          ),
        ),
        if (trailing != null)
          trailing!
        else if (onAdd != null)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onAdd,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    cs.primaryContainer.withAlpha(76), // 30% primaryContainer
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withAlpha(25), // 10% primary
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: cs.primary,
                  size: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
