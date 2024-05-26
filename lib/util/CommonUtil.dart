import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';

class CommonUtil {

  var logger = Logger();

  bool isVideo(String path) {
    return path.endsWith('mp4') || path.endsWith("mkv");
  }

  List<FileData> filterVideoFile(List<PathData> children) {
    List<FileData> files = [];
    children.forEach((child) {
      if (child is FileData && isVideo(child.path)) {
        files.add(child);
      }
    });
    return files;
  }

  HTTPVideoSourceGroup buildHttpVideoSourceGroup(List<FileData> fileChildren,
      FileData file) {
    int pos = -1;
    List<String> urls = [];

    for (var (i, child) in fileChildren.indexed) {
      urls.add(child.path);
      if (child.path == file.path) {
        pos = i;
      }
    }


    return HTTPVideoSourceGroup(urls, pos);
  }

  HTTPVideoSource buildV2HttpVideoSource(FileData file) {

    var path = "http://localhost:8080/?path=${file.path}";
    logger.d("[CommonUtil] [buildV2HttpVideoSource] $path");

    return HTTPVideoSource(path);
  }


}