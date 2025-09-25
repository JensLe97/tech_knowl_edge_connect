import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_knowl_edge_connect/data/index.dart'
    show likedLearningMaterials, blockedUsers;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/idea_reaction_button.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/models/learning_material.dart';
import 'package:tech_knowl_edge_connect/pages/feed/post_profile_page.dart';
import 'package:tech_knowl_edge_connect/pages/library/learning_material_preview_page.dart';
import 'package:tech_knowl_edge_connect/services/learning_material_service.dart';
import 'package:video_player/video_player.dart';
import 'package:tech_knowl_edge_connect/models/report_reason.dart';
import 'package:tech_knowl_edge_connect/services/user_service.dart';

class LearningMaterialReelItem extends StatefulWidget {
  final LearningMaterial material;

  const LearningMaterialReelItem({
    super.key,
    required this.material,
  });

  @override
  State<LearningMaterialReelItem> createState() =>
      _LearningMaterialReelItemState();
}

class _LearningMaterialReelItemState extends State<LearningMaterialReelItem> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final LearningMaterialService _learningMaterialsService =
      LearningMaterialService();

  toggleLike() async {
    if (likedLearningMaterials.contains(widget.material.id)) {
      await _learningMaterialsService.unlikeLearningMaterial(
          _firebaseAuth.currentUser!.uid, widget.material.id);
      likedLearningMaterials.remove(widget.material.id);
    } else {
      await _learningMaterialsService.likeLearningMaterial(
          _firebaseAuth.currentUser!.uid, widget.material.id);
      likedLearningMaterials.add(widget.material.id);
    }
  }

  void toggleBlockUser() async {
    final userId = widget.material.userId;
    if (blockedUsers.contains(userId)) {
      await _userService.unblockUser(userId);
      blockedUsers.remove(userId);
    } else {
      await _userService.blockUser(userId);
      blockedUsers.add(userId);
    }
  }

  void reportContent(ReportReason reason) {
    _userService.reportContent(
      widget.material.id,
      widget.material.userId,
      widget.material.type,
      true,
      reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = widget.material;
    final overlayColor = Theme.of(context).colorScheme.onSecondary;
    final isPdf =
        LearningMaterialType.pdfTypes.contains(material.type.toLowerCase());
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LearningMaterialPreviewPage(
                  url: material.url,
                  type: material.type,
                  name: material.name,
                ),
              ),
            );
          },
          child: Container(
            child: LearningMaterialType.imageTypes
                    .contains(material.type.toLowerCase())
                ? Image.network(
                    material.url,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : LearningMaterialType.videoTypes
                        .contains(material.type.toLowerCase())
                    ? VideoPlayerWidget(url: material.url)
                    : isPdf
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  LearningMaterialType.getIconForType(
                                      material.type),
                                  size: 100,
                                  color: overlayColor,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  material.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: overlayColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: Text(
                              'Vorschau für diesen Dateityp nicht verfügbar.\nTippen zum Öffnen.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            alignment: const Alignment(-1, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostProfilePage(
                        username: material.userName,
                        uid: material.userId,
                      ),
                    ));
                  },
                  child: Text(
                    '@${material.userName}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPdf ? overlayColor : Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(
                      text: material.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPdf ? overlayColor : Colors.white),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            alignment: const Alignment(1, 1),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              IdeaReactionButton(
                onTap: toggleLike,
                icon: Icons.favorite,
                number: material.numberOfLikes,
                isLiked: likedLearningMaterials.contains(material.id),
                color: isPdf ? overlayColor : Colors.white,
              ),
              IdeaReactionButton(
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    useSafeArea: true,
                    enableDrag: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) => SafeArea(
                      child: UserBottomSheet(
                        toggleBlockUser: toggleBlockUser,
                        report: reportContent,
                        isBlocked: blockedUsers.contains(material.userId),
                        isContent: true,
                      ),
                    ),
                  );
                },
                icon: Icons.more_horiz,
                hasCounter: false,
                color: isPdf ? overlayColor : Colors.white,
              ),
            ]),
          ),
        )
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.setVolume(0.0);
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? IgnorePointer(child: VideoPlayer(_controller))
        : const Center(child: CircularProgressIndicator());
  }
}
