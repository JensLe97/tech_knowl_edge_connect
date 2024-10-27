import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/pages/search/search_page.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('Search Page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(makeTestableWidget(const SearchPage()));

    expect(find.text('Informatik'), findsOneWidget);
    expect(find.text('Hardware'), findsNothing);

    // Tap the 'Weiter' button and trigger a frame.
    await tester.tap(find.text('Informatik'));
    await tester.pumpAndSettle();

    // Tap the 'Weiter' button and trigger a frame.
    await tester.tap(find.text('Komponenten'));
    await tester.pumpAndSettle();

    expect(find.text('Mainboard'), findsOneWidget);
    expect(find.text('Hardware'), findsNothing);
  });

  group('Test Subject', () {
    test('Subject should return the initial values', () {
      final subject =
          Subject(name: 'Mathe', color: Colors.blue, iconData: Icons.add);
      expect(subject.name, 'Mathe');
      expect(subject.color, Colors.blue);
      expect(subject.iconData, Icons.add);
    });

    test('Subject should return the initial values', () {
      final subject =
          Subject(name: 'Deutsch', color: Colors.red, iconData: Icons.book);
      expect(subject.name, 'Deutsch');
      expect(subject.color, Colors.red);
      expect(subject.iconData, Icons.book);
    });
  });
}
