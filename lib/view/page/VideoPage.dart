import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';

class VideoPage extends StatefulWidget {
  VideoSource? videoSource;
  bool Function() getIsFullScreen;
  void Function(bool isfull) changeFullScreen;

  VideoPage(this.videoSource, this.getIsFullScreen, this.changeFullScreen, {super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  Logger logger = Logger();
  late AnimationController _videoControllerAnimCtrl;
  bool isVideoControllerIsShowing = false;
  double _slideValue = 0.0;
  bool rememberIsPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(''))
      ..initialize().then((_) => {setState(() {})});
    _videoControllerAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
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
    Wakelock.disable();
    VideoSource? vs = widget.videoSource;
    if (vs != null) {
      switch (vs.runtimeType) {
        case HTTPVideoSource:
          {
            HTTPVideoSource httpVS = vs as HTTPVideoSource;
            _controller =
                VideoPlayerController.networkUrl(Uri.parse(httpVS.url))
                  ..initialize().then((_) => {setState(() {})});
            _controller!.addListener(() {
              // 监听是否正在播放
              var videoIsPlaying = _controller!.value.isPlaying;
              if (videoIsPlaying && !rememberIsPlaying) {
                setState(() {
                  Wakelock.enable();
                });
              } else if (!videoIsPlaying && rememberIsPlaying) {
                setState(() {
                  Wakelock.disable();
                });
              }
              // 错误监听
              if (_controller!.value.hasError) {
                // Handle video playback error
                logger.d(
                    "Video playback error: ${_controller!.value.errorDescription}");
              } else {
                setState(() {
                  _slideValue = _controller.value.position.inSeconds.toDouble();
                });
              }
            });
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
          color: Colors.yellow,
          child: Hero(tag: 'swithunVideo', child: buildVideoPlayer())),
    ));
  }

  Widget buildVideoPlayer() {
    VideoPlayerController? controller = _controller;
    Widget videoPlayer;
    videoPlayer = AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          VideoPlayer(controller),
          MouseRegion(
            onEnter: (e) {
              if (!isVideoControllerIsShowing) {
                isVideoControllerIsShowing = true;
                _videoControllerAnimCtrl.forward(from: 0);
              }
            },
            onExit: (e) {
              if (isVideoControllerIsShowing) {
                isVideoControllerIsShowing = false;
                _videoControllerAnimCtrl.reverse(from: 1);
              }
            },
            child: GestureDetector(
              onTap: () {
                if (isVideoControllerIsShowing) {
                  isVideoControllerIsShowing = false;
                  _videoControllerAnimCtrl.reverse(from: 1);
                } else {
                  isVideoControllerIsShowing = true;
                  _videoControllerAnimCtrl.forward(from: 0);
                }
              },
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _videoControllerAnimCtrl, curve: Curves.linear),
                child: buildVideoController(),
              ),
            ),
          )
        ],
      ),
    );
    return videoPlayer;
  }

  Widget buildVideoController() {
    var controller = _controller;
    var max = 0.0;
    max = controller.value.duration.inSeconds.toDouble();
    return Container(
      color: Colors.black.withAlpha((0.3 * 255).toInt()),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.getIsFullScreen()) {
                    widget.changeFullScreen(false);
                  } else {
                    widget.changeFullScreen(true);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        widget.getIsFullScreen() ? FluentIcons.back_to_window : FluentIcons.full_screen,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Slider(
                      value: _slideValue,
                      onChanged: (double value) {
                        setState(() {
                          _slideValue = value;
                          _controller?.seekTo(Duration(seconds: value.toInt()));
                        });
                      },
                      max: max,
                      min: 0.0,
                    ),
                  ),
                ),
              ),
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
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  bool get wantKeepAlive => true;
}
