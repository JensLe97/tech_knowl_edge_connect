import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SearchBar(
            controller: controller,
            leading: const Icon(Icons.search),
            hintText: hintText,
            constraints: const BoxConstraints(minHeight: 36, maxHeight: 36),
            onSubmitted: (String value) => controller.clear(),
            shape: MaterialStateProperty.all(const ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            )),
          ),
        ),
      ],
    );
  }
}
