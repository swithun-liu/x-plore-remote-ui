import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Directory.dart';
import 'package:x_plore_remote_ui/model/Path.dart';

class FolderUIItem extends StatefulWidget {
  FolderUIData directory;

  FolderUIItem(this.directory, {Key? key}) : super(key: ValueKey(directory));

  @override
  State<FolderUIItem> createState() => _FolderUIItemState();
}

class _FolderUIItemState extends State<FolderUIItem>
    with SingleTickerProviderStateMixin {
  final double smallTextSize = 14;
  final double bigTextSize = 18;
  late AnimationController _controller;

  late TextStyle smallStyle;
  late TextStyle bigStyle;
  Logger logger = Logger();
  late Animation<double> _animation;
  var duration = const Duration(milliseconds: 200);

  IconData get folderIcon {
    if (widget.directory.type == DirectoryType.FOLDER) {
      if ((widget.directory.originalPath as FolderData).isOpen) {
        return FluentIcons.fabric_open_folder_horizontal;
      } else {
        return FluentIcons.fabric_folder_fill;
      }
    } else if (widget.directory.type == DirectoryType.FILE) {
      return FluentIcons.page;
    } else {
      return FluentIcons.unknown;
    }
  }

  late TextStyle style;
  late double iconSize;

  @override
  void initState() {
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    smallStyle = TextStyle(
      fontSize: smallTextSize,
    );
    bigStyle = TextStyle(
      fontSize: bigTextSize,
    );

    var begin = smallTextSize;
    var end = bigTextSize;

    if (widget.directory.wasOpen) {
      style = bigStyle;
      iconSize = bigTextSize;
      begin = bigTextSize;
    } else {
      style = smallStyle;
      iconSize = smallTextSize;
      begin = smallTextSize;
    }

    if (widget.directory.isOpen) {
      end = bigTextSize;
    } else {
      end = smallTextSize;
    }

    _animation = Tween<double>(begin: begin, end: end).animate(_controller);

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        if (widget.directory.isOpen) {
          style = bigStyle;
          iconSize = bigTextSize;
        } else {
          style = smallStyle;
          iconSize = smallTextSize;
        }
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("FolderUIItem build ${widget.directory.name}");
    return Row(
      children: [
        SizedBox(
          width: widget.directory.level * smallTextSize,
        ),
        AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return AnimatedContainer(
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: duration,
                  width: _animation.value,
                  height: _animation.value,
                  child: Icon(
                    folderIcon,
                    size: _animation.value,
                  ));
            })
        // child: Icon(
        // folderIcon,
        // size: iconSize,
        // ),
        ,
        _buildFolderTitle(style)
      ],
    );
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
