import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/personal_library.dart';
import 'package:tech_knowl_edge_connect/components/search_textfield.dart';
import 'package:tech_knowl_edge_connect/components/subject_tile.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
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

  void navigateToSubjectPage(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectOverviewPage(subject: subjects[index]),
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
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: subjects.length,
                    itemBuilder: (BuildContext context, int subjectIndex) {
                      return SubjectTile(
                        onTap: () => navigateToSubjectPage(subjectIndex),
                        subject: subjects[subjectIndex],
                      );
                    },
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
