import 'dart:io';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:subtitle_wrapper_package/data/data.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper.dart';
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

  Logger logger = Logger();

  /// 控制视频播放
  late VideoPlayerController _videoPlayerController;
  /// 控制器——控制条
  late AnimationController _videoControllerAnimCtrl;
  /// 控制器-字幕
  late SubtitleController _subtitleController;
  /// 控制器蒙层 是否显示
  bool isVideoControllerIsShowing = false;
  /// 视频播放进度
  double _playProcess = 0.0;
  bool rememberIsPlaying = false;
  late ChewieController _chewieController;
  var _chewieControllerUI = CupertinoControls(
      backgroundColor: Colors.black.withAlpha(122), iconColor: Colors.white);
  String subtitleUrl = "";

  @override
  void initState() {
    super.initState();
    updateSubtitle("");
    _initializeController();
    updateVideoControllerAnimCtrl();
  }

  void updateVideoControllerAnimCtrl() {
    _videoControllerAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  void updateSubtitle(String url) {
    var subtitleType = SubtitleType.srt;
    if (url.endsWith("srt")) {
      subtitleType = SubtitleType.srt;
    } else {
      subtitleType = SubtitleType.webvtt;
    }
    _subtitleController = SubtitleController(
      subtitleUrl: url,
      subtitleType: subtitleType,
    );
  }

  void updateSubtitleUrl(String url) {
    var subtitleType = SubtitleType.srt;
    if (url.endsWith("srt")) {
      subtitleType = SubtitleType.srt;
    } else {
      subtitleType = SubtitleType.webvtt;
    }
    _subtitleController.subtitleType = subtitleType;
    _subtitleController.subtitleUrl = url;
  }

  void updateVideoPlayer(videoUrl) {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl))
          ..initialize().then((_) => {
                setState(() {
                  stopOrBegin();
                })
              });
  }

  void updateChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      customControls: _chewieControllerUI,
    );
  }

  void listenVideoPlayProcess() {
    _videoPlayerController.addListener(() {
      // 监听是否正在播放
      var videoIsPlaying = _videoPlayerController.value.isPlaying;
      if (videoIsPlaying) {
        setState(() {
          Wakelock.enable();
        });
      } else {
        setState(() {
          Wakelock.disable();
        });
      }
      // 错误监听
      if (_videoPlayerController.value.hasError) {
        logger.d(
            "Video playback error: ${_videoPlayerController.value.errorDescription}");
      } else {
        // 自动播放下一集
        if (_videoPlayerController.value.position.inSeconds ==
            _videoPlayerController.value.duration.inSeconds) {
          sleep(const Duration(seconds: 2));
          gotoNext();
        }
        // 更新播放进度
        setState(() {
          _playProcess = _videoPlayerController.value.position.inSeconds.toDouble();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoPage oldWidget) {
    logger.d('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _playProcess = 0.0;
      _videoPlayerController.dispose();
      _initializeController();
      setState(() { });
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
            updateSubtitleUrl(subtitleUrl);
            updateVideoPlayer(vs.getUrl(widget.dependency.getIp()));
            updateChewieController();
            listenVideoPlayProcess();
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
    return buildOldV2();
  }

  Widget buildOldV2() {
    return SubtitleWrapper(
      videoChild: buildOld(),
      subtitleController: _subtitleController,
      videoPlayerController: _videoPlayerController,
      subtitleStyle: SubtitleStyle(
        textColor: Colors.white,
      ),
    );
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
  // updateSubtitleUrl("http://localhost:8080/?path=/aria/s7/test.srt");
  Widget buildVideoPlayer() {
    VideoPlayerController? controller = _videoPlayerController;
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
    var controller = _videoPlayerController;
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
              ),
              GestureDetector(
                onTap: () {
                  // updateSubtitleUrl("http://localhost:8080/?path=/aria/s7/test.srt");
                  setState(() {
                    subtitleUrl = "http://localhost:8080/?path=/aria/s7/test.srt";
                  });
                  _initializeController();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Icon( FluentIcons.accept_medium,
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
                      value: _playProcess,
                      onChanged: (double value) {
                        setState(() {
                          _playProcess = value;
                          _videoPlayerController?.seekTo(Duration(seconds: value.toInt()));
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
      if (_videoPlayerController.value.isPlaying == true) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
  }

  bool get wantKeepAlive => true;
}
