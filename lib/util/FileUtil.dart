import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:path/path.dart' as p;


class FileUtil {
  
  static bool isFile(String path) {
    return p.extension(path).isNotEmpty;
  }

}