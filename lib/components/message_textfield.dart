import 'package:flutter/material.dart';

class MessageTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final void Function(String)? onSubmitted;

  const MessageTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: TextInputAction.send,
      onEditingComplete: () {},
      onSubmitted: onSubmitted,
      cursorColor: Theme.of(context).colorScheme.inversePrimary,
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
        fillColor: Theme.of(context).colorScheme.background,
        filled: true,
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
