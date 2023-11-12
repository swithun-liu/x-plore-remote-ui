import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/view/page/FileListPage.dart';
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
  FolderData root = FolderData("root", 0, "/", -1, isOpen: false);
  int topIndex = 0;
  List<String> history = [];

  late final Box settingBox;

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
        // body: _NavigationBodyItem(),
        body: FileListPage(),
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

}
