import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../model/Path.dart';

class FileRepo {

  /// 获取 Folder下层所有文件/不包括文件夹
  getOnlyNextChildren(FolderData parent, String ip) async {
    var logger = Logger();
    var url = Uri.http('$ip:1111', parent.path, {'cmd': 'list'});

    var urlStr = url.toString();

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
    // 如果有 has_children 字段，就是文件夹，否则就是文件，拼成FolderItem和FileItem
    List<PathData> children = [];
    for (var file in files) {
      var hasChildren = file['has_children'];
      var name = file['n'];
      var size = file['size'];
      var childPath = '${parent.path}/$name';
      var childLevel = parent.level + 1;
      if (hasChildren != null) {
        FolderData child = FolderData(name, 0, childPath, childLevel);
        children.add(child);
      } else {
        children.add(FileData(name, 0, childPath, childLevel, parent));
      }
    }
    logger.d("FileRepo ${children.length}");
    children.sort((a, b) => a.name.compareTo(b.name));
    parent.children = children;
  }

  /// 递归获取下层所有目录
  getChildren(FolderData parent, String ip) async {
    var logger = Logger();
    var url = Uri.http('$ip:1111', parent.path, {'cmd': 'list'});

    var urlStr = url.toString();

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
    // 如果有 has_children 字段，就是文件夹，否则就是文件，拼成FolderItem和FileItem
    List<PathData> children = [];
    for (var file in files) {
      var hasChildren = file['has_children'];
      var name = file['n'];
      var size = file['size'];
      var childPath = '${parent.path}/$name';
      var childLevel = parent.level + 1;
      if (hasChildren != null) {
        FolderData child = FolderData(name, 0, childPath, childLevel);
        await getChildren(child, ip);
        children.add(child);
      } else {
        children.add(FileData(name, 0, childPath, childLevel, parent));
      }
    }
    children.sort((a, b) => a.name.compareTo(b.name));
    logger.d("FileRepo ${children.length}");
    parent.children = children;
  }

  Future<String> readVideoInfo(String ip, String folderPath) async {
    var logger = Logger();
    var url = Uri.http('$ip:1111', '${folderPath}/info.json', {'cmd': 'file'});
    var response = await http.get(url, headers: {
      "User-Agent": "Apifox/1.0.0 (https://www.apifox.cn)",
      "Accept": "*/*",
      "Access-Control-Allow-Origin": "*"
    });

    // uf8解析body
    var json = jsonDecode(utf8.decode(response.bodyBytes));

    var cover = json['cover'];
    logger.d("readVideoInfo $cover");

    return cover;
  }

}