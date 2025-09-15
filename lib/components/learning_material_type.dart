import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class LearningMaterialType {
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
    if (pdfTypes.contains(t)) {
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
    if (pdfTypes.contains(t)) {
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
