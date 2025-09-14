import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/resume_tile.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/index.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/pages/chats/chat_page.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserDetails() {
    // Reset fields
    // await FirebaseFirestore.instance
    //     .collection("Users")
    //     .doc(currentUser!.email)
    //     .update({
    //   'completedLearningBites': jsonEncode([]),
    //   'resumeSubjects': jsonEncode([[], [], [], [], [], [], []]),
    // });

    return FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  final confettiController = ConfettiController();

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Center(
          child: Text('Home'),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              if (user == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<List<int>> tmpResumeSubjects = [];
              final sharedResumeSubjects =
                  user['resumeSubjects'] ?? "[[], [], [], [], [], [], []]";
              for (var resumeSubject in jsonDecode(sharedResumeSubjects)) {
                tmpResumeSubjects.add(List<int>.from(resumeSubject));
              }
              resumeSubjects = tmpResumeSubjects;

              List<List<int>> tmpCompletedLearningBites = [];
              final sharedCompletedLearningBites =
                  user['completedLearningBites'] ?? "[]";
              for (var completedLearningBite
                  in jsonDecode(sharedCompletedLearningBites)) {
                tmpCompletedLearningBites
                    .add(List<int>.from(completedLearningBite));
              }
              completedLearningBites = tmpCompletedLearningBites;

              blockedUsers = user['blockedUsers'] != null
                  ? List<String>.from(user['blockedUsers'])
                  : [];

              likedLearningMaterials = user['likedLearningMaterials'] != null
                  ? List<String>.from(user['likedLearningMaterials'])
                  : [];

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Hallo",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${user['username']}!",
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(24)),
                                child: const Icon(Icons.person),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          resumeSubjects.every((element) => element.isEmpty)
                              ? const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Starte eine Lektion über die  ",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.search),
                                            Text(
                                              "Suche",
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "in der unteren Navigationsleiste",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "Mach dort weiter, wo du aufgehört hast",
                                  style: TextStyle(fontSize: 20),
                                ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: resumeSubjects.length,
                              itemBuilder: (BuildContext context, int index) {
                                return resumeSubjects[index].length == 6
                                    ? ResumeTile(
                                        path:
                                            """${learningBiteMap.values.elementAt(resumeSubjects[index].elementAt(0)).keys.elementAt(resumeSubjects[index].elementAt(1))} > ${learningBiteMap.values.elementAt(resumeSubjects[index].elementAt(0)).values.elementAt(resumeSubjects[index].elementAt(1)).keys.elementAt(resumeSubjects[index].elementAt(2))} > ${learningBiteMap.values.elementAt(resumeSubjects[index].elementAt(0)).values.elementAt(resumeSubjects[index].elementAt(1)).values.elementAt(resumeSubjects[index].elementAt(2)).keys.elementAt(resumeSubjects[index].elementAt(3))} > ${learningBiteMap.values.elementAt(resumeSubjects[index].elementAt(0)).values.elementAt(resumeSubjects[index].elementAt(1)).values.elementAt(resumeSubjects[index].elementAt(2)).values.elementAt(resumeSubjects[index].elementAt(3)).keys.elementAt(resumeSubjects[index].elementAt(4))}""",
                                        learningBite: learningBiteMap.values
                                            .elementAt(resumeSubjects[index]
                                                .elementAt(0))
                                            .values
                                            .elementAt(resumeSubjects[index]
                                                .elementAt(1))
                                            .values
                                            .elementAt(resumeSubjects[index]
                                                .elementAt(2))
                                            .values
                                            .elementAt(resumeSubjects[index]
                                                .elementAt(3))
                                            .values
                                            .elementAt(resumeSubjects[index]
                                                .elementAt(4))
                                            .elementAt(resumeSubjects[index]
                                                .elementAt(5)),
                                        subject: subjects[
                                            resumeSubjects[index].elementAt(0)],
                                        onTap: () => navigateToLearningBitePage(
                                            learningBiteMap.values
                                                .elementAt(resumeSubjects[index]
                                                    .elementAt(0))
                                                .values
                                                .elementAt(resumeSubjects[index]
                                                    .elementAt(1))
                                                .values
                                                .elementAt(resumeSubjects[index]
                                                    .elementAt(2))
                                                .values
                                                .elementAt(resumeSubjects[index]
                                                    .elementAt(3))
                                                .values
                                                .elementAt(resumeSubjects[index]
                                                    .elementAt(4))
                                                .elementAt(resumeSubjects[index]
                                                    .elementAt(5)),
                                            resumeSubjects[index]),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ),
                        ]),
                  ),
                ),
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatPage(
                receiverUsername: "AI Tech",
                receiverUid: "aitech",
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(FontAwesomeIcons.robot),
      ),
    );
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
        .doc(currentUser!.uid)
        .update({
      'resumeSubjects': jsonEncode(resSubs),
    });
  }

  void setCompletedLearningBites(List<List<int>> complLearnBites) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.uid)
        .update({
      'completedLearningBites': jsonEncode(complLearnBites),
    });
  }

  void navigateToLearningBitePage(
      LearningBite learningBite, List<int> indices) {
    String subjectName = learningBiteMap.keys.elementAt(indices[0]);
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
        int numLearningBites = learningBiteMap[subjectName]!
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
                                "Du hast alle Lektionen zum Thema ${learningBiteMap[subjectName]!.values.elementAt(tmpEndIndcs[1]).values.elementAt(tmpEndIndcs[2]).values.elementAt(tmpEndIndcs[3]).keys.elementAt(tmpEndIndcs[4])} abgeschlossen!",
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
