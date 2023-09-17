import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  List<String> data = [
    "3",
    "1",
    "1",
    "1",
    "1",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
    "2",
    "3",
    "1",
  ];

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _editIP(),
          _buildSubmitBtn(),
          _FileList()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      onPressed: () => _getBaseFileList()
  );


  Widget _FileList() {
    return SizedBox(
        height: 100,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: data.map((e) => Text(e)).toList(),
        ));
  }

  _getBaseFileList() async {
    var logger = Logger();
    logger.d("_getBaseFileList");

    FocusScope.of(context).requestFocus(_focusNode);
    // http://192.168.31.249:1111/ query : cmd = list_root filter=dirs
    var url = Uri.http('192.168.31.249:1111', '', {'cmd': 'list_root', 'filter': 'dirs'});
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
    for (var file in files) {
      var label = file['label'];
      logger.d(label);
      list.add(label);
    }

    logger.d(list);

    setState(() {
      data = list;
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


