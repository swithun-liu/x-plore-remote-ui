import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/model/PostUIData.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';
import 'package:x_plore_remote_ui/view/component/cover/CoverWidget.dart';

class PostWallPage extends StatefulWidget {
  String Function() getVideoRootPath;
  String Function() getIp;

  PostWallPage(this.getVideoRootPath, this.getIp, {super.key});

  @override
  State<PostWallPage> createState() => _PostWallPageState();
}

class _PostWallPageState extends State<PostWallPage> with AutomaticKeepAliveClientMixin{
  Logger logger = Logger();
  List<PostUIData> posts = [
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("1", "1"),
    PostUIData("2", "2"),
    PostUIData("3", "3"),
    PostUIData("4", "3"),
  ];

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

  void iParsePostItems(FolderData parent, List<PostUIData> posts) {
    for (var d in parent.children) {
      if (d.runtimeType == FolderData) {
        FolderData folder = (d as FolderData);
        if (folder.name.startsWith('vd_')) {
          var post = PostUIData(folder.name, folder.path);
          posts.add(post);
          iParsePostItems(folder, posts);
        }
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
          child: postItem(posts[index]),
        );
      },
      itemCount: posts.length,
    );
  }

  getVideoInfo(String parentFolderPath) async {
    await doGetVideoInfo(parentFolderPath);
    refreshData();
  }

  doGetVideoInfo(String parentFolderPath) async {

  }

  void tapPostItem(String path) async {
    var logger = Logger();
    var parent = FolderData('', 0, path, 0);
    await fileRepo.getOnlyNextChildren(parent, widget.getIp());
    List<FileData> files = [];
    logger.d('tapPostItem children: ${parent.children.length}');
    parent.children.forEach((element) {
      if (element.runtimeType == FileData) {
        var file = element as FileData;
        files.add(file);
      }
    });
    logger.d('tapPostItem files: ${files.length}');
    await showDialog(
        context: context,
        builder: (context) => ContentDialog(
        content: ListView.builder(
                  itemCount: files.length,
              itemBuilder: (context, index) {
                    var file = files[index];
                    return Button(
                      child: Text(file.name),
                      onPressed: () {
                        _copyFileUrlToClipboard(file);
                      },
                    );
            }),
          actions: [
            FilledButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, 'User canceled dialog'),
            ),
          ],
    ));
  }

  _copyFileUrlToClipboard(FileData file) {
    var logger = Logger();

    var uri = Uri.http('${widget.getIp()}:1111', file.path, {'cmd': 'file'});
    var url = uri.toString();
    logger.d('swithun-xxxx $url');
    Clipboard.setData(ClipboardData(text: url));
    displayInfoBar(context, builder: (context, close) {
      return const InfoBar(title: Text('已复制'));
    });

    setState(() {

    });
  }

  Widget postItem(PostUIData uiData) {
    var flyoutController = FlyoutController();
    return Expanded(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              tapPostItem(uiData.folderPath);
            },
            child: Container(
              width: double.infinity,
              color: Colors.yellow,
              child: CoverWidget(widget.getIp(), uiData.folderPath),
              // child: Image.network(
              //   'https://upload.wikimedia.org/wikipedia/zh/4/46/Better_Call_Saul_Season_6_DVD.jpg',
              //   fit: BoxFit.fitHeight,
              //   height: double.infinity,
              // ),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: FlyoutTarget(
                controller: flyoutController,
                child: Button(
                  child: Icon(FluentIcons.more),
                  onPressed: () {
                    flyoutController.showFlyout(builder: (context) {
                      return MenuFlyout(
                        items: [
                          MenuFlyoutItem(text: Text('获取信息'), onPressed: () {
                            this.getVideoInfo(uiData.folderPath);
                          }
                          )
                        ],
                      );
                    });
                  },
                ),
              )),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Color(0xaa484644),
                    padding: EdgeInsets.all(5),
                    child: Text(
                        uiData.name,
                        style: TextStyle(color: Colors.white),
                      ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
