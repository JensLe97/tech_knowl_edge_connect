import 'package:flutter/material.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:pdfrx/pdfrx.dart';
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
    if (type.toLowerCase() == 'pdf') {
      return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: PdfViewer.uri(Uri.parse(url)),
      );
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
        .contains(type.toLowerCase())) {
      // Use EasyImageViewer in a dialog for images
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showImageViewer(
          context,
          NetworkImage(url),
          swipeDismissible: true,
          doubleTapZoomable: true,
          onViewerDismissed: () {},
        );
        Navigator.of(context).pop();
      });
      return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (['mp4', 'mov', 'webm', 'mkv'].contains(type.toLowerCase())) {
      return _VideoPreview(url: url, name: name);
    } else {
      // Fallback: just show the URL
      return Scaffold(
        appBar: AppBar(title: Text(name)),
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _initialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
