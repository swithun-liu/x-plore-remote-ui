import 'dart:core';

class MediaInfo {
  final String name;
  final bool isMovie;

  MediaInfo(this.name, this.isMovie);
}

MediaInfo extractMediaInfo(String fileName) {
  // 定义正则表达式
  final movieRegex = RegExp(r'^(.*?)(?:\.\d{4})?(?:\.\d{3,4}p)?(?:\..*)?$');
  final tvShowRegex = RegExp(r'^(.*?)(?:\.\d{4})?(?:\.[Ss]\d{2}[Ee]\d{2})(?:\..*)?$');
  final sitePrefixRegex = RegExp(r'^\[.*?\](.*?)(?:\-\d{4})?(?:_.*)?(?:\..*)?$');

  // 先尝试匹配带网站前缀的文件名
  final sitePrefixMatch = sitePrefixRegex.firstMatch(fileName);
  if (sitePrefixMatch != null && sitePrefixMatch.groupCount >= 1) {
    return MediaInfo(sitePrefixMatch.group(1)!.replaceAll('.', ' ').trim(), true);
  }

  // 尝试匹配电视剧
  final tvMatch = tvShowRegex.firstMatch(fileName);
  if (tvMatch != null && tvMatch.groupCount >= 1) {
    return MediaInfo(tvMatch.group(1)!.replaceAll('.', ' ').trim(), false);
  }

  // 尝试匹配电影
  final movieMatch = movieRegex.firstMatch(fileName);
  if (movieMatch != null && movieMatch.groupCount >= 1) {
    return MediaInfo(movieMatch.group(1)!.replaceAll('.', ' ').trim(), true);
  }

  // 如果都不匹配，则返回原始文件名并标记为未知类型
  return MediaInfo(fileName, true); // 默认假设为电影
}

void main() {
  // 示例文件名
  final fileNames = [
    '流浪地球.2019.1080p.x264.mp4',
    'Ghosted.1080p.x264.mp4',
    '琅琊榜.S01E01.1080p.AMZN.WEB.DL.mkv',
    'Shameless.2011.S02E02.1080p.AMZN.WEB.DL.mkv',
    '琅琊榜.S00E01.SneakPeek.1080p.AMZN.mkv',
    '[电影天堂www.dytt89.com]奥本海默-2023_BD中英双字.mp4'
  ];

  for (var fileName in fileNames) {
    final info = extractMediaInfo(fileName);
    print('File: $fileName');
    print('Name: ${info.name}');
    print('Type: ${info.isMovie ? "Movie" : "TV Show"}\n');
  }
}
