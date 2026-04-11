import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/models/user/report_reason.dart';
import 'package:tech_knowl_edge_connect/pages/library/learning_material_preview_page.dart';
import 'package:tech_knowl_edge_connect/services/user/user_service.dart';

/// Extracts the file extension from a Firebase Storage download URL.
/// Falls back to 'mp4' if extraction fails.
String _extractExtFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final oIndex = uri.pathSegments.indexOf('o');
    if (oIndex != -1 && oIndex + 1 < uri.pathSegments.length) {
      final decoded = Uri.decodeComponent(uri.pathSegments[oIndex + 1]);
      final dot = decoded.lastIndexOf('.');
      if (dot != -1) return decoded.substring(dot + 1).toLowerCase();
    }
  } catch (_) {}
  return 'mp4';
}

/// Extracts the filename (without path) from a Firebase Storage download URL.
String _extractNameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final oIndex = uri.pathSegments.indexOf('o');
    if (oIndex != -1 && oIndex + 1 < uri.pathSegments.length) {
      final decoded = Uri.decodeComponent(uri.pathSegments[oIndex + 1]);
      return decoded.split('/').last;
    }
  } catch (_) {}
  return 'Datei';
}

class ChatBubble extends StatelessWidget {
  final String uid;
  final String message;
  final String type;
  final bool isMe;
  final Timestamp time;
  final UserService userService;

  /// Optional display name shown in the bubble and as the preview page title.
  final String? fileName;

  const ChatBubble({
    super.key,
    required this.uid,
    required this.message,
    required this.type,
    required this.isMe,
    required this.time,
    required this.userService,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final isMedia = LearningMaterialType.categorize(type) != 'text';

    // Effective file extension for LearningMaterialPreviewPage and icon lookup.
    final effectiveExt =
        LearningMaterialType.supportedTypes.contains(type.toLowerCase())
            ? type.toLowerCase()
            : _extractExtFromUrl(message);

    // Display name: explicit param wins, else extract from Storage URL.
    final effectiveName = (fileName != null && fileName!.isNotEmpty)
        ? fileName!
        : _extractNameFromUrl(message);

    final icon = LearningMaterialType.getIconForType(effectiveExt);

    // Calculate dynamic cache sizes based on device screen density.
    // The image container is max 260 width, min 160 height. We'll use 400 as a safe upper bound.
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int cacheSize = min((400 * pixelRatio).round(), 800);

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 40 : 0,
        right: isMe ? 0 : 40,
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 16 : 2),
            topRight: Radius.circular(isMe ? 2 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16)),
        onTap: isMedia
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LearningMaterialPreviewPage(
                      url: message,
                      type: effectiveExt,
                      name: effectiveName,
                    ),
                  ),
                )
            : null,
        onLongPress: () {
          if (isMe) {
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            enableDrag: true,
            builder: (BuildContext context) => SafeArea(
              child: UserBottomSheet(
                  toggleBlockUser: () {},
                  report: reportContent,
                  isContent: true),
            ),
          );
        },
        child: Container(
          padding: LearningMaterialType.categorize(type) == 'image'
              ? const EdgeInsets.all(6)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                bottomRight: const Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (LearningMaterialType.categorize(type) == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 260, minHeight: 160, minWidth: 220),
                    child: CachedNetworkImage(
                      imageUrl: message,
                      fit: BoxFit.contain,
                      memCacheHeight: cacheSize,
                      memCacheWidth: cacheSize,
                      maxHeightDiskCache: cacheSize,
                      maxWidthDiskCache: cacheSize,
                      placeholder: (context, url) => SizedBox(
                        width: 220,
                        height: 160,
                        child: Center(
                          child: CircularProgressIndicator(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      errorWidget: (_, __, ___) => SizedBox(
                        width: 220,
                        height: 80,
                        child: Icon(Icons.broken_image,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else if (isMedia)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(icon,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            effectiveName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            effectiveExt.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                MarkdownBody(
                  data: message,
                  styleSheet: createMarkdownStyleSheet(context).copyWith(
                    p: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  extensionSet: getMarkdownExtensionSet(),
                  builders: getMarkdownColorBuilders(),
                ),
              const SizedBox(height: 5),
              Text(
                time.toDate().toString().substring(11, 16),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void reportContent(ReportReason reason) {
    userService.reportContent(message, uid, type, false, reason);
  }
}
