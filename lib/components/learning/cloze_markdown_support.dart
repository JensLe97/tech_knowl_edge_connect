import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class ClozeSyntax extends md.InlineSyntax {
  ClozeSyntax() : super(r'\{\s*\}');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('cloze'));
    return true;
  }
}

typedef AnswerWidgetBuilder = Widget Function(int index, String answer);

class ClozeBuilder extends MarkdownElementBuilder {
  final List<String> correctAnswers;
  final AnswerWidgetBuilder builder;
  int _index = 0;

  ClozeBuilder(this.correctAnswers, this.builder);

  @override
  void visitElementBefore(md.Element element) {
    // Reset index when a new parse cycle starts (i.e. when index has
    // already been exhausted from a previous parse). This handles the case
    // where flutter_markdown re-parses via didChangeDependencies (theme
    // change) before build() creates a fresh ClozeBuilder instance.
    if (_index >= correctAnswers.length) {
      _index = 0;
    }
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (_index >= correctAnswers.length) {
      return const SizedBox.shrink();
    }

    final answer = correctAnswers[_index];
    final child = builder(_index, answer);
    _index++;

    // Return as Text.rich with a WidgetSpan so flutter_markdown's
    // _mergeInlineChildren can extract the TextSpan and merge it
    // with adjacent text spans into a single RichText widget.
    // This keeps the cloze field truly inline with surrounding text.
    final lineHeight = (parentStyle?.fontSize ?? 16) * 1.5;
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              height: lineHeight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// Rest of file removed as it moved to markdown_support.dart
