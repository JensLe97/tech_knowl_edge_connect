import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_knowl_edge_connect/components/idea_reaction_button.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/pages/ideas/upload_post_page.dart';
import 'package:tech_knowl_edge_connect/services/idea_posts_service.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class IdeaPostViewItem extends StatefulWidget {
  final String postId;
  final String username;
  final String caption;
  final int numberOfLikes;
  final int numberOfComments;
  final int numberOfShares;
  final String content;
  final String type;

  const IdeaPostViewItem(
      {super.key,
      required this.postId,
      required this.username,
      required this.caption,
      required this.numberOfLikes,
      required this.numberOfComments,
      required this.numberOfShares,
      required this.content,
      required this.type});

  @override
  State<IdeaPostViewItem> createState() => _IdeaPostViewItemState();
}

class _IdeaPostViewItemState extends State<IdeaPostViewItem> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final IdeaPostsService _ideaPostsService = IdeaPostsService();
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.type == "video") {
      Uri uri = Uri.parse(widget.content);
      _videoPlayerController = VideoPlayerController.networkUrl(uri)
        ..initialize().then((_) {
          setState(() {
            _videoPlayerController!.setVolume(0);
            _videoPlayerController!.play();
            _videoPlayerController!.setLooping(true);
          });
        });
    }
  }

  bool isLiked = false;

  Future<XFile?> selectPostContent(ImageSource imageSource, String type) async {
    ImagePicker imagePicker = ImagePicker();

    if (type == "video") {
      return await imagePicker.pickVideo(source: imageSource);
    }

    return await imagePicker.pickImage(source: imageSource);
  }

  void uploadPostContent(
      XFile? postContent, String caption, String type) async {
    if (postContent != null) {
      String extension = postContent.name.split(".").last;
      String fileName = const Uuid().v4();

      Reference upload = _firebaseStorage
          .ref()
          .child('${type}s')
          .child("$fileName.$extension");
      extension = extension == "jpg" ? "jpeg" : extension;
      TaskSnapshot taskSnapshot = await upload.putData(
        await postContent.readAsBytes(),
        SettableMetadata(contentType: '$type/$extension'),
      );

      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      await _ideaPostsService.uploadPost(imageUrl, caption, type: type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            widget.type == "image"
                ? Image.network(
                    widget.content,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: VideoPlayer(_videoPlayerController!),
                  ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                alignment: const Alignment(-1, 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${widget.username}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: widget.caption,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                alignment: const Alignment(1, -1),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SafeArea(
                        child: IconButton(
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
                                  builder: (BuildContext context) =>
                                      SafeArea(
                                        child: UploadPostPage(
                                          selectPostContent: selectPostContent,
                                          uploadPostContent: uploadPostContent,
                                        ),
                                      ));
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 40,
                            ),
                            color: Colors.white),
                      ),
                    ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                alignment: const Alignment(1, 1),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IdeaReactionButton(
                      onTap: toggleLike,
                      icon: Icons.favorite,
                      number: widget.numberOfLikes,
                      isLiked: likedPosts.contains(widget.postId)),
                  // IdeaReactionButton(
                  //     onTap: toggleLike,
                  //     icon: Icons.chat_bubble_outlined,
                  //     number: widget.numberOfComments),
                  // IdeaReactionButton(
                  //     onTap: toggleLike,
                  //     icon: Icons.send,
                  //     number: widget.numberOfShares),
                ]),
              ),
            )
          ],
        ));
  }

  toggleLike() async {
    if (likedPosts.contains(widget.postId)) {
      _ideaPostsService.unlikePost(widget.postId);
      setState(() {
        likedPosts.remove(widget.postId);
      });
    } else {
      _ideaPostsService.likePost(widget.postId);
      setState(() {
        likedPosts.add(widget.postId);
      });
    }
  }
}
