import 'package:flutter/material.dart';

/// Animated three-dot typing indicator shown while the AI is thinking.
class TypingIndicator extends StatefulWidget {
  final bool isMe;

  const TypingIndicator({super.key, this.isMe = false});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = ((_controller.value - delay) % 1.0);
        final offset = t < 0.3
            ? (t / 0.3)
            : t < 0.6
                ? ((0.6 - t) / 0.3)
                : 0.0;
        return Transform.translate(
          offset: Offset(0, -6 * offset.toDouble()),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary.withAlpha(120)
                : Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.surfaceContainerLowest
                    : Theme.of(context).colorScheme.secondary.withAlpha(40),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withAlpha(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isMe ? 5 : 12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 16 : 2),
              topRight: Radius.circular(isMe ? 2 : 16),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0.0),
              const SizedBox(width: 5),
              _dot(0.2),
              const SizedBox(width: 5),
              _dot(0.4),
            ],
          ),
        ),
      ),
    );
  }
}
