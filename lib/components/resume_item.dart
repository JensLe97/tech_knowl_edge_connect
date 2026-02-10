import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/resume_tile.dart';
import 'package:tech_knowl_edge_connect/models/category.dart';
import 'package:tech_knowl_edge_connect/models/concept.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/models/topic.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';
import 'package:tech_knowl_edge_connect/services/user_service.dart';

class ResumeItem extends StatelessWidget {
  final String subjectId;
  final Map<String, dynamic> data;
  final ContentService contentService;
  final UserService userService = UserService();

  ResumeItem({
    super.key,
    required this.subjectId,
    required this.data,
    required this.contentService,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryId = data['categoryId'];
    final String topicId = data['topicId'];
    final String unitId = data['unitId'];
    final String conceptId = data['conceptId'];
    final String learningBiteId = data['learningBiteId'];

    return FutureBuilder(
      future: Future.wait([
        contentService.getSubject(subjectId),
        contentService.getCategory(subjectId, categoryId),
        contentService.getTopic(subjectId, categoryId, topicId),
        contentService.getUnit(subjectId, categoryId, topicId, unitId),
        contentService.getConcept(
            subjectId, categoryId, topicId, unitId, conceptId),
        contentService.getLearningBite(
            subjectId, categoryId, topicId, unitId, conceptId, learningBiteId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final results = snapshot.data as List<dynamic>;
        final Subject subject = results[0] as Subject;
        final Category category = results[1] as Category;
        final Topic topic = results[2] as Topic;
        final Unit unit = results[3] as Unit;
        final Concept concept = results[4] as Concept;
        final LearningBite learningBite = results[5] as LearningBite;

        final String path =
            "${category.name} > ${topic.name} > ${unit.name} > ${concept.name}";

        return ResumeTile(
          path: path,
          subject: subject,
          learningBite: learningBite,
          onTap: () async {
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            try {
              final tasks = await contentService.getTasks(subjectId, categoryId,
                  topicId, unitId, conceptId, learningBiteId);

              if (context.mounted) {
                Navigator.pop(context); // Hide loading
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LearningBitePage(
                            learningBite: learningBite,
                            tasks: tasks,
                          )),
                );

                if (result == true) {
                  await userService.markLearningBiteComplete(learningBiteId);

                  // Try to find next learning bite in this concept
                  final lbStream = contentService.getLearningBites(
                      subjectId, categoryId, topicId, unitId, conceptId);
                  final allLBs = await lbStream.first;
                  final currentIndex =
                      allLBs.indexWhere((lb) => lb.id == learningBiteId);

                  if (currentIndex != -1 && currentIndex < allLBs.length - 1) {
                    final nextLB = allLBs[currentIndex + 1];
                    await userService.updateResumeStatus(subjectId, nextLB.id,
                        categoryId, topicId, unitId, conceptId);
                  } else {
                    await userService.removeResumeStatus(subjectId);
                  }
                }
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            }
          },
        );
      },
    );
  }
}
