import 'dart:math' as math;

import 'package:flutter/material.dart';

class AiTechKnowledgeCheckActivityIndicator extends StatefulWidget {
  final bool analyzing;

  const AiTechKnowledgeCheckActivityIndicator({
    super.key,
    required this.analyzing,
  });

  @override
  State<AiTechKnowledgeCheckActivityIndicator> createState() =>
      _AiTechKnowledgeCheckActivityIndicatorState();
}

class _AiTechKnowledgeCheckActivityIndicatorState
    extends State<AiTechKnowledgeCheckActivityIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.analyzing) {
      return Tooltip(
        message: 'Antwort wird transkribiert und ausgewertet',
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    return Tooltip(
      message: 'AI Tech liest die Frage vor',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 28,
            height: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                final phase = (_controller.value + index / 3) % 1;
                final height = 8 + math.sin(phase * math.pi * 2).abs() * 14;
                return Container(
                  width: 5,
                  height: height,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
