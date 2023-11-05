import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import '../../model/Path.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  FolderItem root = FolderItem("root", 0, "/", 0, isOpen: false);
  List<Directory> directories = [];
  var logger = Logger();
  String ip = '192.168.31.249';

  late final Box settingBox;
  List<String> history = [];

  @override
  void initState() {
    super.initState();

    settingBox = Hive.box("setting");
    var ip = settingBox.get("ip");
    logger.d("db ip $ip");
    if (ip != null) {
      this.ip = ip;
    }
    var history = settingBox.get("history") as List<String>?;
    if (history != null) {
      this.history = history;
      logger.d("history $history");
    }

    setState(() {
      directories = parseFileList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: directories.length,
        itemBuilder: (context, index) {
          var d = directories[index];
          var kongge = ' ' * (d.level * 2);

          return GestureDetector(
            onTap: () => {_onFolderClick(d.originalPath)},
            child: Text('$kongge + ${d.name}'),
          );

          return Text('$kongge + ${d.name}');
        });
  }

  List<Directory> parseFileList() {
    logger.d('swithun-xxxx parseFileList');
    List<Directory> directories = [];
    return iParsePath(directories, root, 0);
  }

  List<Directory> iParsePath(
      List<Directory> directories, Path parent, int level) {
    switch (parent.runtimeType) {
      case FolderItem:
        {
          var d = Directory(
              DirectoryType.FOLDER, parent.path, parent.name, level, parent);
          directories.add(d);
          var folder = (parent as FolderItem);
          if (folder.isOpen) {
            for (var directory in folder.children) {
              iParsePath(directories, directory, level + 1);
            }
          }

          break;
        }
      case FileItem:
        {
          var d = Directory(
              DirectoryType.FILE, parent.path, parent.name, level, parent);
          directories.add(d);
          break;
        }
    }
    logger.d('swithun-xxxx iParsePath ${directories.length}');
    return directories;
  }


  _copyFileUrlToClipboard(FileItem file) {
    var logger = Logger();

    var uri = Uri.http('$ip:1111', file.path, {'cmd': 'file'});
    var url = uri.toString();
    logger.d('swithun-xxxx $url');
    Clipboard.setData(ClipboardData(text: url));
    displayInfoBar(context, builder: (context, close) {
      return const fluent.InfoBar(title: Text('已复制'));
    });

    var newHistory = history;
    newHistory.add(file.path);

    if (newHistory.length > 30) {
      newHistory.removeAt(0);
    }

    settingBox.put('history', newHistory);

    setState(() {
      history = newHistory;
    });
  }

  _onFolderClick(Path path) async {
    switch (path.runtimeType) {
      case FolderItem:
        {
          var folder = path as FolderItem;
          if (folder.isOpen) {
            folder.isOpen = false;
          } else {
            if (path.path == '/') {
              await _getBaseFileList();
            } else {
              await _getChildFileList(path as FolderItem);
            }
            folder.isOpen = true;
          }

        }
      case FileItem:
        {
          _copyFileUrlToClipboard(path as FileItem);
        }
    }

    setState(() {
      directories = parseFileList();
    });
  }

  _getChildFileList(FolderItem folder) async {
    var logger = Logger();
    logger.d("_getChildFileList");

    var parent = folder.path;

    var url = Uri.http('$ip:1111', parent, {'cmd': 'list'});

    var urlStr = url.toString();
    logger.d("_getChildFileList $urlStr");

    var response = await http.get(url, headers: {
      "User-Agent": "Apifox/1.0.0 (https://www.apifox.cn)",
      "Accept": "*/*",
      "Access-Control-Allow-Origin": "*"
    });

    // uf8解析body
    var json = jsonDecode(utf8.decode(response.bodyBytes));

    /**
     * {
        "files": [
        {
        "has_children": true,
        "n": "apk",
        "t": 1
        },
        ],
        "hasDon": true
        }*/
    var files = json['files'];
    logger.d(files);
    // 如果有 has_children 字段，就是文件夹，否则就是文件，拼成FolderItem和FileItem
    List<Path> pathList = [];
    for (var file in files) {
      var hasChildren = file['has_children'];
      var name = file['n'];
      var size = file['size'];
      var path = parent + '/' + name;
      if (hasChildren != null) {
        pathList.add(FolderItem(name, 0, path, folder.level + 1));
      } else {
        pathList.add(FileItem(name, 0, path, folder.level + 1));
      }
    }
    var newFolder = folder;
    newFolder.children = pathList;

    setState(() {
      folder = newFolder;
    });
  }

  _getBaseFileList() async {
    var logger = Logger();
    logger.d("_getBaseFileList");

    // FocusScope.of(context).requestFocus(_focusNode);
    // http://192.168.31.249:1111/ query : cmd = list_root filter=dirs
    var url = Uri.http('$ip:1111', '', {'cmd': 'list_root', 'filter': 'dirs'});
    var urlStr = url.toString();
    logger.d("_getBaseFileList $urlStr");

    var response = await http.get(url, headers: {
      "User-Agent": "Apifox/1.0.0 (https://www.apifox.cn)",
      "Accept": "*/*",
      "Access-Control-Allow-Origin": "*"
    });

    // uf8解析body
    var json = jsonDecode(utf8.decode(response.bodyBytes));
    var files = json['files'];
    logger.d(files);
    // 取出 lable 是名字，组成list
    List<String> list = [];
    List<Path> pathList = [];
    for (var file in files) {
      var label = file['label'];
      var mount = file['mount'];
      logger.d(label);
      list.add(label);

      pathList.add(FolderItem(label, 0, mount, 0));
    }

    logger.d(list);
    var newRoot = root;
    newRoot.children = pathList;

    setState(() {
      root = newRoot;
    });
  }
}

class Directory {
  DirectoryType type;
  String path;
  String name;
  int level;
  Path originalPath;

  Directory(this.type, this.path, this.name, this.level, this.originalPath);
}

enum DirectoryType { FILE, FOLDER }
