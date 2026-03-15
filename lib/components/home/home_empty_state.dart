import 'package:flutter/material.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
          children: const [
            TextSpan(text: 'Starte eine Lektion über die  '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(height: 2),
                  Text('Suche', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            TextSpan(text: '  in der unteren Navigationsleiste.'),
          ],
        ),
      ),
    );
  }
}
