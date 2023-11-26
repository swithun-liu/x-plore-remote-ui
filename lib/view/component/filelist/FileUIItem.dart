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

  final double chipHeight = 14;


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
        Container(
          height: chipHeight,
          width: widget.file.level * chipHeight,
        ),
        Expanded(child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey[10],
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[70],
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 0)
              )
            ]
          ),
          child: Row(
            children: [
              Icon(
                FluentIcons.page,
                size: iconSize,
              ),
              Text(
                widget.file.name,
                style: TextStyle(color: Colors.black, fontSize: chipHeight),
              )
            ],
          ),
        ))
      ],
    );
  }
}
