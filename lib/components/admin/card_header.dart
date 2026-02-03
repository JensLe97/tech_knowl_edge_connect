import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;

  const CardHeader({
    super.key,
    required this.title,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Neu',
          onPressed: onAdd,
        ),
      ],
    );
  }
}
