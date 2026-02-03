import 'package:flutter/material.dart';

class AdminConstants {
  static const List<String> statusOptions = [
    'Draft',
    'Ausstehend',
    'Genehmigt'
  ];
  static const List<String> learningBiteTypes = [
    'lesson',
    'text',
    'task',
    'video'
  ];
  static const List<String> taskTypes = [
    'singleChoice',
    'singleChoiceCloze',
    'freeTextFieldCloze',
    'multipleChoice',
    'indexCard',
  ];

  static const Map<String, IconData> availableIcons = {
    'Code': Icons.code,
    'Computer': Icons.computer,
    'Book': Icons.book,
    'Calculate': Icons.calculate,
    'Biotech': Icons.biotech,
    'History': Icons.history,
    'Language': Icons.language,
    'Science': Icons.science,
    'Music': Icons.music_note,
    'Art': Icons.brush,
    'Rocket': Icons.rocket_launch,
    'Lightbulb': Icons.lightbulb,
    'School': Icons.school,
    'Laptop': Icons.laptop,
    'Menu': Icons.menu_book,
  };

  static const Map<String, Color> availableColors = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
    'Indigo': Colors.indigo,
    'Pink': Colors.pink,
    'Cyan': Colors.cyan,
    'Brown': Colors.brown,
  };
}
