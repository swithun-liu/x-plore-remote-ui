import 'dart:convert';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart' as material;

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
  FolderItem root = FolderItem("root", 0, "/", isOpen: true);
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
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     title: Text(widget.title),
    //   ),
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       _editIP(),
    //       _buildSubmitBtn(),
    //       _FileList()
    //     ],
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );

    root.isOpen = true;
    // root.children = [
    //   FileItem("f1", 0, '/'),
    //   FileItem("f1", 0, '/'),
    //   FolderItem("fo1", 0, '/'),
    //   FolderItem("fo1", 0, '/')
    // ];

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
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: <Widget>[_editIP(), _buildSubmitBtn(), _FileList()],
    // );
  }

  Widget _PathTree() {
    return SizedBox(width: 300, child: _buildPathItem(root));
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
    return Button(child: Text(file.name), onPressed: () => {} );
  }

  Widget _buildFolderItem(FolderItem folder) {
    return Expander(
      header: Text(folder.name),
      content: ListView(
        shrinkWrap: true,
        children: [..._buildFolderChildren(folder)],
      ),
      onStateChanged: (open) {
        setState(() {
          folder.isOpen = open;
          if (folder.path == '/') {
            _getBaseFileList();
          } else {
            _getChildFileList(folder);
          }
        });
      },
    );
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

    var url = Uri.http(
        '192.168.31.249:1111', parent, {'cmd': 'list'});

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
        pathList.add(FolderItem(name, 0, path));
      } else {
        pathList.add(FileItem(name, 0, path));
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

      pathList.add(FolderItem(label, 0, mount));

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
