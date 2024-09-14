import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/env/env.dart';

class AiSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Was möchtest du wissen?';

  final answerController = TextEditingController();
  final imageData = "";
  var allMessages = [
    OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are a helpful assistant.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    )
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
              cursorColor: Theme.of(context).colorScheme.inversePrimary,
              selectionColor: Theme.of(context).colorScheme.secondary,
            ),
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            constraints: const BoxConstraints(minHeight: 36, maxHeight: 36),
            filled: true,
            hoverColor: Theme.of(context).colorScheme.onPrimary,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none)));
  }

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 20);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return query.isEmpty == true
        ? Container()
        : FutureBuilder(
            future: askOpenAi(allMessages, query, answerController),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: TextField(
                              readOnly: true,
                              maxLines: 11,
                              controller: answerController,
                              decoration: InputDecoration(
                                constraints: const BoxConstraints(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                filled: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 200),
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(child: Text("Fehler: ${snapshot.error}"));
                  } else {
                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: TextField(
                                readOnly: true,
                                maxLines: 11,
                                controller: answerController,
                                decoration: InputDecoration(
                                  constraints: const BoxConstraints(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fillColor:
                                      Theme.of(context).colorScheme.surface,
                                  filled: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 0),
                              child: Center(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                        base64Decode(snapshot.data!))),
                              ),
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    );
                  }
              }
            });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                readOnly: true,
                maxLines: 11,
                controller: answerController,
                decoration: InputDecoration(
                  constraints: const BoxConstraints(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.inversePrimary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Future<String> askOpenAi(
      List<OpenAIChatCompletionChoiceMessageModel> thisMessages,
      String prompt,
      answerController) async {
    OpenAI.apiKey = Env.openaiApiKey;
    List<OpenAIChatCompletionChoiceMessageModel> newMessages = [];
    for (var messageElement in thisMessages) {
      newMessages.add(messageElement);
    }
    if (answerController.text == "") {
      newMessages.add(OpenAIChatCompletionChoiceMessageModel(content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
      ], role: OpenAIChatMessageRole.user));
    } else {
      newMessages.add(OpenAIChatCompletionChoiceMessageModel(content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            answerController.text)
      ], role: OpenAIChatMessageRole.assistant));
      newMessages.add(OpenAIChatCompletionChoiceMessageModel(content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
      ], role: OpenAIChatMessageRole.user));
    }

    allMessages = newMessages;

    final chatStream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo",
      messages: newMessages,
      n: 1,
      maxTokens: 2000,
      temperature: 0.7,
    );
    answerController.clear();
    chatStream.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        answerController.text += content != null &&
                content.first != null &&
                content.first!.text != null
            ? content.first!.text!
            : "";
      },
      onDone: () {},
    );

    // The speech request.
    // File speechFile = await OpenAI.instance.audio.createSpeech(
    //   model: "tts-1",
    //   input: prompt,
    //   voice: "nova",
    //   responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
    //   outputFileName: "anas",
    // );

    // // The file result.
    // print(speechFile.path);

    // Printing the output to the console

    // Generate an image from a prompt.
    final image = await OpenAI.instance.image.create(
      model: "dall-e-2",
      prompt: prompt,
      n: 1,
      size: OpenAIImageSize.size1024,
      responseFormat: OpenAIImageResponseFormat.b64Json,
    );

    return image.data[0].b64Json!;
  }
}
