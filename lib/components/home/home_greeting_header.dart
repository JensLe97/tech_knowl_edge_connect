import 'package:flutter/material.dart';

class HomeGreetingHeader extends StatelessWidget {
  final String username;

  const HomeGreetingHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Hallo $username!',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
