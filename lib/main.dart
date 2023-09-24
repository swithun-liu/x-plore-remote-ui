import 'dart:convert';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'model/Path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      theme: FluentThemeData(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String ip = '192.168.31.249';
  List<String> data = [];
  FolderItem root = FolderItem("root", 0, "/", -1, isOpen: true);
  int topIndex = 0;

  // 在State类中定义一个TextEditingController对象
  final TextEditingController ipController =
      TextEditingController(text: '192.168.31.249');
  final FocusNode _focusNode = FocusNode();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<NavigationPaneItem> items = [
      PaneItem(
        icon: const Icon(Icons.home),
        title: const Text('主页'),
        body: _NavigationBodyItem(),
      ),
      PaneItem(
        icon: const Icon(Icons.settings),
        title: const Text('设置'),
        body: _NavigationBodyItem(),
      ),
      PaneItemSeparator(),
    ];

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('NavigationView'),
      ),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        // displayMode: displayMode,
        items: items,
        footerItems: [],
      ),
    );
  }

  Widget _NavigationBodyItem() {
    return Expanded(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 子项顶部对齐
      children: [_PathTree()],
    ));
  }

  Widget _PathTree() {
    return Expanded(
        child: Container(
          color: fluent.Colors.green,
          child: ListView(
            shrinkWrap: true,
            children: [_buildPathItem(root)],
          ),
        ));
  }

  Widget _buildPathItem(Path path) {
    // 当Path是File，和当Path是Folder，做不同的处理
    if (path is FileItem) {
      return _buildFileItem(path);
    } else if (path is FolderItem) {
      return _buildFolderItem(path);
    } else {
      return const Text("未知类型");
    }
  }

  Widget _buildFileItem(FileItem file) {
    return material.Row(children: [
      createCustomWidgets(file.level),
      Button(child: Text(file.name), onPressed: () => {
        _copyFileUrlToClipboard(file)
      })
    ]);

  }

  _copyFileUrlToClipboard(FileItem file) {
    var logger = Logger();

    var uri = Uri.http('192.168.31.249:1111', file.path, {'cmd': 'file'});
    var url = uri.toString();
    logger.d('swithun-xxxx $url');
    Clipboard.setData(ClipboardData(text: url));
    displayInfoBar(context, builder: (context, close) {
      return const fluent.InfoBar(title: Text('已复制'));
    });

  }

  Widget createCustomWidgets(int size) {
    if (size >= 0) {
      return Row(
        children: List.generate(size + 1, (index) {
          return createCustomWidget();
        }),
      );
    } else {
      return Container();
    }
  }

  Widget createCustomWidget() {
    return Container(
      width: 10.0, // 宽度设置为 40
      color: fluent.Colors.yellow, // 透明背景颜色
      child: Center(
        child: Container(
          width: 4.0, // 竖条宽度设置为 15
          color: fluent.Colors.yellow, // 竖条蓝色
        ),
      ),
    );
  }

  Widget _buildFolderItem(FolderItem folder) {
    var children = [];
    if (folder.isOpen) {
      children = _buildFolderChildren(folder);
    }
    return material.Row(children: [
      createCustomWidgets(folder.level),
      Expanded(
        child: Column(
          children: [
            fluent.GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _onFolderClick(folder);
              },
              child: Container(
                color: material.Colors.blue,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folder.name),
                  ],
                ),
              ),
            ),
            ...children
          ],
        ),
      ),
    ]);
  }

  _onFolderClick(FolderItem folder) {
    if (!folder.isOpen) {
      if (folder.path == '/') {
        _getBaseFileList();
      } else {
        _getChildFileList(folder);
      }
    }
    setState(() {
      folder.isOpen = !folder.isOpen;
    });
  }

  List<Widget> _buildFolderChildren(FolderItem folder) {
    List<Widget> ws = [];
    if (folder.isOpen) {
      ws.addAll(folder.children.map((e) => _buildPathItem(e)).toList());
    }
    return ws;
  }

  // 编辑IP地址，默认填写 192.168.31.249
  Widget _editIP() {
    return TextField(
      controller: ipController,
      decoration: const InputDecoration(
        hintText: "请输入IP地址",
        prefixIcon: Icon(Icons.computer),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        print("输入的内容为：$value");
        // ip = value;
      },
    );
  }

  Widget _buildSubmitBtn() => ElevatedButton(
      child: const Text(
        "提交",
        style: TextStyle(color: material.Colors.black, fontSize: 16),
      ),
      onPressed: () => _getBaseFileList());

  Widget _FileList() {
    return SizedBox(
        height: 100,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: data.map((e) => Text(e)).toList(),
        ));
  }

  _getChildFileList(FolderItem folder) async {
    var logger = Logger();
    logger.d("_getChildFileList");

    var parent = folder.path;

    var url = Uri.http('192.168.31.249:1111', parent, {'cmd': 'list'});

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
        "n": ".fseventsd",
        "hidden": true,
        "t": 1
        },
        {
        "n": "usb2.mp4",
        "size": 234102236,
        "time": 1692473052000,
        "mime": "video/mp4",
        "t": 2
        },
        {
        "has_children": true,
        "n": "fengsao3",
        "t": 1
        },
        {
        "has_children": true,
        "n": "test",
        "t": 1
        },
        {
        "has_children": true,
        "n": "fff",
        "t": 1
        },
        {
        "has_children": true,
        "n": "fengsao4",
        "t": 1
        },
        {
        "n": "20230820-163653.mp4",
        "size": 1849788,
        "time": 1693624774000,
        "mime": "video/mp4",
        "t": 2
        },
        {
        "has_children": true,
        "n": "apk",
        "t": 1
        },
        {
        "has_children": true,
        "n": "fengsao5",
        "t": 1
        }
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

    FocusScope.of(context).requestFocus(_focusNode);
    // http://192.168.31.249:1111/ query : cmd = list_root filter=dirs
    var url = Uri.http(
        '192.168.31.249:1111', '', {'cmd': 'list_root', 'filter': 'dirs'});
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
      data = list;
      root = newRoot;
    });

    /**
     * {
        "files": [
        {
        "space_total": 113850953728,
        "space_free": 59749588992,
        "label": "内部存储设备",
        "mount": "/storage/emulated/0",
        "icon_id": "7f080155",
        "has_children": true,
        "n": "0",
        "t": 0
        },
        {
        "space_total": 62505615360,
        "space_free": 62460264448,
        "label": "Transcend SD 卡",
        "mount": "/storage/0123-4567",
        "icon_id": "7f080181",
        "has_children": true,
        "n": "0123-4567",
        "t": 0
        },
        {
        "space_total": 160033669120,
        "space_free": 140828213248,
        "label": "SWITHUN",
        "mount": "/mnt/media_rw/64EA-D541",
        "icon_id": "7f08018d",
        "has_children": true,
        "n": "64EA-D541",
        "t": 0
        },
        {
        "space_total": 113850953728,
        "space_free": 59749556224,
        "label": "Root",
        "mount": "/",
        "icon_id": "7f080155",
        "fs": "root",
        "has_children": true,
        "n": "",
        "t": 0
        }
        ],
        "device_name": "Xiaomi MI 8 Lite",
        "device_uuid": -6095460998045790991,
        "hasDon": true
        }
        解析出每一个
        {
        "space_total": 113850953728,
        "space_free": 59749588992,
        "label": "内部存储设备",
        "mount": "/storage/emulated/0",
        "icon_id": "7f080155",
        "has_children": true,
        "n": "0",
        "t": 0
        },
     */
  }
}
