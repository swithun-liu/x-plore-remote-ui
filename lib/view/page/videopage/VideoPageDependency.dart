import 'package:x_plore_remote_ui/model/VideoSource.dart';

class VideoPageDependency {
  void Function(VideoSource videoSource) copyFileUrlToClipboard;
  String Function() getIp;
  VideoPageDependency(this.copyFileUrlToClipboard, this.getIp);

}