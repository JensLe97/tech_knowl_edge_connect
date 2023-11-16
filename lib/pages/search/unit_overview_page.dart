import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/learning_bite_tile.dart';
import 'package:tech_knowl_edge_connect/data/concepts/index.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';

class UnitOverviewPage extends StatefulWidget {
  final String subjectName;
  final String categoryName;
  final String topicName;
  final Unit unit;

  const UnitOverviewPage({
    super.key,
    required this.subjectName,
    required this.categoryName,
    required this.topicName,
    required this.unit,
  });

  @override
  State<UnitOverviewPage> createState() => _UnitOverviewPageState();
}

class _UnitOverviewPageState extends State<UnitOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.unit.name),
                background: Stack(children: [
                  OverflowBox(
                    maxWidth: 800,
                    maxHeight: 800,
                    child: FaIcon(
                      widget.unit.iconData,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: conceptMap[widget.subjectName]![
                                    widget.categoryName]![widget.topicName]![
                                widget.unit.name]!
                            .length,
                        itemBuilder: (BuildContext context, int conceptIndex) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  conceptMap[widget.subjectName]![
                                                  widget.categoryName]![
                                              widget.topicName]![
                                          widget.unit.name]![conceptIndex]
                                      .name,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 130,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: conceptMap[widget.subjectName]![
                                                  widget.categoryName]![
                                              widget.topicName]![
                                          widget.unit.name]![conceptIndex]
                                      .learningBites
                                      .length,
                                  itemBuilder: (BuildContext context,
                                      int learningBiteIndex) {
                                    return Row(
                                      children: [
                                        LearingBiteTile(
                                          learningBite: conceptMap[widget
                                                              .subjectName]![
                                                          widget.categoryName]![
                                                      widget.topicName]![
                                                  widget
                                                      .unit.name]![conceptIndex]
                                              .learningBites[learningBiteIndex],
                                          onTap: () =>
                                              navigateToLearningBitePage(
                                            conceptMap[widget.subjectName]![
                                                            widget
                                                                .categoryName]![
                                                        widget
                                                            .topicName]![widget
                                                        .unit
                                                        .name]![conceptIndex]
                                                    .learningBites[
                                                learningBiteIndex],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void navigateToLearningBitePage(LearningBite learningBite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningBitePage(learningBite: learningBite),
      ),
    );
  }
}
