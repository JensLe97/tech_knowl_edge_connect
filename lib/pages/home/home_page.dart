import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_knowl_edge_connect/components/resume_tile.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/index.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<dynamic> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Center(
          child: Text('Home'),
        ),
      ),
      body: FutureBuilder(
          future: Future.wait([getUserDetails(), getSharedPreferences()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
            } else if (snapshot.hasData) {
              final userData =
                  snapshot.data![0] as DocumentSnapshot<Map<String, dynamic>>;
              Map<String, dynamic>? user = userData.data();

              final SharedPreferences prefs = snapshot.data![1];
              List<List<int>> tmpResumeSubjects = [];
              final sharedResumeSubjects =
                  prefs.getString("resumeSubjects") ?? "[[], [], []]";
              for (var resumeSubject in jsonDecode(sharedResumeSubjects)) {
                tmpResumeSubjects.add(List<int>.from(resumeSubject));
              }
              resumeSubjects = tmpResumeSubjects;

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
                                    "${user!['username']}!",
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
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Starte eine Lektion über die  ",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Column(
                                          children: [
                                            const Icon(Icons.search),
                                            Text(
                                              "Suche",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
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
                          ListView.builder(
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
                                              .elementAt(
                                                  resumeSubjects[index]
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
                                                  .elementAt(5))),
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ]),
                  ),
                ),
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          }),
    );
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
