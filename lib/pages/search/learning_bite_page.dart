import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/learning/free_text_field_cloze_task.dart';
import 'package:tech_knowl_edge_connect/components/learning/index_card_task.dart';
import 'package:tech_knowl_edge_connect/components/learning/learning_content_page.dart';
import 'package:tech_knowl_edge_connect/components/learning/learning_summary_page.dart';
import 'package:tech_knowl_edge_connect/components/learning/multiple_choice_task.dart';
import 'package:tech_knowl_edge_connect/components/learning/single_choice_cloze_task.dart';
import 'package:tech_knowl_edge_connect/components/learning/single_choice_task.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

class LearningBitePage extends StatefulWidget {
  final LearningBite learningBite;
  final List<Task> tasks;

  const LearningBitePage({
    super.key,
    required this.learningBite,
    required this.tasks,
  });

  @override
  State<LearningBitePage> createState() => _LearningBitePageState();
}

class _LearningBitePageState extends State<LearningBitePage>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final PageController pageController;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    pageController = PageController();

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    controller.dispose();
    super.dispose();
  }

  int currentPage = 0;
  int points = 0;
  bool firstTry = true;

  void _nextPage(int maxPageNum) {
    if (currentPage < maxPageNum) {
      setState(() {
        currentPage++;
        firstTry = true;
      });
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      Navigator.pop(context, true);
    }
  }

  void _onResult(bool correct) {
    if (correct) {
      if (firstTry) {
        setState(() {
          points++;
        });
      }
    } else {
      setState(() {
        firstTry = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> data = widget.learningBite.content;
    List<Task> tasks = widget.tasks;
    int maxDataNum = data.length;
    int maxTaskNum = tasks.length;
    int maxPageNum = maxDataNum + maxTaskNum;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 10, right: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.learningBite.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(
                      begin: 0,
                      end: currentPage.toDouble() / maxPageNum,
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.secondary,
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemCount: maxPageNum + 1,
              itemBuilder: (context, currentPageIndex) {
                if (currentPageIndex == maxPageNum) {
                  return LearningSummaryPage(
                    points: points,
                    maxPoints: maxTaskNum,
                    onComplete: () => Navigator.pop(context, true),
                  );
                } else if (currentPageIndex < maxDataNum) {
                  return LearningContentPage(
                    text: data[currentPageIndex],
                    onNext: () => _nextPage(maxPageNum),
                  );
                } else {
                  return _buildTaskWidget(
                      tasks[currentPageIndex - maxDataNum], maxPageNum);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskWidget(Task task, int maxPageNum) {
    switch (task.type) {
      case TaskType.singleChoice:
        return SingleChoiceTask(
          task: task,
          onComplete: () => _nextPage(maxPageNum),
          onResult: _onResult,
        );
      case TaskType.indexCard:
        return IndexCardTask(
          task: task,
          onComplete: () => _nextPage(maxPageNum),
          onResult: _onResult,
        );
      case TaskType.singleChoiceCloze:
        return SingleChoiceClozeTask(
          task: task,
          onComplete: () => _nextPage(maxPageNum),
          onResult: _onResult,
        );
      case TaskType.freeTextFieldCloze:
        return FreeTextFieldClozeTask(
          task: task,
          onComplete: () => _nextPage(maxPageNum),
          onResult: _onResult,
        );
      case TaskType.multipleChoice:
        return MultipleChoiceTask(
          task: task,
          onComplete: () => _nextPage(maxPageNum),
          onResult: _onResult,
        );
    }
  }
}
