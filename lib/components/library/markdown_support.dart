import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';

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
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          width: 1.5,
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    code: GoogleFonts.robotoMono(
      textStyle: TextStyle(
        fontFamilyFallback: const ['Courier New', 'Courier'],
        fontSize: baseStyle.fontSize! * 0.9,
        color: baseStyle.color,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    ),
    codeblockDecoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    codeblockPadding: const EdgeInsets.all(8),
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

class PreBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final theme = Theme.of(context);

    final textStyle = GoogleFonts.robotoMono(
      textStyle: (preferredStyle ?? theme.textTheme.bodyMedium!).copyWith(
        fontFamilyFallback: const ['Courier New', 'Courier'],
        fontSize: theme.textTheme.bodyLarge!.fontSize! * 0.9,
        color: theme.colorScheme.onSurface,
        // Clear any inherited background color from the inline code style
        backgroundColor: Colors.transparent,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        element.textContent.trimRight(),
        style: textStyle,
        softWrap: true, // Prevents horizontal scrolling
      ),
    );
  }
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
    final baseStyle =
        (preferredStyle ?? theme.textTheme.bodyMedium!).merge(parentStyle);
    final codeStyle = GoogleFonts.robotoMono(
      textStyle: baseStyle.copyWith(
        fontFamilyFallback: const ['Courier New', 'Courier'],
        fontSize:
            (baseStyle.fontSize ?? theme.textTheme.bodyLarge!.fontSize!) * 0.9,
        color: theme.colorScheme.onSurface,
        backgroundColor: Colors.transparent,
      ),
    );

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                element.textContent,
                style: codeStyle,
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

    // Merge preferred + parent styles so inline emphasis (e.g. **bold**, *italic*)
    // is preserved when color tags are nested inside markdown formatting.
    final baseStyle = (preferredStyle ?? const TextStyle()).merge(parentStyle);
    final parsed = _parseInlineEmphasis(element.textContent);
    var style = baseStyle.copyWith(color: color);
    if (parsed.isBold) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }
    if (parsed.isItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    // Must use Text.rich with a TextSpan so flutter_markdown's
    // _mergeInlineChildren can extract and merge it with adjacent spans.
    // A plain Text("string") has textSpan == null and breaks the inline flow.
    return Text.rich(
      TextSpan(
        text: parsed.text,
        style: style,
      ),
    );
  }
}

class _InlineEmphasisResult {
  final String text;
  final bool isBold;
  final bool isItalic;

  const _InlineEmphasisResult({
    required this.text,
    required this.isBold,
    required this.isItalic,
  });
}

_InlineEmphasisResult _parseInlineEmphasis(String input) {
  var text = input;
  var isBold = false;
  var isItalic = false;

  // Handle ***text*** first.
  final boldItalic = RegExp(r'^\*\*\*(.+)\*\*\*$', dotAll: true);
  final boldItalicMatch = boldItalic.firstMatch(text);
  if (boldItalicMatch != null) {
    text = boldItalicMatch.group(1) ?? text;
    isBold = true;
    isItalic = true;
    return _InlineEmphasisResult(
        text: text, isBold: isBold, isItalic: isItalic);
  }

  final bold = RegExp(r'^\*\*(.+)\*\*$', dotAll: true);
  final boldMatch = bold.firstMatch(text);
  if (boldMatch != null) {
    text = boldMatch.group(1) ?? text;
    isBold = true;
  }

  final italic = RegExp(r'^\*(.+)\*$', dotAll: true);
  final italicMatch = italic.firstMatch(text);
  if (italicMatch != null) {
    text = italicMatch.group(1) ?? text;
    isItalic = true;
  }

  return _InlineEmphasisResult(text: text, isBold: isBold, isItalic: isItalic);
}

Map<String, MarkdownElementBuilder> getMarkdownColorBuilders() {
  final colorBuilder = ColorBuilder();
  return {
    'pre': PreBuilder(),
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
