import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/resume_item.dart';
import 'package:tech_knowl_edge_connect/pages/chats/chat_page.dart';
import 'package:tech_knowl_edge_connect/providers/user_provider.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final ContentService _contentService = ContentService();

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserDetails() {
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Consume UserProvider data
    final userState = UserState.of(context);
    final userData = userState?.userData;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Center(
          child: Text('Home'),
        ),
      ),
      body: Builder(builder: (context) {
        if (userData == null) {
          // If no data, it might be loading or no user
          // Since UserProvider handles the stream, if userData is null it's effectively waiting or empty
          return const Center(child: CircularProgressIndicator());
        }

        // Parse new Resume Progress structure
        // Expected: Map<String, dynamic> resumeProgress = { 'subjectId': { 'learningBiteId': ..., ... } }
        final Map<String, dynamic> resumeProgress =
            userData['resumeProgress'] as Map<String, dynamic>? ?? {};

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
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${userData['username']}!",
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(24)),
                          child: const Icon(Icons.person),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    resumeProgress.isEmpty
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
                        itemCount: resumeProgress.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String subjectId =
                              resumeProgress.keys.elementAt(index);
                          final Map<String, dynamic> data =
                              resumeProgress[subjectId] as Map<String, dynamic>;

                          return ResumeItem(
                            subjectId: subjectId,
                            data: data,
                            contentService: _contentService,
                          );
                        },
                      ),
                    ),
                  ]),
            ),
          ),
        );
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
        child: const FaIcon(FontAwesomeIcons.robot),
      ),
    );
  }
}
