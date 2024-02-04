import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/learning_bite_tile.dart';
import 'package:tech_knowl_edge_connect/data/concepts/index.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/index.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
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
  final confettiController = ConfettiController();

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              elevation: 0,
              shadowColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsetsDirectional.only(top: 10, bottom: 10),
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
                                height: 145,
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
                                    LearningBite learningBite =
                                        conceptMap[widget.subjectName]![
                                                        widget.categoryName]![
                                                    widget.topicName]![
                                                widget.unit.name]![conceptIndex]
                                            .learningBites[learningBiteIndex];
                                    List<int> indices = [
                                      // subjectIndex
                                      conceptMap.keys.toList().indexWhere(
                                          (element) =>
                                              element == widget.subjectName),
                                      // categoryIndex
                                      conceptMap[widget.subjectName]!
                                          .keys
                                          .toList()
                                          .indexWhere((element) =>
                                              element == widget.categoryName),
                                      // topicIndex
                                      conceptMap[widget.subjectName]![
                                              widget.categoryName]!
                                          .keys
                                          .toList()
                                          .indexWhere((element) =>
                                              element == widget.topicName),
                                      // unitIndex
                                      learningBiteMap[widget.subjectName]![
                                                  widget.categoryName]![
                                              widget.topicName]!
                                          .keys
                                          .toList()
                                          .indexWhere((element) =>
                                              element == widget.unit.name),
                                      // conceptIndex
                                      conceptIndex,
                                      // learningBiteIndex
                                      learningBiteIndex
                                    ];
                                    return Row(
                                      children: [
                                        LearingBiteTile(
                                          completed: completedLearningBites.any(
                                              (e) => const ListEquality()
                                                  .equals(e, indices)),
                                          learningBite: learningBite,
                                          onTap: () =>
                                              navigateToLearningBitePage(
                                                  learningBite, indices),
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

  void setResumeSubjects(List<List<int>> resSubs, List<int> indices) async {
    if (indices.length == 1 &&
        resumeSubjects.elementAt(indices.first).isNotEmpty) {
      resumeSubjects.elementAt(indices.first).clear();
    } else {
      if (resumeSubjects.elementAt(indices.first).isEmpty) {
        resumeSubjects.removeAt(indices.first);
        resumeSubjects.insert(indices.first, indices);
      } else {
        resumeSubjects.elementAt(indices.first).replaceRange(0, 6, indices);
      }
    }
    User? currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      'resumeSubjects': jsonEncode(resSubs),
    });
  }

  void setCompletedLearningBites(List<List<int>> complLearnBites) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      'completedLearningBites': jsonEncode(complLearnBites),
    });
  }

  void navigateToLearningBitePage(
      LearningBite learningBite, List<int> indices) {
    setResumeSubjects(resumeSubjects, indices);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningBitePage(
          learningBite: learningBite,
          tasks: learningBite.type == LearningBiteType.lesson
              ? learningBite.tasks!
              : [],
        ),
      ),
    ).then(
      (completed) => setState(() {
        completed = completed ?? false;

        bool confetti = false;
        int numLearningBites = learningBiteMap[widget.subjectName]!
            .values
            .elementAt(indices[1])
            .values
            .elementAt(indices[2])
            .values
            .elementAt(indices[3])
            .values
            .elementAt(indices[4])
            .length;
        if (completed &&
            !completedLearningBites
                .any((e) => const ListEquality().equals(e, indices))) {
          learningBite.completed = true;
          List<int> indcs = List.from(indices);
          completedLearningBites.add(indcs);
          setCompletedLearningBites(completedLearningBites);
          int numCompletedLearningBites = 0;
          List<int> tmpIndcs = List.from(indices);
          for (var i = 0; i < numLearningBites; i++) {
            tmpIndcs.last = i;
            if (completedLearningBites
                .any((e) => const ListEquality().equals(e, tmpIndcs))) {
              numCompletedLearningBites++;
            }
          }

          if (numCompletedLearningBites == numLearningBites) {
            confetti = true;
            List<int> tmpEndIndcs = List.from(indices);
            confettiController.play();
            showDialog(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: ConfettiWidget(
                          confettiController: confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          emissionFrequency: 0.05,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          title: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                "Du hast alle Lektionen zum Thema ${learningBiteMap[widget.subjectName]!.values.elementAt(tmpEndIndcs[1]).values.elementAt(tmpEndIndcs[2]).values.elementAt(tmpEndIndcs[3]).keys.elementAt(tmpEndIndcs[4])} abgeschlossen!",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                });
          }
        }
        if (completed) {
          if (!confetti && indices[5] + 1 < numLearningBites) {
            indices.replaceRange(5, 6, [indices[5] + 1]);
            setResumeSubjects(resumeSubjects, indices);
          } else {
            setResumeSubjects(resumeSubjects, [indices[0]]);
          }
        }
      }),
    );
  }
}
