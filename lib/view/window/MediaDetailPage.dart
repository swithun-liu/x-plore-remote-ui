import 'package:flutter/material.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaDetailPageData data;

  MediaDetailPage({required this.data});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
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
                  return Text(widget.data.uiData.mediaInfos[index].name);
                },
              )
          )
        ],
      ),
    );
  }
}

class MediaDetailPageData {
  final PostItemUIData uiData;

  MediaDetailPageData({required this.uiData});
}
