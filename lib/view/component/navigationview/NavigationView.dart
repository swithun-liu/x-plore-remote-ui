import 'package:fluent_ui/fluent_ui.dart';
import 'package:x_plore_remote_ui/eventbus/EventBus.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/view/page/PostWallPage.dart';
import 'package:x_plore_remote_ui/view/page/videopage/VideoPageDependency.dart';

import '../../../model/Directory.dart';
import '../../../model/Setting.dart';
import '../../page/FileListPage.dart';
import '../../page/HistoryPage.dart';
import '../../page/SettingPage.dart';
import '../../page/videopage/VideoPage.dart';

class SwithunNavigationView extends StatefulWidget {
  void Function(String url) updateVideoSource;
  VideoSource? videoSource;
  List<String> history;
  bool Function() getIsFullScreen;
  void Function(bool isfull) changeFullScreen;
  void Function(FolderUIData directory) setVideoRootPath;
  String Function() getVideoRootPath;
  void Function(VideoSource videoSource) copyFileUrlToClipboard;

  SwithunNavigationView(
      this.updateVideoSource,
      this.videoSource,
      this.history,
      this.getIsFullScreen,
      this.changeFullScreen,
      this.setVideoRootPath,
      this.getVideoRootPath,
      this.copyFileUrlToClipboard,
      {super.key});

  @override
  State<SwithunNavigationView> createState() => _SwithunNavigationViewState();
}

class _SwithunNavigationViewState extends State<SwithunNavigationView> {
  List<SidebarItemData> sidebarItems = [
    SidebarItemData('fileList', FluentIcons.home),
    SidebarItemData('PosterWall', FluentIcons.box_play_solid),
    SidebarItemData('video', FluentIcons.video),
    SidebarItemData('setting', FluentIcons.settings),
    SidebarItemData('history', FluentIcons.history)
  ];
  int page_index = 0;
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: widget.getIsFullScreen() ? 0.0 : 1.0,
            duration: Duration(milliseconds: 500),
            child: Visibility(
              visible: !widget.getIsFullScreen(),
              child: sidebar(),
            ),
          ),
          pages()
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ALL_EVENTS.eventBus.on<GotoVideoPage>().listen((event) {
      setState(() {
        gotoPage(2);
      });
    });
  }

  Widget pages() {
    return Expanded(
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        controller: _pageController,
        children: [
          Container(
              color: Colors.white,
              child: FileListPage(widget.updateVideoSource,
                  widget.setVideoRootPath, widget.copyFileUrlToClipboard)),
          Container(
            color: Colors.white,
            child: PostWallPage(
                widget.getVideoRootPath, widget.copyFileUrlToClipboard),
          ),
          Container(
              color: Colors.black,
              child: VideoPage(
                  widget.videoSource,
                  widget.getIsFullScreen,
                  widget.changeFullScreen,
                  VideoPageDependency(
                      widget.copyFileUrlToClipboard, SettingStore.getIp))),
          Container(
            color: Colors.white,
            child: SettingPage(),
          ),
          Container(color: Colors.white, child: HistoryPage(widget.history)),
        ],
      ),
    );
  }

  Widget sidebar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Container(
        width: 50,
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sidebarItems.length,
            itemBuilder: (context, index) {
              var e = sidebarItems[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    gotoPage(index);
                  });
                },
                child: Container(
                  width: 30,
                  height: 35,
                  margin: const EdgeInsets.only(
                      left: 5, right: 5, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[70],
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 0))
                    ],
                  ),
                  child: Icon(
                    e.icon,
                    color: Colors.grey[170],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void gotoPage(int index) {
    if ((page_index - index).abs() > 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }

    page_index = index;
  }
}

class SidebarItemData {
  String name;
  IconData icon;

  SidebarItemData(this.name, this.icon);
}
