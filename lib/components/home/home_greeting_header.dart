import 'package:flutter/material.dart';

class HomeGreetingHeader extends StatelessWidget {
  final String? username;
  final bool isLoading;

  const HomeGreetingHeader({super.key, this.username, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isLoading)
            // Skeleton loader for the text to avoid visual jump
            Container(
              height: 32,
              width: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            )
          else
            Text(
              username != null && username!.isNotEmpty
                  ? 'Hallo $username!'
                  : 'Hallo!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.person),
          )
        ],
      ),
    );
  }
}
