import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class LearningMaterialType {
  static const List<String> supportedTypes = [
    ...pdfTypes,
    ...imageTypes,
    ...videoTypes,
    ...textTypes,
  ];
  static const List<String> textTypes = [
    'txt',
    'md',
    'docx',
    'doc',
    'rtf',
    'adoc',
  ];
  static const List<String> pdfTypes = ['pdf'];
  static const List<String> imageTypes = [
    // heic not supported by android
    // 'heic',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp'
  ];
  static const List<String> videoTypes = ['mp4', 'mov', 'webm', 'mkv'];

  static IconData getIconForType(String type) {
    final t = type.toLowerCase();
    if (textTypes.contains(t)) {
      return FontAwesomeIcons.fileLines;
    } else if (pdfTypes.contains(t)) {
      return FontAwesomeIcons.filePdf;
    } else if (imageTypes.contains(t)) {
      return FontAwesomeIcons.fileImage;
    } else if (videoTypes.contains(t)) {
      return FontAwesomeIcons.fileVideo;
    } else {
      return FontAwesomeIcons.file;
    }
  }

  static String getMimeType(String type) {
    String t = type.toLowerCase();
    t = t == "jpg" ? "jpeg" : t;
    if (textTypes.contains(t)) {
      switch (t) {
        case 'txt':
          return 'text/plain';
        case 'md':
          return 'text/markdown';
        case 'docx':
          return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        case 'doc':
          return 'application/msword';
        case 'rtf':
          return 'application/rtf';
        case 'adoc':
          return 'text/asciidoc';
        default:
          return 'text/plain';
      }
    } else if (pdfTypes.contains(t)) {
      return 'application/$t';
    } else if (imageTypes.contains(t)) {
      return 'image/$t';
    } else if (videoTypes.contains(t)) {
      return 'video/$t';
    } else {
      return 'application/octet-stream';
    }
  }
}
