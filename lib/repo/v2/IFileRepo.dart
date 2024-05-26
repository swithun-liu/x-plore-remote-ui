import 'package:x_plore_remote_ui/model/Path.dart';

abstract class IFileRepo {
  void init();
  Future<List<PathData>> getPaths(FolderData parent, int level);
}