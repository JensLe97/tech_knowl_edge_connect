import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';

class LearningBitePage extends StatefulWidget {
  final LearningBite learningBite;

  const LearningBitePage({
    super.key,
    required this.learningBite,
  });

  @override
  State<LearningBitePage> createState() => _LearningBitePageState();
}

class _LearningBitePageState extends State<LearningBitePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                title: Text(widget.learningBite.name),
                background: Stack(children: [
                  OverflowBox(
                    maxWidth: 800,
                    maxHeight: 800,
                    child: FaIcon(
                      widget.learningBite.iconData,
                      size: 50,
                    ),
                  ),
                ]),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.learningBite.data,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
