import 'package:fluent_ui/fluent_ui.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/view/page/PostWallPage.dart';
import 'package:x_plore_remote_ui/view/page/videopage/VideoPageDependency.dart';

import '../../../model/Directory.dart';
import '../../../model/Path.dart';
import '../../page/FileListPage.dart';
import '../../page/HistoryPage.dart';
import '../../page/SettingPage.dart';
import '../../page/videopage/VideoPage.dart';

class SwithunNavigationView extends StatefulWidget {
  void Function(String url) updateVideoSource;
  VideoSource? videoSource;
  String Function() getIp;
  String Function() getName;
  String Function() getPassword;
  String Function() getPath;
  void Function(String newIp) changeIp;
  void Function(String newIp) changeName;
  void Function(String newIp) changePassword;
  void Function(String newIp) changePath;
  List<String> history;
  bool Function() getIsFullScreen;
  void Function(bool isfull) changeFullScreen;
  void Function(FolderUIData directory) setVideoRootPath;
  String Function() getVideoRootPath;
  void Function(VideoSource videoSource) copyFileUrlToClipboard;

  SwithunNavigationView(
      this.updateVideoSource,
      this.videoSource,
      this.changeIp,
      this.changeName,
      this.changePassword,
      this.changePath,
      this.history,
      this.getIsFullScreen,
      this.changeFullScreen,
      this.setVideoRootPath,
      this.getVideoRootPath,
      this.getIp,
      this.getName,
      this.getPassword,
      this.getPath,
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
            child: PostWallPage(widget.getVideoRootPath, widget.getIp,
                widget.copyFileUrlToClipboard),
          ),
          Container(
              color: Colors.black,
              child: VideoPage(
                  widget.videoSource,
                  widget.getIsFullScreen,
                  widget.changeFullScreen,
                  VideoPageDependency(
                      widget.copyFileUrlToClipboard, widget.getIp))),
          Container(
            color: Colors.white,
            child: SettingPage(
                widget.getIp,
                widget.getName,
                widget.getPassword,
                widget.getPath,
                widget.changeIp,
                widget.changeName,
                widget.changePassword,
                widget.changePath),
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
                    page_index = index;
                    _pageController.animateToPage(index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
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
}

class SidebarItemData {
  String name;
  IconData icon;

  SidebarItemData(this.name, this.icon);
}
