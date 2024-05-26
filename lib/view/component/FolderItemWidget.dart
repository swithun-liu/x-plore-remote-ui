import 'package:flutter/material.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'ColorBgContainer.dart';

Widget buildPathItem(PathData path, Function(FolderData folder) onFolderClick, Function(FileData file) onFileClick) {
  // 当Path是File，和当Path是Folder，做不同的处理
  Widget child;
  if (path is FileData) {
    child = _buildFileItem(path, onFileClick);
  } else if (path is FolderData) {
    child = FolderItemWidget(path, onFolderClick, onFileClick);
  } else {
    child = Text("未知类型");
  }

  return fluent.IntrinsicHeight(
    child: child,
  );
}

Widget _buildFileItem(FileData file, Function(FileData file) onFileClick) {
  return material.Row(
      children: [
        createCustomWidget(),
        Expanded(
          child: ColorBgContainer(
            tagUpColor: fluent.Colors.grey[20],
            tagDownColor: fluent.Colors.grey[50],
            onTap: () {
              onFileClick(file);
            },
            child: Expanded(
                child: fluent.Row(
                  children: [
                    const fluent.Icon(fluent.FluentIcons.page),
                    Text(file.name)
                  ],
                )
            ),
          ),
        )
      ]
  );
}

class FolderItemWidget extends StatefulWidget {
  FolderData folder;
  Function(FolderData folder) onFolderClick;
  Function(FileData file) onFileClick;

  FolderItemWidget(this.folder, this.onFolderClick, this.onFileClick);

  @override
  _FolderItemWidget createState() => _FolderItemWidget();
}

class _FolderItemWidget extends State<FolderItemWidget> {
  _FolderItemWidget();
  bool showProcess = false;

  @override
  Widget build(BuildContext context) {
    var folder = widget.folder;
    var _onFolderClick = widget.onFolderClick;

    var children = [];
    if (folder.isOpen) {
      children = _buildFolderChildren(folder, _onFolderClick, widget.onFileClick);
    }
    var folderIcon = folder.isOpen
        ? fluent.FluentIcons.fabric_open_folder_horizontal
        : fluent.FluentIcons.fabric_folder_fill;

    return material.Row(children: [
      createCustomWidget(),
      Expanded(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ColorBgContainer(
                    tagUpColor: fluent.Colors.grey[20],
                    tagDownColor: fluent.Colors.grey[50],
                    onTap: () {
                      _test(folder, _onFolderClick);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fluent.Icon(folderIcon),
                        Text(folder.name),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showProcess)
              LinearProgressIndicator(
                color: fluent.Colors.blue['normal'],
                minHeight: 1,
              )
            ,
            ...children
          ],
        ),
      ),
    ]);
  }

  Future<void> _test(FolderData folder, Function(FolderData folder) onFolderClick) async {
    setState(() {
      showProcess = true;
    });
    await onFolderClick(folder);
    setState(() {
      showProcess = false;
    });
  }

  List<Widget> _buildFolderChildren(
      FolderData folder, Function(FolderData folder) onFolderClick, Function(FileData file) onFileClick) {
    List<Widget> ws = [];
    if (folder.isOpen) {
      ws.addAll(folder.children
          .map((e) => buildPathItem(e, onFolderClick, onFileClick))
          .toList());
    }
    return ws;
  }

}

Widget createCustomWidget() {
  return Container(
    width: 10.0,
    color: material.Colors.transparent,
    child: Center(
      child: Container(
        width: 1.0,
        color: fluent.Colors.grey[50],
      ),
    ),
  );
}
