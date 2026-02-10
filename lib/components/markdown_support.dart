import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class ColorSyntax extends md.InlineSyntax {
  // Matches <color>text</color>
  ColorSyntax() : super(r'<([a-zA-Z]+)>(.*?)</\1>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final color = match[1]!;
    final text = match[2]!;
    // Use the color name as the tag. Normalized to lowercase.
    final element = md.Element(color.toLowerCase(), [md.Text(text)]);
    parser.addNode(element);
    return true;
  }
}

// Helper to create a stylesheet that includes color tags and uses bodyLarge
MarkdownStyleSheet createMarkdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final baseStyle = theme.textTheme.bodyLarge!;

  MarkdownStyleSheet styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: baseStyle,
    code: TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier New', 'Courier'],
      fontSize: baseStyle.fontSize! * 0.9,
      color: baseStyle.color,
    ),
    codeblockDecoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    codeblockPadding: const EdgeInsets.all(12),
    blockquote: baseStyle.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    ),
    blockquoteDecoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      borderRadius: BorderRadius.circular(8),
      border: Border(
        left: BorderSide(
          color: theme.colorScheme.primary,
          width: 4,
        ),
      ),
    ),
    blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  return styleSheet;
}

class InlineCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                element.textContent.trimRight(),
                style: preferredStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    String colorName = element.attributes['color'] ?? element.tag;
    colorName = colorName.toLowerCase();

    Color color;
    switch (colorName) {
      case 'red':
        color = Colors.red;
        break;
      case 'green':
        color = Colors.green;
        break;
      case 'blue':
        color = Colors.blue;
        break;
      case 'yellow':
        color = Colors.amber;
        break;
      case 'orange':
        color = Colors.orange;
        break;
      case 'purple':
        color = Colors.purple;
        break;
      case 'grey':
      case 'gray':
        color = Colors.grey;
        break;
      default:
        color = parentStyle?.color ?? Colors.black;
    }

    // Use parentStyle as base since preferredStyle (from styleSheet.styles[tag])
    // is null for custom color tags.
    final baseStyle = preferredStyle ?? parentStyle;
    // Must use Text.rich with a TextSpan so flutter_markdown's
    // _mergeInlineChildren can extract and merge it with adjacent spans.
    // A plain Text("string") has textSpan == null and breaks the inline flow.
    return Text.rich(
      TextSpan(
        text: element.textContent,
        style: baseStyle?.copyWith(color: color) ?? TextStyle(color: color),
      ),
    );
  }
}

Map<String, MarkdownElementBuilder> getMarkdownColorBuilders() {
  final colorBuilder = ColorBuilder();
  return {
    'code': InlineCodeBuilder(),
    'colored-text': colorBuilder,
    'red': colorBuilder,
    'green': colorBuilder,
    'blue': colorBuilder,
    'yellow': colorBuilder,
    'orange': colorBuilder,
    'purple': colorBuilder,
    'grey': colorBuilder,
    'gray': colorBuilder,
  };
}

md.ExtensionSet getMarkdownExtensionSet() {
  return md.ExtensionSet(
    md.ExtensionSet.gitHubFlavored.blockSyntaxes,
    [
      ColorSyntax(),
      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
    ],
  );
}
