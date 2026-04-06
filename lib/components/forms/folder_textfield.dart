import 'package:flutter/material.dart';

class FolderTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const FolderTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 16, height: 1.2),
      strutStyle: const StrutStyle(
        fontSize: 16,
        height: 1.2,
        forceStrutHeight: true,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, height: 1.2),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        helperText: ' ', // Reserve space for error message
      ),
    );
  }
}
