import '../../model/Path.dart';

class DirectoryUIData {
  DirectoryType type;
  String path;
  String name;
  int level;
  PathData originalPath;

  DirectoryUIData(this.type, this.path, this.name, this.level, this.originalPath);
}

class FolderUIData extends DirectoryUIData {
  bool wasOpen;
  bool isOpen;

  FolderUIData(super.type, super.path, super.name, super.level, super.originalPath, this.wasOpen, this.isOpen);


}

class FileUIData extends DirectoryUIData {

  FileUIData(super.type, super.path, super.name, super.level, super.originalPath);


}

enum DirectoryType { FILE, FOLDER }
