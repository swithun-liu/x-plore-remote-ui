import 'package:x_plore_remote_ui/model/Path.dart';

abstract class IFileRepo {
  void init();
  List<DirectoryData> getDirectory();
}