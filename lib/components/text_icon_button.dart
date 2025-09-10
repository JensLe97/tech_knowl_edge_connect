import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? borderColor;

  const TextIconButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.inversePrimary,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 5),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
