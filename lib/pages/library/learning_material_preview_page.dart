import 'package:flutter/material.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';
import 'package:video_player/video_player.dart';

class LearningMaterialPreviewPage extends StatelessWidget {
  final String url;
  final String type;
  final String name;

  const LearningMaterialPreviewPage({
    Key? key,
    required this.url,
    required this.type,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (LearningMaterialType.pdfTypes.contains(type.toLowerCase())) {
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: true,
        ),
        body: PdfViewer.uri(Uri.parse(url)),
      );
    } else if (LearningMaterialType.imageTypes.contains(type.toLowerCase())) {
      // Use EasyImageViewer in a dialog for images
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showImageViewer(
          context,
          NetworkImage(url),
          swipeDismissible: true,
          doubleTapZoomable: true,
          onViewerDismissed: () {
            Navigator.of(context).pop();
          },
        );
      });
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (LearningMaterialType.videoTypes.contains(type.toLowerCase())) {
      return _VideoPreview(url: url, name: name);
    } else {
      // Fallback: just show the URL
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Dateityp wird nicht unterstützt.\n$url'),
        ),
      );
    }
  }
}

class _VideoPreview extends StatefulWidget {
  final String url;
  final String name;
  const _VideoPreview({Key? key, required this.url, required this.name})
      : super(key: key);

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showPlayPause = false;
  late VoidCallback _hideOverlayCallback;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setVolume(0);
        _controller.setLooping(true);
        _controller.play();
      });
    _hideOverlayCallback = () {
      if (mounted) {
        setState(() {
          _showPlayPause = false;
        });
      }
    };
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showPlayPause = true;
    });
    Future.delayed(const Duration(seconds: 2), _hideOverlayCallback);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: Center(
        child: _initialized
            ? GestureDetector(
                onTap: _togglePlayPause,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (_showPlayPause)
                      AnimatedOpacity(
                        opacity: _showPlayPause ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
