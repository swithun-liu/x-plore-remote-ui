import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:x_plore_remote_ui/view/component/FolderItemWidget.dart';
import 'package:x_plore_remote_ui/view/page/HistoryPage.dart';
import 'package:x_plore_remote_ui/view/page/SettingPage.dart';

import '../../model/Path.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String ip = '192.168.31.249';
  List<String> data = [];
  FolderItem root = FolderItem("root", 0, "/", -1, isOpen: false);
  int topIndex = 0;
  List<String> history = [];

  late final Box settingBox;

  // 在State类中定义一个TextEditingController对象
  final TextEditingController ipController =
  TextEditingController(text: '192.168.31.249');
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    var logger = Logger();
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
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
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
        body: SettingPage(getIP, changeIp),
      ),
      PaneItem(
        icon: const Icon(Icons.history),
        title: const Text('历史'),
        body: HistoryPage(history),
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

  void changeIp(String newIp) {
    var logger = Logger();
    logger.d("changeIp $newIp");
    ip = newIp;
    settingBox.put("ip", newIp);
  }

  String getIP() {
    return ip;
  }

  String test(String Function() getIP) {
    return "test";
  }

  void test2() {
    test(getIP);
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
          color: fluent.Colors.transparent,
          child: ListView(
            shrinkWrap: true,
            children: [buildPathItem(root, _onFolderClick, _onFileClick)],
          ),
        ));
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

  _onFileClick(FileItem file) async {
    _copyFileUrlToClipboard(file);
  }

  _onFolderClick(FolderItem folder) async {
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

    FocusScope.of(context).requestFocus(_focusNode);
    // http://192.168.31.249:1111/ query : cmd = list_root filter=dirs
    var url = Uri.http(
        '$ip:1111', '', {'cmd': 'list_root', 'filter': 'dirs'});
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
     */
  }
}
