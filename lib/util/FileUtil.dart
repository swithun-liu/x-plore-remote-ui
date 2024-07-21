import 'dart:io';

import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:path/path.dart' as p;


class FileUtil {
  
  static bool isFile(String path) {
    var ext = p.extension(path);
    return (ext.isNotEmpty && commonExtensions.contains(ext));
  }

  static String fileExt(String name) {
    return p.extension(name);
  }


  static final commonExtensions = ['.txt', '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.png', '.jpg', '.jpeg', '.gif', '.mp4', '.mp3', '.mkv', '.avi', '.zip', '.rar'];

}