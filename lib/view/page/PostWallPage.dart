import 'dart:ffi';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart' as SysLogger;
import 'package:tmdb_api/tmdb_api.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/repo/v2/IFileRepo.dart';
import 'package:x_plore_remote_ui/repo/v2/SmbaFileRepo.dart';
import 'package:x_plore_remote_ui/util/MovieNameMatcher.dart';
import 'package:x_plore_remote_ui/util/ScrapUtil.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';
import 'package:x_plore_remote_ui/view/component/post_item/post_item_view.dart';

import '../../model/Setting.dart';

class PostWallPage extends StatefulWidget {
  String Function() getVideoRootPath;
  void Function(VideoSource videoSource) copyFileUrlToClipboard;

  PostWallPage(this.getVideoRootPath, this.copyFileUrlToClipboard, {super.key});

  @override
  State<PostWallPage> createState() => _PostWallPageState();
}

class _PostWallPageState extends State<PostWallPage>
    with AutomaticKeepAliveClientMixin {
  SysLogger.Logger logger = SysLogger.Logger();
  List<PostItemUIData> posts = [];

  FileRepo fileRepo = FileRepo();
  IFileRepo repoV2 = SmbFileRepo();
  FolderData root = FolderData('', 0, '', 0);

  @override
  void initState() {
    super.initState();
    refreshDataV2();
  }

  void refreshData() async {
    posts = [];

    String path = widget.getVideoRootPath();
    String ip = SettingStore.getIp();
    var url = Uri.http('$ip:1111', path, {'cmd': 'list'});
    var urlStr = url.toString();
    logger.d("postwallpage $urlStr");
    FolderData root = FolderData("root", 0, path, 0);
    await fileRepo.getChildren(root, ip);
    iParsePostItems(root, posts);
    logger.d("postwallpage posts ${posts.length}");
    setState(() {});
  }

  void refreshDataV2() async {
    posts = [];
    logger.d("[refreshDataV2] posts ${posts.length}");
    FolderData root = FolderData("", 0, "", 0);
    var children = await repoV2.getPaths(root, root.level);
    root.children = children;
    var mediaInfoMap = Map<String, List<MediaInfo>>();
    await iParsePostItemsV2(root, posts, mediaInfoMap);
    logger.d(
        "[refreshDataV2] postwallpage posts ${posts.length} ${mediaInfoMap.keys} ${mediaInfoMap.keys.length}");
    for (var key in mediaInfoMap.keys) {
      var result =
          await ScrapUtil.scrapMedia(key, mediaInfoMap[key]![0].isMovie);
      var postUrl = result?.postUrl ?? "";
      var uri = Uri.parse("https://image.tmdb.org/t/p/w500$postUrl");
      posts.add(PostItemUIData(key, key, uri));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return wallPage();
  }

  var tmdbWithCustomLogs = TMDB(
      ApiKeys('31e942957a41df2217cc2eaeb960c4b0',
          'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMWU5NDI5NTdhNDFkZjIyMTdjYzJlYWViOTYwYzRiMCIsInN1YiI6IjY1NmFlNGUwODg2MzQ4MDE0ZDgzYzM5YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.2oVrbs0i6kNCr_dlT09-dB1n6TLrIavyGdcFfery1I8'),
      logConfig: const ConfigLogger(showLogs: true, showErrorLogs: true));

  Future<String> testScrap(String name, bool isMove) async {
    var url = "";

    try {
      var result = await tmdbWithCustomLogs.v3.search.queryMovies(name);
      var innerResult = result['results'];
      if (innerResult == null) {
        return "";
      }
      var firstResult = innerResult[0];
      if (firstResult == null) {
        return "";
      }

      url = firstResult['poster_path'];
      logger.d("[TMDB] result $url");
    } catch (exception) {
      logger.d("[TMDB] result err $exception");
    }

    return url;
  }

  Future<void> iParsePostItemsV2(FolderData current, List<PostItemUIData> posts,
      Map<String, List<MediaInfo>> mediaInfoMap) async {
    for (var c in current.children) {
      if (c.runtimeType == FileData) {
        var child = c as FileData;
        logger.d("[refreshDataV2]: file ${child.path}");
        var mediaInfo = extractMediaInfo(child.name, child.path);
        var oldMediaInfoList = mediaInfoMap[mediaInfo.name];
        if (oldMediaInfoList == null) {
          var newMediaInfoList = [mediaInfo];
          mediaInfoMap[mediaInfo.name] = newMediaInfoList;
        } else {
          oldMediaInfoList.add(mediaInfo);
        }
      } else if (c.runtimeType == FolderData) {
        var child = c as FolderData;
        logger.d("[refreshDataV2]: folder ${child.path}");
        var childChildren = await repoV2.getPaths(child, child.level);
        child.children = childChildren;
        await iParsePostItemsV2(child, posts, mediaInfoMap);
      }
    }
  }

  void iParsePostItems(FolderData current, List<PostItemUIData> posts) {
    for (var c in current.children) {
      if (c.runtimeType == FolderData) {
        FolderData child = (c as FolderData);
        // 视频文件夹
        if (child.name.startsWith('vd_')) {
          PathData? thumbnailVideoChild = null;

          try {
            thumbnailVideoChild = current.children.firstWhere((element) {
              return element.path.endsWith("mp4") ||
                  element.path.endsWith("mkv");
            });
          } catch (e) {}

          Uri? thumbnailUrl = null;

          if (thumbnailVideoChild != null) {
            String ip = SettingStore.getIp();
            thumbnailUrl = Uri.http(
                '$ip:1111', thumbnailVideoChild.path, {'cmd': 'thumbnail'});
          }

          var post = PostItemUIData(child.name, child.path, thumbnailUrl);
          posts.add(post);
        }

        iParsePostItems(child, posts);
      }
    }
  }

  Widget wallPage() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        // 20dp top padding
        children: [
          Button(child: Text("Refresh"), onPressed: refreshDataV2),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150.0,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.green,
                  child:
                      PostItemView(widget.copyFileUrlToClipboard, posts[index]),
                );
              },
              itemCount: posts.length,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
