import 'package:flutter/material.dart';

class HomeGreetingHeader extends StatelessWidget {
  final String? username;
  final bool isLoading;

  const HomeGreetingHeader({super.key, this.username, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parts = (username ?? '').trim().split(RegExp(r'\s+'));
    final String initials = parts.isEmpty || parts[0].isEmpty
        ? '?'
        : parts.length > 1
            ? (parts[0][0] + parts.last[0]).toUpperCase()
            : parts[0].length > 1
                ? parts[0].substring(0, 2).toUpperCase()
                : parts[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Willkommen zurück',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isLoading)
                    Container(
                      height: 24,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  else
                    Text(
                      username != null && username!.isNotEmpty
                          ? 'Hallo $username!'
                          : 'Hallo!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
