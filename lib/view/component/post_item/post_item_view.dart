import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/model/Setting.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/util/CommonUtil.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';
import 'package:x_plore_remote_ui/view/component/post_item/post_item_bloc.dart';

import '../../../model/Path.dart';
import '../../../repo/FileRepo.dart';
import '../post/widget/CoverItem.dart';

class PostItemView extends StatefulWidget {

  PostItemUIData post;
  void Function(VideoSource videoSource) copyFileUrlToClipboard;

  PostItemView(this.copyFileUrlToClipboard, this.post, {super.key});

  @override
  State<PostItemView> createState() => _PostItemViewState();
}

class _PostItemViewState extends State<PostItemView> {

  Logger logger = Logger();
  FileRepo fileRepo = FileRepo();
  CommonUtil util = CommonUtil();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostItemBloc(PostItemNormal(widget.post)),
      child: BlocBuilder<PostItemBloc, PostItemState>(
        builder: (context, state) {
          logger.d("PostItemBlocBuilder $state");
          Widget widget = const Placeholder();
          if (state is PostItemNormal) {
            widget = _buildPostItemView((state as PostItemNormal).postData);
          }
          return widget;
        },
      ),
    );
  }

  Widget _buildPostItemView(PostItemUIData uiData) {
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
              height: double.infinity,
              color: Colors.yellow['lighter'],
              child: CoverItem(SettingStore.getIp(), uiData),
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

  void tapPostItem(String path) async {
    var logger = Logger();
    var parent = FolderData('', 0, path, 0);
    await fileRepo.getOnlyNextChildren(parent, SettingStore.getIp());
    List<FileData> files = [];
    logger.d('tapPostItem children: ${parent.children.length}');
    parent.children.forEach((element) {
      if (element.runtimeType == FileData) {
        var file = element as FileData;
        files.add(file);
      }
    });
    logger.d('tapPostItem files: ${files.length}');
    // ignore: use_build_context_synchronously
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
    HTTPVideoSourceGroup videoSource =  util.buildHttpVideoSourceGroup(util.filterVideoFile(file.parent.children), file);
    widget.copyFileUrlToClipboard(videoSource);
    setState(() {

    });
  }

  getVideoInfo(String parentFolderPath) async {
  }

}
