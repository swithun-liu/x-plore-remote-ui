import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Directory.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/view/component/navigationview/NavigationView.dart';
import 'package:x_plore_remote_ui/view/page/FileListPage.dart';
import 'package:x_plore_remote_ui/view/page/HistoryPage.dart';
import 'package:x_plore_remote_ui/view/page/SettingPage.dart';
import 'package:x_plore_remote_ui/view/page/VideoPage.dart';

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
  VideoSource? videoSource;

  late final Box settingBox;
  bool fullScreeVideo = false;

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

  void updateVideoSource(String url) {
    setState(() {
      videoSource = HTTPVideoSource(url);
    });
  }

  bool getIsFullScreen() {
    return fullScreeVideo;
  }

  void changeFullScreen(bool isfull) {
    setState(() {
      fullScreeVideo = isfull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwithunNavigationView(
        updateVideoSource,
        videoSource,
        getIP,
        changeIp,
        history,
        getIsFullScreen,
        changeFullScreen,
        setVideoRootPath,
        getVideoRootPath,
        getIp,
        copyVideoLinkAndChangePlaying
    );
  }

  String getIp() {
    return settingBox.get("ip");
  }

  void setVideoRootPath(FolderUIData directory) {
    String path = directory.path;
    settingBox.put("video_root", path);
  }

  String getVideoRootPath() {
    return settingBox.get("video_root");
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


  void copyVideoLinkAndChangePlaying(FileData file) {
    var logger = Logger();

    var uri = Uri.http('$ip:1111', file.path, {'cmd': 'file'});
    var url = uri.toString();
    logger.d('swithun-xxxx $url');
    Clipboard.setData(ClipboardData(text: url));
    updateVideoSource(url);
    displayInfoBar(context, builder: (context, close) {
      return const InfoBar(title: Text('已复制'));
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

  void test2() {
    test(getIP);
  }
}
