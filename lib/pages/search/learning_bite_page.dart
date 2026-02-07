import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/answer_field.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';
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
  late final TextEditingController textFieldController;
  late List<TextEditingController> answersControllers = [];

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    pageController = PageController();
    textFieldController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    controller.dispose();
    textFieldController.dispose();
    for (final TextEditingController answersController in answersControllers) {
      answersController.dispose();
    }
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
  List<String> correctAnswers = [];
  List<String> question = [];
  IterableZip<String> answers = IterableZip([]);
  bool initFreeTextCloze = true;
  bool allCorrect = false;
  bool showAnswer = false;

  Task indexCard = Task(
      id: "index_card",
      type: TaskType.indexCard,
      question: "Gewusst?",
      correctAnswer: "Ja",
      answers: ["Nein", "Ja"]);

  @override
  Widget build(BuildContext context) {
    List<Widget> data = widget.learningBite.content
        .map((c) => Text(c, style: Theme.of(context).textTheme.bodyLarge))
        .toList();
    List<Task> tasks = widget.tasks;
    int maxDataNum = data.length;
    int maxTaskNum = tasks.length;
    int maxPageNum = maxDataNum + maxTaskNum;
    int currentTask = currentPage - maxDataNum;
    if (0 <= currentTask && currentTask < maxTaskNum) {
      correctAnswers = tasks[currentTask].correctAnswer.split('{}');
      question = tasks[currentTask].question.split(RegExp(r'\{\s*\}'));
      answers = IterableZip([question, correctAnswers]);
      answersControllers = initFreeTextCloze
          ? List.generate(
              correctAnswers.length, (index) => TextEditingController())
          : answersControllers;
    }
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
                return currentPageIndex == maxPageNum
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                            child: Column(
                          children: [
                            const SizedBox(height: 200),
                            points / maxTaskNum >= 0.5
                                ? points / maxTaskNum >= 0.9
                                    ? const Text("Super gemacht!",
                                        style: TextStyle(fontSize: 22))
                                    : const Text("Gut gemacht!",
                                        style: TextStyle(fontSize: 22))
                                : const Text("Übe weiter!",
                                    style: TextStyle(fontSize: 22)),
                            const SizedBox(height: 50),
                            Text(
                                "Du hast $points von $maxTaskNum Punkten erhalten."),
                          ],
                        )),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Column(
                            children: currentPageIndex < maxDataNum
                                ? [
                                    const SizedBox(height: 30),
                                    data[currentPageIndex]
                                  ]
                                : [
                                    const SizedBox(height: 30),
                                    taskContent(
                                        tasks, currentPageIndex - maxDataNum)
                                  ],
                          ),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
        child: currentPage < maxDataNum || currentPage == maxPageNum
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
            : taskBottom(tasks, currentTask, maxPageNum, maxTaskNum, context),
      ),
    );
  }

  Widget taskContent(List<Task> tasks, int currentTask) {
    switch (tasks[currentTask].type) {
      case TaskType.singleChoice:
        return Text(tasks[currentTask].question);
      case TaskType.indexCard:
        return showAnswer
            ? Column(
                children: [
                  Text(tasks[currentTask].correctAnswer),
                  const SizedBox(height: 200),
                  Text(indexCard.question)
                ],
              )
            : Text(tasks[currentTask].question);
      case TaskType.singleChoiceCloze:
        return Text.rich(
          TextSpan(children: <InlineSpan>[
            for (final pairs in answers) ...[
              TextSpan(
                text: pairs.first,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: AnswerField(
                  setAllCorrect: () => setAllCorrect(
                      tasks[currentTask].correctAnswer.split('{}')),
                  controller: textFieldController,
                  answer: pairs.last,
                  enabled: false,
                ),
              )
            ],
            if (question.length > correctAnswers.length)
              TextSpan(
                text: question.last,
              ),
          ], style: const TextStyle(fontSize: 14)),
        );
      case TaskType.freeTextFieldCloze:
        return Text.rich(
          TextSpan(children: <InlineSpan>[
            for (var correctAnswersIndex = 0;
                correctAnswersIndex < answers.length;
                correctAnswersIndex++) ...[
              TextSpan(
                text: answers.elementAt(correctAnswersIndex).first,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: AnswerField(
                    setAllCorrect: () => setAllCorrect(correctAnswers),
                    controller: answersControllers[correctAnswersIndex],
                    answer: answers.elementAt(correctAnswersIndex).last,
                    enabled: true,
                    textInputAction: correctAnswersIndex < answers.length - 1
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofocus: correctAnswersIndex == 0 ? true : false),
              )
            ],
            if (question.length > correctAnswers.length)
              TextSpan(
                text: question.last,
              ),
          ], style: const TextStyle(fontSize: 14)),
        );
      default:
        return Text(tasks[currentTask].question);
    }
  }

  Widget taskBottom(List<Task> tasks, int currentTask, int maxPageNum,
      int maxTaskNum, BuildContext context) {
    switch (tasks[currentTask].type) {
      case TaskType.indexCard:
        return showAnswer
            ? Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                children: [
                    for (var answerIndex = 0;
                        answerIndex < indexCard.answers.length;
                        answerIndex++)
                      LessonButton(
                          onTap: () async {
                            bool correct = false;
                            setState(() {
                              correct = indexCard.answers[answerIndex] ==
                                  indexCard.correctAnswer;
                            });
                            if (currentPage < maxPageNum) {
                              setState(() {
                                showAnswer = false;
                                currentPage++;
                                if (correct) {
                                  points++;
                                }
                              });
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          text: indexCard.answers[answerIndex],
                          color: indexCard.answers[answerIndex] ==
                                  indexCard.correctAnswer
                              ? Colors.green
                              : Colors.red),
                  ])
            : Wrap(direction: Axis.horizontal, children: [
                LessonButton(
                  onTap: () async {
                    setState(() {
                      showAnswer = true;
                    });
                  },
                  text: "Prüfen",
                )
              ]);
      case TaskType.singleChoiceCloze:
        return Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            children: [
              for (var answerIndex = 0;
                  answerIndex < tasks[currentTask].answers.length;
                  answerIndex++)
                LessonButton(
                    onTap: () async {
                      bool correct = false;
                      setState(() {
                        answeredIndex = answerIndex;
                        _isAnswered[currentTask] = true;
                        correct = tasks[currentTask].answers[answerIndex] ==
                            tasks[currentTask].correctAnswer;
                        _isCorrect[currentTask] = correct;
                        if (correct) {
                          textFieldController.text =
                              tasks[currentTask].correctAnswer;
                        }
                      });
                      if (currentPage < maxPageNum) {
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() {
                          _isAnswered = List.generate(maxTaskNum, (i) => false);
                          textFieldController.text = "";
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
                    text: tasks[currentTask].answers[answerIndex],
                    color: answerIndex == answeredIndex &&
                            _isAnswered[currentTask]
                        ? (_isCorrect[currentTask] ? Colors.green : Colors.red)
                        : Theme.of(context).colorScheme.secondary),
            ]);
      case TaskType.singleChoice:
        return Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            children: [
              for (var answerIndex = 0;
                  answerIndex < tasks[currentTask].answers.length;
                  answerIndex++)
                LessonButton(
                    onTap: () async {
                      bool correct = false;
                      setState(() {
                        answeredIndex = answerIndex;
                        _isAnswered[currentTask] = true;
                        correct = tasks[currentTask].answers[answerIndex] ==
                            tasks[currentTask].correctAnswer;
                        _isCorrect[currentTask] = correct;
                      });
                      if (currentPage < maxPageNum) {
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() {
                          _isAnswered = List.generate(maxTaskNum, (i) => false);
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
                    text: tasks[currentTask].answers[answerIndex],
                    color: answerIndex == answeredIndex &&
                            _isAnswered[currentTask]
                        ? (_isCorrect[currentTask] ? Colors.green : Colors.red)
                        : Theme.of(context).colorScheme.secondary),
            ]);
      case TaskType.multipleChoice:
        return Text(tasks[currentTask].question);
      case TaskType.freeTextFieldCloze:
        return allCorrect
            ? Wrap(direction: Axis.horizontal, children: [
                LessonButton(
                  onTap: () async {
                    if (currentPage < maxPageNum) {
                      if (allCorrect && pageController.hasClients) {
                        setState(() {
                          currentPage++;
                          if (firstTry) {
                            points++;
                          }
                          firstTry = true;
                          allCorrect = false;
                          initFreeTextCloze = true;
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
                  text: "Weiter",
                )
              ])
            : const SizedBox.shrink();
    }
  }

  Iterable<T> zip<T>(Iterable<T> a, Iterable<T> b) sync* {
    final ita = a.iterator;
    final itb = b.iterator;
    bool hasa, hasb;
    while ((hasa = ita.moveNext()) | (hasb = itb.moveNext())) {
      if (hasa) yield ita.current;
      if (hasb) yield itb.current;
    }
  }

  void setAllCorrect(List<String> correctAnswers) {
    initFreeTextCloze = false;
    for (var correctAnswerIndex = 0;
        correctAnswerIndex < correctAnswers.length;
        correctAnswerIndex++) {
      if (correctAnswers[correctAnswerIndex].toLowerCase() !=
          answersControllers[correctAnswerIndex].text.toLowerCase()) {
        setState(() {
          allCorrect = false;
        });
        return;
      }
    }
    setState(() {
      allCorrect = true;
    });
  }
}
