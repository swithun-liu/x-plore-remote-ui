import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Directory.dart';
import 'package:x_plore_remote_ui/model/Path.dart';

class FileUIItem extends StatefulWidget {
  DirectoryUIData directory;
  bool lastChecking;
  bool currentChecking;

  FileUIItem(this.directory, this.currentChecking, this.lastChecking, {Key? key}) : super(key: ValueKey(currentChecking));

  @override
  State<FileUIItem> createState() => _FileUIItemState();
}

class _FileUIItemState extends State<FileUIItem> {

  final double smallTextSize = 10;
  final double bigTextSize = 15;

  late TextStyle smallStyle;
  late TextStyle bigStyle;
  Logger logger = Logger();

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
    smallStyle = TextStyle(
      fontSize: smallTextSize,
    );
    bigStyle = TextStyle(
      fontSize: bigTextSize,
    );

    if (widget.lastChecking) {
      style = bigStyle;
      iconSize = bigTextSize;
    } else {
      style = smallStyle;
      iconSize = smallTextSize;
    }

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        if (widget.currentChecking) {
          style = bigStyle;
          iconSize = bigTextSize;
        } else {
          style = smallStyle;
          iconSize = smallTextSize;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d("FolderUIItem build ${widget.directory.name}");
    return Row(
      children: [
        SizedBox(
          width: widget.directory.level * smallTextSize,
        ),
        Icon(
          folderIcon,
          size: iconSize,
        ),
        _buildFolderTitle(style)
      ],
    )
    ;
  }

  Widget _buildFolderTitle(TextStyle style) {
    return AnimatedDefaultTextStyle(
        curve: Curves.linear,
        style: style,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.directory.name,
          style: TextStyle(color: Colors.black),
        ));
  }
}
