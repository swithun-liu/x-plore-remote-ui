// 接口Path，两个实现类 File 和 Folder
abstract class PathData {
  String name;
  int size;
  String path;
  int level;

  PathData(this.name, this.size, this.path, this.level);

  String getPath() {
    return path;
  }

  String getName() {
    return name;
  }

  int getSize() {
    return size;
  }

}

class FileData extends PathData {
  FolderData parent;
  FileData(String name, int size, String path, int level, this.parent)
      : super(name, size, path, level);
}

class FolderData extends PathData {
  bool isOpen = false;
  List<PathData> children = [];

  FolderData(String name, int size, String path, int leve,
      {this.isOpen = false})
      : super(name, size, path, leve);
}