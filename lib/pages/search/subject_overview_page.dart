import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/unit_tile.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/unit_overview_page.dart';

class SubjectOverviewPage extends StatefulWidget {
  final Subject subject;
  const SubjectOverviewPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectOverviewPage> createState() => _SubjectOverviewPageState();
}

class _SubjectOverviewPageState extends State<SubjectOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.subject.name),
                background: Stack(children: [
                  OverflowBox(
                    maxWidth: 800,
                    maxHeight: 800,
                    child: FaIcon(
                      widget.subject.iconData,
                      color: widget.subject.color,
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
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: categoryMap[widget.subject.name]!.length,
                  itemBuilder: (BuildContext context, int categoryIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            categoryMap[widget.subject.name]![categoryIndex]
                                .name,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount:
                              categoryMap[widget.subject.name]![categoryIndex]
                                  .topics
                                  .length,
                          itemBuilder: (BuildContext context, int topicIndex) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    categoryMap[widget.subject.name]![
                                            categoryIndex]
                                        .topics[topicIndex]
                                        .name,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 145,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: categoryMap[
                                            widget.subject.name]![categoryIndex]
                                        .topics[topicIndex]
                                        .units
                                        .length,
                                    itemBuilder:
                                        (BuildContext context, int unitIndex) {
                                      return Row(
                                        children: [
                                          UnitTile(
                                            unit: categoryMap[widget.subject
                                                    .name]![categoryIndex]
                                                .topics[topicIndex]
                                                .units[unitIndex],
                                            onTap: () => navigateToUnitPage(
                                                widget.subject.name,
                                                categoryMap[widget.subject
                                                        .name]![categoryIndex]
                                                    .name,
                                                categoryMap[widget.subject
                                                        .name]![categoryIndex]
                                                    .topics[topicIndex]
                                                    .name,
                                                categoryMap[widget.subject
                                                        .name]![categoryIndex]
                                                    .topics[topicIndex]
                                                    .units[unitIndex]),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }

  void navigateToUnitPage(
      String subjectName, String categoryName, String topicName, Unit unit) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnitOverviewPage(
            subjectName: subjectName,
            categoryName: categoryName,
            topicName: topicName,
            unit: unit,
          ),
        ));
  }
}
