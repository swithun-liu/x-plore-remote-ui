import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/repo/v2/IFileRepo.dart';
import 'package:x_plore_remote_ui/repo/v2/SmbaFileRepo.dart';
import 'package:x_plore_remote_ui/util/MovieNameMatcher.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';
import 'package:x_plore_remote_ui/view/component/post_item/post_item_view.dart';

class PostWallPage extends StatefulWidget {
  String Function() getVideoRootPath;
  String Function() getIp;
  void Function(VideoSource videoSource) copyFileUrlToClipboard;

  PostWallPage(
      this.getVideoRootPath,
      this.getIp,
      this.copyFileUrlToClipboard,
      {super.key}
      );

  @override
  State<PostWallPage> createState() => _PostWallPageState();
}

class _PostWallPageState extends State<PostWallPage> with AutomaticKeepAliveClientMixin{
  Logger logger = Logger();
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
    String ip = widget.getIp();
    var url = Uri.http('$ip:1111', path, {'cmd': 'list'});
    var urlStr = url.toString();
    logger.d("postwallpage $urlStr");
    FolderData root = FolderData("root", 0, path, 0);
    await fileRepo.getChildren(root, ip);
    iParsePostItems(root, posts);
    logger.d("postwallpage posts ${posts.length}");
    setState(() { });
  }

  void refreshDataV2() async {
    posts = [];
    logger.d("[refreshDataV2] posts ${posts.length}");
    FolderData root = FolderData("", 0, "" ,0);
    var children = await repoV2.getPaths(root, root.level);
    root.children = children;
    var mediaInfoMap = Map<String, List<MediaInfo>>();
    await iParsePostItemsV2(root, posts, mediaInfoMap);
    logger.d("[refreshDataV2] postwallpage posts ${posts.length} ${mediaInfoMap.keys}");
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return wallPage();
  }

  Future<void> iParsePostItemsV2(FolderData current, List<PostItemUIData> posts, Map<String, List<MediaInfo>> mediaInfoMap) async {
    for (var c in current.children) {
      if (c.runtimeType == FileData) {
        var child = c as FileData;
        logger.d("[refreshDataV2]: file ${child.path}");
        var mediaInfo = extractMediaInfo(child.name);
        var oldMediaInfoList = mediaInfoMap[mediaInfo.name];
        if (oldMediaInfoList == null) {
          var newMediaInfoList = [ mediaInfo ];
          mediaInfoMap[mediaInfo.name] = newMediaInfoList;
        } else {
          oldMediaInfoList.add(mediaInfo);
        }
      } else if (c.runtimeType == FolderData) {
        var child = c as FolderData;
        logger.d("[refreshDataV2]: folder ${child.path}");
        var childChildren = await repoV2.getPaths(child, child.level);
        child.children = childChildren;
        iParsePostItemsV2(child, posts, mediaInfoMap);
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
              return element.path.endsWith("mp4") || element.path.endsWith("mkv");
            });
          } catch(e) { }

          Uri? thumbnailUrl = null;

          if (thumbnailVideoChild != null) {
            String ip = widget.getIp();
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
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.75),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.green,
          child: PostItemView(widget.getIp, widget.copyFileUrlToClipboard, posts[index]),
        );
      },
      itemCount: posts.length,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
