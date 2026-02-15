import 'package:flutter/material.dart';

class UserConstants {
  static const Map<String, IconData> availableIcons = {
    'Folder': Icons.folder,
    'Language': Icons.language,
    'Science': Icons.science,
    'Biotech': Icons.biotech,
    'Computer': Icons.computer,
    'History': Icons.history_edu,
    'Calculate': Icons.calculate,
    'Music': Icons.music_note,
    'Palette': Icons.palette,
    'Sports': Icons.sports_soccer,
    'Menu Book': Icons.menu_book,
    'School': Icons.school,
    'Lightbulb': Icons.lightbulb,
    'Work': Icons.work,
    'Psychology': Icons.psychology,
    'Public': Icons.public,
    'Gavel': Icons.gavel,
    'Health': Icons.health_and_safety,
    'Book': Icons.book,
    'Article': Icons.article,
    'Description': Icons.description,
    'Quiz': Icons.quiz,
    'Assignment': Icons.assignment,
    'Code': Icons.code,
    'Translate': Icons.translate,
    'Movie': Icons.movie,
    'Image': Icons.image,
    'Edit': Icons.edit_note,
    'Video': Icons.videocam,
    'Mic': Icons.mic,
    'Terminal': Icons.terminal,
    'Stars': Icons.stars,
    'Rocket': Icons.rocket_launch,
    'Laptop': Icons.laptop,
    'Brush': Icons.brush,
  };

  // Status Constants
  static const String statusPrivate = 'private'; // Entwurf
  static const String statusPending = 'pending'; // Ausstehend
  static const String statusApproved = 'approved'; // Genehmigt
  static const String statusRejected = 'rejected'; // Abgelehnt

  static const Map<String, String> statusLabels = {
    statusPrivate: 'Entwurf',
    statusPending: 'Ausstehend',
    statusApproved: 'Genehmigt',
    statusRejected: 'Abgelehnt',
  };

  static const List<String> statusOptions = [
    statusPrivate,
    statusPending,
    statusApproved,
    statusRejected,
  ];

  static Color getStatusColor(String status) {
    if (status == statusApproved) return Colors.green;
    if (status == statusRejected) return Colors.red;
    if (status == statusPending) return Colors.orange;
    return Colors.grey;
  }

  static const Map<String, Color> availableColors = {
    'Red': Color.fromARGB(255, 236, 50, 29),
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Deep Purple': Colors.deepPurple,
    'Indigo': Colors.indigo,
    'Blue': Colors.blue,
    'Light Blue': Colors.lightBlue,
    'Cyan': Colors.cyan,
    'Teal': Colors.teal,
    'Green': Colors.green,
    'Light Green': Colors.lightGreen,
    'Lime': Colors.lime,
    'Amber': Colors.amber,
    'Orange': Colors.orange,
    'Deep Orange': Colors.deepOrange,
    'Brown': Colors.brown,
    'Blue Grey': Colors.blueGrey,
  };

  static const List<String> learningBiteTypes = [
    'lesson',
    'text',
    'task',
    'video'
  ];

  static const String learningBiteLesson = 'lesson';
  static const String learningBiteText = 'text';
  static const String learningBiteTask = 'task';
  static const String learningBiteVideo = 'video';

  static const Map<String, String> learningBiteTypeLabels = {
    learningBiteLesson: 'Lektion',
    learningBiteText: 'Text',
    learningBiteTask: 'Aufgabe',
    learningBiteVideo: 'Video',
  };

  static const List<String> taskTypes = [
    'singleChoice',
    'singleChoiceCloze',
    'freeTextFieldCloze',
    'multipleChoice',
    'indexCard',
  ];

  static const String taskTypeSingleChoice = 'singleChoice';
  static const String taskTypeSingleChoiceCloze = 'singleChoiceCloze';
  static const String taskTypeFreeTextFieldCloze = 'freeTextFieldCloze';
  static const String taskTypeMultipleChoice = 'multipleChoice';
  static const String taskTypeIndexCard = 'indexCard';

  static const Map<String, String> taskTypeLabels = {
    taskTypeSingleChoice: 'Single Choice',
    taskTypeSingleChoiceCloze: 'Lückentext (Single Choice)',
    taskTypeFreeTextFieldCloze: 'Lückentext (Freitext)',
    taskTypeMultipleChoice: 'Multiple Choice',
    taskTypeIndexCard: 'Karteikarte',
  };

  static IconData? getIconFromData(Map<String, dynamic>? data) {
    if (data == null) return null;

    final int? codePoint = data['codePoint'];
    final String? fontFamily = data['fontFamily'];
    final String? fontPackage = data['fontPackage'];

    if (codePoint == null) return null;

    try {
      return availableIcons.values.firstWhere(
        (icon) =>
            icon.codePoint == codePoint &&
            icon.fontFamily == fontFamily &&
            icon.fontPackage == fontPackage,
        orElse: () => Icons.error,
      );
    } catch (_) {
      return null;
    }
  }
}
