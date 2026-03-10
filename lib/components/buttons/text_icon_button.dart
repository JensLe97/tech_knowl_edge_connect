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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.all(10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
            color: borderColor ?? Theme.of(context).colorScheme.inversePrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 5),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
