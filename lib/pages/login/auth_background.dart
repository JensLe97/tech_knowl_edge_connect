import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Background image and gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBJ6ymwK36DD2Wa9J6d2V-V1g0IZZsWERfBIPvuSIt1B7BSUMWiH697koIlp43ETpthGfee9sDJFuAs55I1gtojtkxW3djF3olVUiIUKR1cM5EgvVllMjSZ512UUM6xrs4lazhqStUCT-2v5E2GhwZ4ztq4XKJIWXsa2M3Z-IP9ZnB_AHp--BLXQbY7_czcdG9oCyKF1w7HFbjgWWG07OYNQvls1big_BsuWk77uhO7xYUUGjXdscO1cii0UdLZ-Bq81_7JV0u4o1CF'),
                fit: BoxFit.cover,
                opacity: 0.3,
                // blendMode: BlendMode.multiply, // Add if needed
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surface.withAlpha(100),
                    cs.surface.withAlpha(200),
                    cs.surface,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Secure content area
        SafeArea(child: child),
      ],
    );
  }
}
