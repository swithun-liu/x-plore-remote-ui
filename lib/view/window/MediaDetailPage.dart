import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/eventbus/EventBus.dart';
import 'package:x_plore_remote_ui/main.dart';
import 'package:x_plore_remote_ui/model/VideoSource.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';

import '../../util/MovieNameMatcher.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaDetailPageData data;

  MediaDetailPage({required this.data});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {

  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 200,
                height: 300,
                child: Image.network(
                  widget.data.uiData.thumbnailVideoUrl?.toString() ?? "",
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
          Expanded(child:
              ListView.builder(
                itemCount: widget.data.uiData.mediaInfos.length,
                itemBuilder: (context, index) {
                  return buildMediaNameItem(widget.data.uiData.mediaInfos[index], index);
                },
              )
          )
        ],
      ),
    );
  }

  void _onTap(MediaInfo mediaInfo, int index) {
    logger.d("Tapped on ${mediaInfo.name} $index ${mediaInfo.path}");
    ALL_EVENTS.eventBus.fire(ChangeVideoSourceEvent(HTTPVideoSourceGroup(
        widget.data.uiData.mediaInfos.map((e) => e.getUrlPath()).toList(),
        index)));
    ALL_EVENTS.eventBus.fire(GotoVideoPage());
    Navigator.pop(context);
  }

  Widget buildMediaNameItem(MediaInfo mediaInfo, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          _onTap(mediaInfo, index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(11),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mediaInfo.name, style: TextStyle(fontSize: 16)),
                        Text(mediaInfo.path, style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}


class MediaDetailPageData {
  final PostItemUIData uiData;

  MediaDetailPageData({required this.uiData});
}
