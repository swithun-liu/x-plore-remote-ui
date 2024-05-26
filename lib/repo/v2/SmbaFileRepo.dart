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
    logger.d("[getPathList] $paths}");

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

    testScrap();

    return pathDatas;
  }

  var tmdbWithCustomLogs = TMDB(
    ApiKeys('31e942957a41df2217cc2eaeb960c4b0', 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMWU5NDI5NTdhNDFkZjIyMTdjYzJlYWViOTYwYzRiMCIsInN1YiI6IjY1NmFlNGUwODg2MzQ4MDE0ZDgzYzM5YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.2oVrbs0i6kNCr_dlT09-dB1n6TLrIavyGdcFfery1I8'),
    logConfig: const ConfigLogger(
      showLogs: true,
      showErrorLogs: true
    )
  );

  void testScrap(){
    tmdbWithCustomLogs.v3.search.queryMovies('[电影天堂www.dytt89.com]奥本海默-2023_BD中英双字.mp4', region: ' ').then((result) {
      logger.d("[testScrap] [search] $result");
    }).catchError((err) {
      logger.d("[testScrap] [search] err ${err}");
    });
  }

}