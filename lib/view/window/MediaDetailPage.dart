import 'dart:ui';

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
    return Stack(
      children: [
        Positioned.fill(
          child: Expanded(
            child: Container(
              color: Colors.black,
              child: Image.network(
                widget.data.uiData.thumbnailVideoUrl?.toString() ?? "",
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top), // 状态栏高度
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // thumbnail
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 16.0, bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(0.5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 200,
                                    height: 300,
                                    child: Image.network(
                                      widget.data.uiData.thumbnailVideoUrl
                                              ?.toString() ??
                                          "",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          
                      // 简介
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 26.0, bottom: 16.0, right: 8.0),
                          child: Column(
                            // 左上对齐
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.data.uiData.name,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: widget.data.uiData.mediaInfos.length,
                    itemBuilder: (context, index) {
                      return buildMediaNameItem(
                          widget.data.uiData.mediaInfos[index], index);
                    },
                  ))
                ],
              ),
            ),
          ),
        ),
      ],
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
                        Text(mediaInfo.path,
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
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
