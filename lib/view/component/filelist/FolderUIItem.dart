import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Directory.dart';
import 'package:x_plore_remote_ui/view/component/filelist/FolderUIConfig.dart';

class FolderUIItem extends StatefulWidget {
  FolderUIData directory;

  FolderUIItem(this.directory, {Key? key}) : super(key: ValueKey(directory));

  @override
  State<FolderUIItem> createState() => _FolderUIItemState();
}

class _FolderUIItemState extends State<FolderUIItem>
    with SingleTickerProviderStateMixin {
  final double defSmallTextSize = 14;
  final double defBigTextSize = 18;

  late bool animUseOpenIcon;
  late AnimIconSize animIconSize;
  late double animTextSize;

  Logger logger = Logger();

  late AnimationController _controller;
  late Animation<double> _animation;
  var duration = const Duration(milliseconds: 200);
  var halfDuration = const Duration(milliseconds: 100);

  bool get getIsOpening {
    return widget.directory.isOpen;
  }

  @override
  void initState() {
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    if (widget.directory.wasOpen) {
      animTextSize = defBigTextSize;

      if (widget.directory.isOpen) {
        animIconSize = AnimIconSize(defBigTextSize, defBigTextSize);
      } else {
        animIconSize = AnimIconSize(defBigTextSize, defSmallTextSize);
      }
      animUseOpenIcon = true;
    } else {
      animTextSize = defSmallTextSize;
      animUseOpenIcon = false;

      if (widget.directory.isOpen) {
        animIconSize = AnimIconSize(defSmallTextSize, defBigTextSize);
      } else {
        animIconSize = AnimIconSize(defSmallTextSize, defSmallTextSize);
      }
    }

    _animation = Tween<double>(begin: animIconSize.begin, end: animIconSize.end)
        .animate(_controller);

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        if (widget.directory.isOpen) {
          animUseOpenIcon = true;
          animTextSize = defBigTextSize;
        } else {
          animUseOpenIcon = false;
          animTextSize = defSmallTextSize;
        }
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("FolderUIItem build ${widget.directory.name}");

    return Row(
      children: [
        Container(
          height: defSmallTextSize,
          width: widget.directory.level * defSmallTextSize,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(3),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.grey[30],
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey[70],
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 0))
                ]),
            child: Row(
              children: [
                AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return AnimatedContainer(
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: duration,
                          margin: EdgeInsets.only(right: 5),
                          width: _animation.value,
                          height: _animation.value,
                          child: _buildIcon());
                    }),
                _buildFolderTitle(TextStyle(
                  fontSize: animTextSize,
                ))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return AnimatedSwitcher(
        duration: halfDuration,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: animUseOpenIcon
            ? Icon(
                FluentIcons.fabric_open_folder_horizontal,
                size: _animation.value,
                key: const ValueKey('icon1'),
              )
            : Icon(
                FluentIcons.fabric_folder_fill,
                size: _animation.value,
                key: const ValueKey('icon2'),
              ));
  }

  Widget _buildFolderTitle(TextStyle style) {
    return AnimatedDefaultTextStyle(
        curve: Curves.fastLinearToSlowEaseIn,
        style: style,
        duration: duration,
        child: Text(
          widget.directory.name,
          style: TextStyle(color: Colors.black),
        ));
  }
}
