import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/search_textfield.dart';
import 'package:tech_knowl_edge_connect/components/subject_tile.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/pages/search/subject_overview_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final subjectController = TextEditingController();

  List<Subject> subjects = [
    Subject(
      name: "Mathematik",
      color: Colors.blue.shade800,
      iconData: FontAwesomeIcons.calculator,
    ),
    Subject(
      name: "Informatik",
      color: Colors.blueGrey.shade500,
      iconData: FontAwesomeIcons.desktop,
    ),
    Subject(
      name: "Biologie",
      color: Colors.green.shade600,
      iconData: FontAwesomeIcons.tree,
    ),
  ];

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Center(
          child: SearchTextField(
            controller: subjectController,
            hintText: 'Fächer, Themen, Aufgaben...',
          ),
        ),
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
                    "Naturwissenschaften",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SubjectTile(
                        onTap: () => navigateToSubjectPage(index),
                        subject: subjects[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
