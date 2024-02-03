import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';

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

  late List<bool> _isAnswered =
      List.generate(widget.tasks.length, (index) => false);
  late final List<bool> _isCorrect =
      List.generate(widget.tasks.length, (index) => false);

  int currentPage = 0;
  bool onLastPage = false;
  int answeredIndex = 0;

  int points = 0;
  bool firstTry = true;

  @override
  Widget build(BuildContext context) {
    int maxTextNum = widget.learningBite.data.length;
    int maxTaskNum = widget.learningBite.tasks != null
        ? widget.learningBite.tasks!.length
        : 0;
    int maxPageNum = maxTextNum + maxTaskNum;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: 100,
        flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
                top: 40, bottom: 10, start: 25, end: 25),
            centerTitle: true,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(widget.learningBite.name),
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: currentPage.toDouble() / (maxTextNum + maxTaskNum),
                  ),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.secondary,
                    minHeight: 12,
                  ),
                ),
              ],
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                itemCount: maxPageNum + 1,
                itemBuilder: (context, index) {
                  return index == maxPageNum
                      ? Center(
                          child: Column(
                          children: [
                            const SizedBox(
                              height: 200,
                            ),
                            points / maxTaskNum >= 0.5
                                ? points / maxTaskNum >= 0.9
                                    ? const Text("Super gemacht!",
                                        style: TextStyle(fontSize: 22))
                                    : const Text("Gut gemacht!",
                                        style: TextStyle(fontSize: 22))
                                : const Text("Übe weiter!",
                                    style: TextStyle(fontSize: 22)),
                            const SizedBox(
                              height: 50,
                            ),
                            Text(
                                "Du hast $points von $maxTaskNum Punkten erhalten."),
                          ],
                        ))
                      : Center(
                          child: Column(
                            children: index < maxTextNum
                                ? [
                                    const SizedBox(height: 30),
                                    widget.learningBite.data[index]
                                  ]
                                : [
                                    const SizedBox(height: 30),
                                    Text(widget.learningBite
                                        .tasks![index - maxTextNum].question)
                                  ],
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
        child: currentPage < maxTextNum || currentPage == maxPageNum
            ? Wrap(direction: Axis.horizontal, children: [
                LessonButton(
                  onTap: () async {
                    if (currentPage < maxPageNum) {
                      setState(() {
                        currentPage++;
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
                  },
                  text: currentPage == maxPageNum
                      ? "Lektion abschließen"
                      : "Weiter",
                )
              ])
            : Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                children: [
                    for (var answerIndex = 0;
                        answerIndex <
                            widget.learningBite.tasks![currentPage - maxTextNum]
                                .answers.length;
                        answerIndex++)
                      LessonButton(
                          onTap: () async {
                            bool correct = false;
                            setState(() {
                              answeredIndex = answerIndex;
                              _isAnswered[currentPage - maxTextNum] = true;
                              correct = widget
                                      .learningBite
                                      .tasks![currentPage - maxTextNum]
                                      .answers[answerIndex] ==
                                  widget
                                      .learningBite
                                      .tasks![currentPage - maxTextNum]
                                      .correctAnswer;
                              _isCorrect[currentPage - maxTextNum] = correct;
                            });
                            if (currentPage < maxPageNum) {
                              await Future.delayed(const Duration(seconds: 1));
                              setState(() {
                                _isAnswered =
                                    List.generate(maxTaskNum, (i) => false);
                              });

                              if (correct && pageController.hasClients) {
                                setState(() {
                                  currentPage++;
                                  if (firstTry) {
                                    points++;
                                  }
                                  firstTry = true;
                                });
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                setState(() {
                                  firstTry = false;
                                });
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          text: widget
                              .learningBite
                              .tasks![currentPage - maxTextNum]
                              .answers[answerIndex],
                          color: answerIndex == answeredIndex &&
                                  _isAnswered[currentPage - maxTextNum]
                              ? (_isCorrect[currentPage - maxTextNum]
                                  ? Colors.green
                                  : Colors.red)
                              : Theme.of(context).colorScheme.primary),
                  ]),
      ),
    );
  }
}
