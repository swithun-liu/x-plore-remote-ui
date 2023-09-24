// 接口Path，两个实现类 File 和 Folder
abstract class Path {
  String name;
  int size;
  String path;
  int level;

  Path(this.name, this.size, this.path, this.level);

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

class FileItem extends Path {
  FileItem(String name, int size, String path, int level) : super(name, size, path, level);
}

class FolderItem extends Path {
  bool isOpen = false;
  List<Path> children = [];

  FolderItem(String name, int size, String path, int leve,
      {this.isOpen = false})
      : super(name, size, path, leve);
}