import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';
import 'package:x_plore_remote_ui/repo/v2/IFileRepo.dart';
import 'package:x_plore_remote_ui/repo/v2/SmbaFileRepo.dart';
import 'package:x_plore_remote_ui/util/CommonUtil.dart';
import 'package:x_plore_remote_ui/view/component/filelist/FileUIItem.dart';
import 'package:x_plore_remote_ui/view/component/filelist/FolderUIItem.dart';

import '../../model/Directory.dart';
import '../../model/Path.dart';

class FileListPage extends StatefulWidget {
  final Function(String) updateVideoSource;
  void Function(FolderUIData directory) setVideoRootPath;
  void Function(VideoSource videoSource) copyFileUrlToClipboard;

  FileListPage(this.updateVideoSource, this.setVideoRootPath, this.copyFileUrlToClipboard, {super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> with AutomaticKeepAliveClientMixin {
  FolderData root = FolderData("root", 0, "", 0, isOpen: false);
  List<DirectoryUIData> directories = [];
  var logger = Logger();
  String ip = '192.168.31.249';
  IFileRepo repoV2 = SmbFileRepo();

  int pos = -1;
  int lastPos = -1;

  late final Box settingBox;
  List<String> history = [];

  Set<String> lastStateOpeningFolder = {};
  CommonUtil util = CommonUtil();
  FileRepo repo = FileRepo();

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
      logger.d("directories: ${directories}");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
        itemCount: directories.length,
        itemBuilder: (context, index) {
          var d = directories[index];

          Widget child = const Text("unknown");
          switch (d.runtimeType) {
            case FolderUIData:
              {
                child = FolderUIItem(d as FolderUIData, widget.setVideoRootPath);
              }
            case FileUIData:
              {
                child = FileUIItem(d as FileUIData, false, false);
              }
          }

          return GestureDetector(
            onTap: () => {
              setState(() {
                logger.d("new pos ${pos}");
                lastPos = pos;
                pos = index;
              }),
              _onFolderClick(d.originalPath)
            },
            // child: Text('$kongge + ${d.name}'),
            child: Container(width: double.infinity, child: child),
          );
        });
  }

  List<DirectoryUIData> parseFileList() {
    List<DirectoryUIData> directories = [];
    return iParsePath(directories, root, 0);
  }

  List<DirectoryUIData> iParsePath(
      List<DirectoryUIData> directories, PathData parent, int level) {
    switch (parent.runtimeType) {
      case FolderData:
        {
          var folder = (parent as FolderData);
          var d = FolderUIData(
              DirectoryType.FOLDER,
              folder.path,
              folder.name,
              level,
              folder,
              lastStateOpeningFolder.contains(folder.path),
              folder.isOpen);
          directories.add(d);
          if (folder.isOpen) {
            for (var directory in folder.children) {
              iParsePath(directories, directory, level + 1);
            }
          }

          break;
        }
      case FileData:
        {
          var d = FileUIData(
              DirectoryType.FILE, parent.path, parent.name, level, parent);
          directories.add(d);
          break;
        }
    }
    return directories;
  }

  _copyFileUrlToClipboard(VideoSource file) {
    widget.copyFileUrlToClipboard(file);

    setState(() {
    });
  }

  _onFolderClick(PathData path) async {
    lastStateOpeningFolder = directories
        .where((element) {
          bool result = false;
          if (element.originalPath is FolderData) {
            if ((element.originalPath as FolderData).isOpen) {
              result = true;
            }
          }
          return result;
        })
        .toSet()
        .map((e) => e.path)
        .toSet();

    switch (path.runtimeType) {
      case FolderData:
        {
          var folder = path as FolderData;
          if (folder.isOpen) {
            folder.isOpen = false;
          } else {
            folder.isOpen = true;
            if (path.path == root.path) {
              await  _getChildFileList_V2(root);
            } else {
              await _getChildFileList_V2(path as FolderData);
            }
          }
        }
      case FileData:
        {
          FileData file = path as FileData;
          List<FileData> fileChildren = util.filterVideoFile(file.parent.children);
          HTTPVideoSourceGroup videoSource = util.buildHttpVideoSourceGroup(fileChildren, file);
          _copyFileUrlToClipboard(videoSource);
        }
    }

    setState(() {
      directories = parseFileList();
      logger.d("directories: ${directories.map((e) => e.path)}");
    });
  }

  _getChildFileList_V2(FolderData folder) async {
    var newFolder = folder;
    newFolder.children = await repoV2.getPaths(folder, folder.level);

    setState(() {
      folder = newFolder;
    });
  }

  _getChildFileList(FolderData folder) async {
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
    List<PathData> children = [];
    for (var file in files) {
      var hasChildren = file['has_children'];
      var name = file['n'];
      var size = file['size'];
      var path = parent + '/' + name;
      if (hasChildren != null) {
        children.add(FolderData(name, 0, path, folder.level + 1));
      } else {
        children.add(FileData(name, 0, path, folder.level + 1, folder));
      }
    }
    children.sort((a, b) => a.name.compareTo(b.name));
    var newFolder = folder;
    newFolder.children = children;

    setState(() {
      folder = newFolder;
    });
  }

  _getBaseFileList_V2() async {
    var newRoot = root;
    newRoot.children = await repoV2.getPaths(root, root.level);
    setState(() {
      root = newRoot;
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
    List<PathData> pathList = [];
    for (var file in files) {
      var label = file['label'];
      var mount = file['mount'];
      logger.d(label);
      list.add(label);

      pathList.add(FolderData(label, 0, mount, 0));
    }

    logger.d(list);
    var newRoot = root;
    newRoot.children = pathList;

    setState(() {
      root = newRoot;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
