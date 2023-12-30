// 接口Path，两个实现类 File 和 Folder
abstract class DirectoryData {
  String name;
  int size;
  String path;
  int level;

  DirectoryData(this.name, this.size, this.path, this.level);

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

class FileData extends DirectoryData {
  FolderData parent;
  FileData(String name, int size, String path, int level, this.parent)
      : super(name, size, path, level);
}

class FolderData extends DirectoryData {
  bool isOpen = false;
  List<DirectoryData> children = [];

  FolderData(String name, int size, String path, int leve,
      {this.isOpen = false})
      : super(name, size, path, leve);
}