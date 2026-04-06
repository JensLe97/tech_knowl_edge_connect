import 'dart:ui';
import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  final Widget image;
  final IconData badgeIcon;
  final String badgeText;
  final String titlePart1;
  final String? titleHighlight;
  final String? titlePart2;
  final String subtitle;

  const OnboardingSlide({
    super.key,
    required this.image,
    required this.badgeIcon,
    required this.badgeText,
    required this.titlePart1,
    this.titleHighlight,
    this.titlePart2,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Top Graphic Layer
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Stack(
            fit: StackFit.expand,
            children: [
              image,
              // Fade Gradient Over Graphic
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.surface.withAlpha(26), // 10% opacity
                        cs.surface.withAlpha(0),
                        cs.surface,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content Panel (Glassmorphism look)
        Positioned(
          bottom: 120, // Leave room for footer
          left: 24,
          right: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withAlpha(isDark ? 26 : 76),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      badgeText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Glass Panel Main
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x66101418)
                          : const Color(0xB2FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: cs.outlineVariant.withAlpha(isDark ? 26 : 128),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -0.5,
                              color: cs.onSurface,
                            ),
                            children: [
                              TextSpan(text: '$titlePart1 '),
                              if (titleHighlight != null)
                                TextSpan(
                                  text: titleHighlight,
                                  style: TextStyle(color: cs.primary),
                                ),
                              if (titlePart2 != null)
                                TextSpan(
                                  text: titlePart2,
                                  style: TextStyle(color: cs.primary),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16), // space for dots
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
