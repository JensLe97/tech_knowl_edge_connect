import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_knowl_edge_connect/components/blocked_field.dart';
import 'package:tech_knowl_edge_connect/components/chat_bubble.dart';
import 'package:tech_knowl_edge_connect/components/message_textfield.dart';
import 'package:tech_knowl_edge_connect/components/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/env/env.dart';
import 'package:tech_knowl_edge_connect/models/report_reason.dart';
import 'package:tech_knowl_edge_connect/pages/chats/upload_image_page.dart';
import 'package:tech_knowl_edge_connect/services/chat_service.dart';
import 'package:tech_knowl_edge_connect/services/user_service.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String receiverUsername;
  final String receiverUid;
  const ChatPage(
      {super.key, required this.receiverUsername, required this.receiverUid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String prompt = _messageController.text;
      await _chatService.sendMessage(
          widget.receiverUid, _messageController.text);
      _messageController.clear();
      if (widget.receiverUid == "aitech") {
        String response = await askOpenAi(allMessages, prompt);
        await _chatService.sendMessage(_firebaseAuth.currentUser!.uid, response,
            fromAI: true);
      }
    }
  }

  void sendImage(ImageSource imageSource) async {
    final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

    ImagePicker imagePicker = ImagePicker();
    // await Permission.photos.request();

    // var permissionStatus = await Permission.photos.status;

    if (true) {
      XFile? image = await imagePicker.pickImage(source: imageSource);

      if (image != null) {
        String extension = image.name.split(".").last;
        String fileName = const Uuid().v4();

        Reference upload =
            firebaseStorage.ref().child('images').child("$fileName.$extension");
        extension = extension == "jpg" ? "jpeg" : extension;
        TaskSnapshot taskSnapshot = await upload.putData(
          await image.readAsBytes(),
          SettableMetadata(contentType: 'image/$extension'),
        );

        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await _chatService.sendMessage(widget.receiverUid, imageUrl,
            type: "image");
      }
    }
  }

  void toggleBlockUser() {
    if (blockedUsers.contains(widget.receiverUid)) {
      _userService.unblockUser(widget.receiverUid);
      setState(() {
        blockedUsers.remove(widget.receiverUid);
      });
    } else {
      _userService.blockUser(widget.receiverUid);
      setState(() {
        blockedUsers.add(widget.receiverUid);
      });
    }
  }

  void reportUser(ReportReason reason) {
    _userService.reportUser(widget.receiverUid, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.receiverUsername),
              ],
            ),
            centerTitle: true,
            actions: [
              widget.receiverUid == "aitech"
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          enableDrag: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) => SafeArea(
                            child: UserBottomSheet(
                                toggleBlockUser: toggleBlockUser,
                                report: reportUser,
                                isBlocked:
                                    blockedUsers.contains(widget.receiverUid)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.more_horiz)),
            ]),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildMessageList()),
              ),
              const SizedBox(height: 2),
              blockedUsers.contains(widget.receiverUid)
                  ? BlockedField(
                      toggleBlockUser: toggleBlockUser,
                      isBlocked: true,
                    )
                  : _buildMessageInput(),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.receiverUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
        } else if (snapshot.hasData) {
          ListView messageList = ListView(
              reverse: true,
              shrinkWrap: true,
              children: snapshot.data!.docs.reversed
                  .map((document) => _buildMessageItem(document))
                  .toList());
          return TextFieldTapRegion(child: messageList);
        } else {
          return const Text("Noch keine Nachrichten vorhanden.");
        }
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = data['senderId'] == _firebaseAuth.currentUser!.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: data['senderId'] == _firebaseAuth.currentUser!.uid
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: data['senderId'] == _firebaseAuth.currentUser!.uid
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            ChatBubble(
              uid: data['senderId'],
              message: data['message'],
              type: data['type'],
              isMe: data['senderId'] == _firebaseAuth.currentUser!.uid,
              time: data['timestamp'],
              userService: _userService,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          widget.receiverUid == "aitech"
              ? const SizedBox()
              : IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        enableDrag: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext context) => SafeArea(
                              child: UploadImagePage(
                                sendImage: sendImage,
                              ),
                            ));
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 40,
                  ),
                  color: Theme.of(context).colorScheme.inversePrimary),
          Expanded(
            child: MessageTextField(
              controller: _messageController,
              hintText: 'Nachricht schreiben...',
              obscureText: false,
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                size: 40,
              ),
              color: Theme.of(context).colorScheme.inversePrimary),
        ],
      ),
    );
  }

  Future<String> askOpenAi(
    List<OpenAIChatCompletionChoiceMessageModel> thisMessages,
    String prompt,
  ) async {
    OpenAI.apiKey = Env.openaiApiKey;
    List<OpenAIChatCompletionChoiceMessageModel> newMessages = [];
    for (var messageElement in thisMessages) {
      newMessages.add(messageElement);
    }

    newMessages.add(OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
    ], role: OpenAIChatMessageRole.user));

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: newMessages,
      n: 1,
      maxTokens: 2000,
      temperature: 0.7,
    );
    String response = chatCompletion.choices.first.message.content!.first.text!;
    newMessages.add(OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(response)
    ], role: OpenAIChatMessageRole.assistant));
    allMessages = newMessages;

    return response;
  }
}
