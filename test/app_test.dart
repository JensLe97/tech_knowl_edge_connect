import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/components/subject_tile.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets(
      'SubjectTile displays subject name, icon, color, and responds to tap',
      (WidgetTester tester) async {
    bool tapped = false;
    final subject = Subject(
        id: 'test_subject',
        name: 'Testfach',
        color: Colors.blue,
        iconData: FontAwesomeIcons.book);
    await tester.pumpWidget(
      makeTestableWidget(
        Scaffold(
          body: SubjectTile(
            subject: subject,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );
    // Check name
    expect(find.text('Testfach'), findsOneWidget);
    // Check icon
    expect(find.byType(FaIcon), findsOneWidget);
    // Check color (Container background)
    final container = tester.widget<Container>(find
        .descendant(
          of: find.byType(SubjectTile),
          matching: find.byType(Container),
        )
        .first);
    final BoxDecoration? decoration = container.decoration as BoxDecoration?;
    expect(decoration?.color, Colors.blue);
    // Check tap
    await tester.tap(find.byType(SubjectTile));
    expect(tapped, isTrue);
  });

  group('Test Subject', () {
    test('Subject should return the initial values', () {
      final subject = Subject(
          id: 'test_mathe',
          name: 'Mathe',
          color: Colors.blue,
          iconData: Icons.add);
      expect(subject.name, 'Mathe');
      expect(subject.color, Colors.blue);
      expect(subject.iconData, Icons.add);
    });

    test('Subject should return the initial values', () {
      final subject = Subject(
          id: 'test_deutsch',
          name: 'Deutsch',
          color: Colors.red,
          iconData: Icons.book);
      expect(subject.name, 'Deutsch');
      expect(subject.color, Colors.red);
      expect(subject.iconData, Icons.book);
    });
  });
}
