// 接口Path，两个实现类 File 和 Folder
abstract class Path {
  String name;
  int size;
  String path;

  Path(this.name, this.size, this.path);

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
  FileItem(String name, int size, String path) : super(name, size, path);
}

class FolderItem extends Path {
  bool isOpen = false;
  List<Path> children = [];

  FolderItem(String name, int size, String path,
      {this.isOpen = false})
      : super(name, size, path);
}