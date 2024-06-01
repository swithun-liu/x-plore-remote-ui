import '../../../../util/MovieNameMatcher.dart';

class PostItemUIData {
  String folderPath;
  String name;
  Uri? thumbnailVideoUrl;
  List<MediaInfo> mediaInfos;

  PostItemUIData(this.name, this.folderPath, this.thumbnailVideoUrl, this.mediaInfos);
}