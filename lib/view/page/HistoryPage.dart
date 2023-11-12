import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Directory.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/view/component/CustomAnimatedSize.dart';
import 'package:x_plore_remote_ui/view/component/filelist/FolderUIItem.dart';

class HistoryPage extends StatefulWidget {
  final List<String> history;
  const HistoryPage(this.history, {super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedContact = '';
  int pos = -1;
  int lastPos = -1;
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.history.length,
        itemBuilder: (context, index) {
          final contact = widget.history[index];
          return GestureDetector(
            onTap: () => {
            setState(() {
              logger.d("new pos ${pos}");
              lastPos = pos;
              pos = index;
            })
            },
            child: FolderUIItem(
              FolderUIData(DirectoryType.FOLDER, "haha", "hahaname", 0, FolderData("haha", 3, "haha", 0), false, false),
            ),
          );
        });

    // return CustomAnimatedSize();
    // return ListView.builder(
    //     itemCount: widget.history.length,
    //     itemBuilder: (context, index) {
    //       final contact = widget.history[index];
    //       return ListTile.selectable(
    //         title: Text(contact),
    //         selected: selectedContact == contact,
    //         onSelectionChange: (v) => setState(() => selectedContact = contact),
    //       );
    //     });
  }
}
