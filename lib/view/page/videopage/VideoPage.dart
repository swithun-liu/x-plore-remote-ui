import 'dart:io';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';

import 'VideoPageDependency.dart';

class VideoPage extends StatefulWidget {
  /// 正在播放的视频源
  VideoSource? videoSource;

  /// 是否正在全屏播放
  bool Function() getIsFullScreen;

  /// 切换是否全屏播放
  void Function(bool isfull) changeFullScreen;
  VideoPageDependency dependency;

  VideoPage(this.videoSource, this.getIsFullScreen, this.changeFullScreen,
      this.dependency,
      {super.key});

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
  late ChewieController _chewieController;
  var control = CupertinoControls(
      backgroundColor: Colors.black.withAlpha(122), iconColor: Colors.white);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(''))
      ..initialize().then((_) => {setState(() {})});
    _videoControllerAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _initializeController();
    // testInitial();
  }

  @override
  void didUpdateWidget(covariant VideoPage oldWidget) {
    logger.d('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _slideValue = 0.0;
      _controller.dispose();
      _initializeController();
    }
  }

  // Initialize video controller
  void _initializeController() {
    logger.d('_initializeController');
    Wakelock.disable();
    VideoSource? vs = widget.videoSource;
    if (vs != null) {
      switch (vs.runtimeType) {
        case HTTPVideoSourceGroup:
        case HTTPVideoSource:
          {
            logger.d("Video Page VS更新 ${vs.getUrl(widget.dependency.getIp())}");
            _controller = VideoPlayerController.networkUrl(
                Uri.parse(vs.getUrl(widget.dependency.getIp())))
              ..initialize().then((_) => {
                    setState(() {
                      stopOrBegin();
                    })
                  });
            _chewieController = ChewieController(
              videoPlayerController: _controller,
              autoPlay: true,
              customControls: control,
              subtitle: Subtitles([
                Subtitle(
                  index: 0,
                  start: Duration.zero,
                  end: const Duration(seconds: 10),
                  text: 'Hello from subtitles',
                ),
                Subtitle(
                  index: 1,
                  start: const Duration(seconds: 10),
                  end: const Duration(seconds: 20),
                  text: 'Whats up? :)',
                ),
              ]),
              subtitleBuilder: (context, subtitle) => Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
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
                if (_controller.value.position.inSeconds ==
                    _controller.value.duration.inSeconds) {
                  sleep(const Duration(seconds: 2));
                  gotoNext();
                }
                setState(() {
                  _slideValue = _controller.value.position.inSeconds.toDouble();
                });
              }
            });
          }
        default:
          {
            logger.d("Video Page default ${vs.runtimeType}");
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildOld();
    return buildNew();
  }

  Widget buildNew() {
    return Container(
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }

  Widget buildOld() {
    return Center(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
          color: Colors.yellow,
          child: Hero(tag: 'swithunVideo', child: buildVideoPlayer())),
    ));
  }

  /// 构建播放器
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

  /// 构建播放器控制器
  Widget buildVideoController() {
    var controller = _controller;
    var max = 0.0;
    max = controller.value.duration.inSeconds.toDouble();
    return Container(
      color: Colors.black.withAlpha((0.0 * 255).toInt()),
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
                        widget.getIsFullScreen()
                            ? FluentIcons.back_to_window
                            : FluentIcons.full_screen,
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

              /// 播放/暂停
              Center(
                child: Row(
                  children: [
                    Button(
                        onPressed: gotoPrevious,
                        child: const Icon(FluentIcons.previous)),
                    Button(
                        onPressed: stopOrBegin,
                        child: const Icon(FluentIcons.play)),
                    Button(
                        onPressed: gotoNext,
                        child: const Icon(FluentIcons.next))
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void gotoNext() {
    VideoSource? vs = widget.videoSource;
    if (vs is HTTPVideoSourceGroup) {
      int length = vs.urls.length;
      int newPos = vs.pos + 1;
      if (newPos <= length) {
        HTTPVideoSourceGroup newVs = HTTPVideoSourceGroup(vs.urls, newPos);
        widget.dependency.copyFileUrlToClipboard(newVs);
      }
    }
  }

  void gotoPrevious() {
    VideoSource? vs = widget.videoSource;
    if (vs is HTTPVideoSourceGroup) {
      int length = vs.urls.length;
      int newPos = vs.pos - 1;
      if (newPos <= length && newPos >= 0) {
        HTTPVideoSourceGroup newVs = HTTPVideoSourceGroup(vs.urls, newPos);
        widget.dependency.copyFileUrlToClipboard(newVs);
      }
    }
  }

  void stopOrBegin() {
    setState(() {
      if (_controller.value.isPlaying == true) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  bool get wantKeepAlive => true;
}
