import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';

class CoverItem extends StatefulWidget {
  PostItemUIData folderPath;
  String ip;

  CoverItem(this.ip, this.folderPath, {super.key});

  @override
  State<CoverItem> createState() => _CoverItemState();
}

class _CoverItemState extends State<CoverItem> {
  String? url;
  FileRepo fileRepo = FileRepo();
  Uint8List? _thumbnailBytes;
  Logger logger = Logger();

  @override
  void initState() {
    readVideoInfo();
  }

  readVideoInfo() async {
    logger.d('thumbnail ${widget.folderPath.thumbnailVideoUrl.toString()}');
    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: widget.folderPath.thumbnailVideoUrl.toString(),
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    setState(() {
      _thumbnailBytes = thumbnailBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.folderPath.thumbnailVideoUrl.toString(),
      fit: BoxFit.fitHeight,
      height: double.infinity,
    );
  }
  //   var u = _thumbnailBytes;
  //   return u == null
  //       ? const Icon(Icons.local_movies, size: 100,)
  //       : Image.network(
  //           widget.folderPath.thumbnailVideoUrl.toString(),
  //           fit: BoxFit.fitHeight,
  //           height: double.infinity,
  //         );
  // }
}
