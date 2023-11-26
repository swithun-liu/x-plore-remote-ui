import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_player/video_player.dart';

class SwithunVideoPlayer extends StatefulWidget {

  VideoPlayerController Function() getVideoController;


  SwithunVideoPlayer(this.getVideoController, {super.key});

  @override
  State<SwithunVideoPlayer> createState() => _SwithunVideoPlayerState();
}

class _SwithunVideoPlayerState extends State<SwithunVideoPlayer> {

  late VideoPlayerController _controller;
  late AnimationController _videoControllerAnimCtrl;
  bool isVideoControllerIsShowing = false;
  double _slideValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return buildVideoPlayer(widget.getVideoController());
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      FluentIcons.full_screen,
                      color: Colors.white,
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
}
