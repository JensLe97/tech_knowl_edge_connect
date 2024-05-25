import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_knowl_edge_connect/components/caption_textfield.dart';
import 'package:tech_knowl_edge_connect/components/login_button.dart';
import 'package:video_player/video_player.dart';

class UploadPostPage extends StatefulWidget {
  final Future<XFile?> Function(ImageSource, String) selectPostContent;
  final void Function(XFile?, String, String) uploadPostContent;

  const UploadPostPage(
      {Key? key,
      required this.selectPostContent,
      required this.uploadPostContent})
      : super(key: key);

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final _captionController = TextEditingController();
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _captionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  String type = "";
  XFile? postContent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: "Foto aufnehmen",
                  onPressed: () async {
                    setState(() {
                      type = "image";
                      postContent = null;
                    });
                    await widget
                        .selectPostContent(ImageSource.camera, type)
                        .then((value) {
                      setState(() {
                        postContent = value;
                      });
                    });
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
                IconButton(
                  tooltip: "Foto aus Galerie auswählen",
                  onPressed: () async {
                    setState(() {
                      type = "image";
                      postContent = null;
                    });
                    await widget
                        .selectPostContent(ImageSource.gallery, type)
                        .then((value) {
                      setState(() {
                        postContent = value;
                      });
                    });
                  },
                  icon: const Icon(Icons.image),
                ),
                IconButton(
                  tooltip: "Video aufnehmen",
                  onPressed: () async {
                    setState(() {
                      type = "video";
                      postContent = null;
                    });
                    await widget
                        .selectPostContent(ImageSource.camera, type)
                        .then((value) {
                      setState(() {
                        if (value != null) {
                          postContent = value;
                          loadVideoPlayer(File(postContent!.path));
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.video_call),
                ),
                IconButton(
                  tooltip: "Video aus Galerie auswählen",
                  onPressed: () async {
                    setState(() {
                      type = "video";
                      postContent = null;
                    });
                    await widget
                        .selectPostContent(ImageSource.gallery, type)
                        .then((value) {
                      setState(() {
                        if (value != null) {
                          postContent = value;
                          loadVideoPlayer(File(postContent!.path));
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.video_file),
                ),
              ],
            ),
            const SizedBox(height: 10),
            postContent != null
                ? type == "image"
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: kIsWeb
                            ? Image.network(
                                postContent!.path,
                                height: 500,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(postContent!.path),
                                height: 500,
                                fit: BoxFit.cover,
                              ),
                      )
                    : _videoPlayerController != null
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: SizedBox(
                              height: 500,
                              child: VideoPlayer(_videoPlayerController!),
                            ),
                          )
                        : const SizedBox(
                            height: 500,
                          )
                : const SizedBox(
                    height: 500,
                  ),
            const SizedBox(height: 20),
            CaptionTextField(
              controller: _captionController,
              hintText: 'Beschreibung',
            ),
            const SizedBox(height: 20),
            LoginButton(onTap: uploadIdeaPost, text: "Posten"),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  loadVideoPlayer(File file) {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }

    if (kIsWeb) {
      Uri uri = Uri.parse(postContent!.path);
      _videoPlayerController = VideoPlayerController.networkUrl(uri)
        ..initialize().then((_) {
          _videoPlayerController!.setVolume(0);
          _videoPlayerController!.play();
          _videoPlayerController!.setLooping(true);
          setState(() {});
        });
    } else {
      _videoPlayerController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          _videoPlayerController!.setVolume(0);
          _videoPlayerController!.play();
          _videoPlayerController!.setLooping(true);
          setState(() {});
        });
    }
  }

  uploadIdeaPost() {
    if (postContent == null) {
      showErrorMessage("Bitte ein Bild oder Video auswählen.");
    } else if (_captionController.text.isEmpty) {
      showErrorMessage("Bitte eine Beschreibung hinzufügen.");
    } else {
      widget.uploadPostContent(postContent, _captionController.text, type);
      Navigator.pop(context);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
