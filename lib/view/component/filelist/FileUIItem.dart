import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Directory.dart';

class FileUIItem extends StatefulWidget {
  FileUIData file;
  bool lastChecking;
  bool currentChecking;

  FileUIItem(this.file, this.currentChecking, this.lastChecking, {Key? key})
      : super(key: ValueKey(currentChecking));

  @override
  State<FileUIItem> createState() => _FileUIItemState();
}

class _FileUIItemState extends State<FileUIItem> {
  Logger logger = Logger();

  double iconSize = 14;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d("FolderUIItem build ${widget.file.name}");
    return Row(
      children: [
        SizedBox(
          width: widget.file.level * iconSize,
        ),
        Icon(
          FluentIcons.page,
          size: iconSize,
        ),
        Text(
          widget.file.name,
          style: TextStyle(color: Colors.black),
        )
      ],
    );
  }
}
