import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/personal_library.dart';
import 'package:tech_knowl_edge_connect/components/search_textfield.dart';
import 'package:tech_knowl_edge_connect/components/subject_tile.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/subject_dialog.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/pages/search/ai_search_page.dart';
import 'package:tech_knowl_edge_connect/pages/search/subject_overview_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final subjectController = TextEditingController();
  final searchController = TextEditingController();
  final ContentService _contentService = ContentService();

  void navigateToSubjectPage(Subject subject) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectOverviewPage(subject: subject),
        )).then((value) => {subjectController.clear()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Center(
            child: SearchTextField(
          controller: searchController,
          hintText: "Was möchtest du wissen?",
          onTap: () => {
            showSearch(context: context, delegate: AiSearchDelegate())
                .then((value) => FocusManager.instance.primaryFocus?.unfocus())
          },
        )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    "Meine Fächer",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    children: [
                      StreamBuilder<List<Subject>>(
                        stream: _contentService.getSubjects(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Fehler: ${snapshot.error}"),
                            ));
                          }
                          final subjects = snapshot.data ?? [];
                          if (subjects.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: subjects.length,
                            itemBuilder:
                                (BuildContext context, int subjectIndex) {
                              final subject = subjects[subjectIndex];
                              return SubjectTile(
                                onTap: () => navigateToSubjectPage(subject),
                                subject: subject,
                              );
                            },
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const SubjectDialog(),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(5),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Neues Fach erstellen",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    "Meine Lerninhalte",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const PersonalLibrary(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
