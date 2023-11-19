import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';

class VideoPage extends StatefulWidget {
  VideoSource? videoSource;
  VideoPage(this.videoSource, {super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.networkUrl(Uri.parse('http://192.168.31.250:1111/mnt/media_rw/64EA-D541/film/john4.mp4?cmd=file'))
    //   ..initialize().then((_) => {
    //   });
    //
    // _controller!.addListener(() {
    //   logger.d("Video playback video: ${_controller!.value}");
    //   if (_controller!.value.hasError) {
    //     // Handle video playback error
    //     logger.d("Video playback error: ${_controller!.value.errorDescription}");
    //   }
    // });
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant VideoPage oldWidget) {
    logger.d('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _controller?.dispose();
      _initializeController();
    }
  }

  // Initialize video controller
  void _initializeController() {
    VideoSource? vs = widget.videoSource;
    if (vs != null) {
      switch (vs.runtimeType) {
        case HTTPVideoSource: {
          HTTPVideoSource httpVS = vs as HTTPVideoSource;
            _controller =
                VideoPlayerController.networkUrl(Uri.parse(httpVS.url))
                  ..initialize().then((_) => {});
            _controller!.addListener(() {
              logger.d("Video playback video: ${_controller!.value}");
              if (_controller!.value.hasError) {
                // Handle video playback error
                logger.d(
                    "Video playback error: ${_controller!.value.errorDescription}");
              }
            });
          }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    VideoPlayerController? controller = _controller;
    Widget child;
    if (controller == null) {
      child = Container();
    } else {
      child = AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller));
    }

    return Column(
      children: [
        Center(child: child),
        Button(
            child: const Icon(FluentIcons.icon_sets_flag),
            onPressed: () {
              setState(() {
                if (_controller?.value.isPlaying == true) {
                  _controller?.pause();
                } else {
                  _controller?.play();
                }
              });
            })
      ],
    );
  }

  bool get wantKeepAlive => true;
}
