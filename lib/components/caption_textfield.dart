import 'package:flutter/material.dart';

class CaptionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CaptionTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          hintText: hintText,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}
