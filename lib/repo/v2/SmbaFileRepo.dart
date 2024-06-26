import 'package:logger/logger.dart' as CommonLog;
import 'package:tmdb_api/tmdb_api.dart';
import 'package:x_plore_remote_ui/Extensions.dart';
import 'package:x_plore_remote_ui/channel/SMBChannel.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/repo/v2/IFileRepo.dart';
import 'package:x_plore_remote_ui/util/FileUtil.dart';

class SmbFileRepo implements IFileRepo {

  CommonLog.Logger logger = CommonLog.Logger();

  @override
  void init() {

  }

  @override
  Future<List<PathData>> getPaths(FolderData parent, int level) async {
    List<Object?> paths = await SMBChannel.getPathList(parent.path);
    logger.d("[getPathList] for ${parent.path} | ${paths.length} | $paths}");

    List<PathData> pathDatas = paths.mapNotNull((childName) {
      var childPath = "${parent.path}/$childName";
      if (childName == "." || childName == "..") {
        return null;
      } else if (FileUtil.isFile(childName as String)) {
        return FileData(childName as String, 0, childPath, level + 1, parent);
      } else {
        return FolderData(childName as String, 0, childPath , level + 1);
      }
    }).toList();

    // testScrap();

    return pathDatas;
  }


}