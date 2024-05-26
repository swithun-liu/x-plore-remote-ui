import 'package:logger/logger.dart';
import 'package:samba_browser/samba_browser.dart';
import 'package:x_plore_remote_ui/channel/SMBChannel.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/repo/v2/IFileRepo.dart';

class SmbFileRepo implements IFileRepo {

  Logger logger = Logger();

  @override
  void init() {

  }

  @override
  Future<List<PathData>> getPaths(String parent, int level) async {
    String parentPath = "";
    if (parent != '-') {
      parentPath = parent;
    }

    List<Object?> paths = await SMBChannel.getPathList(parent);
    logger.d("[getPathList] $paths}");

    List<PathData> pathDatas = paths.map((path)=>
      FolderData(path as String, 0, "$parent\\$path", level +1)
    ).toList();

    return pathDatas;
  }

}