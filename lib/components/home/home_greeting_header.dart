import 'package:flutter/material.dart';

class HomeGreetingHeader extends StatelessWidget {
  final String? username;
  final bool isLoading;

  const HomeGreetingHeader({super.key, this.username, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.secondaryContainer,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: colorScheme.primary,
                    child: Icon(Icons.person,
                        color: colorScheme.onPrimary, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Willkommen zurück,',
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
