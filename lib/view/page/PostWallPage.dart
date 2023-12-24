import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';
import 'package:x_plore_remote_ui/view/component/post_item/post_item_view.dart';

class PostWallPage extends StatefulWidget {
  String Function() getVideoRootPath;
  String Function() getIp;
  void Function(FileData file) copyFileUrlToClipboard;

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
  FolderData root = FolderData('', 0, '', 0);


  @override
  void initState() {
    super.initState();
    refreshData();
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

  @override
  Widget build(BuildContext context) {
    return wallPage();
  }

  void iParsePostItems(FolderData current, List<PostItemUIData> posts) {
    for (var c in current.children) {
      if (c.runtimeType == FolderData) {
        FolderData child = (c as FolderData);
        // 视频文件夹
        if (child.name.startsWith('vd_')) {

          DirectoryData? thumbnailVideoChild = null;

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
