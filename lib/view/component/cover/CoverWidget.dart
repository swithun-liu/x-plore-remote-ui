import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:x_plore_remote_ui/repo/FileRepo.dart';

class CoverWidget extends StatefulWidget {
  String folderPath;
  String ip;

  CoverWidget(this.ip, this.folderPath, {super.key});

  @override
  State<CoverWidget> createState() => _CoverWidgetState();
}

class _CoverWidgetState extends State<CoverWidget> {
  String? url;
  FileRepo fileRepo = FileRepo();

  @override
  void initState() {
    readVideoInfo();
  }

  readVideoInfo() async {
    String cover = await fileRepo.readVideoInfo(widget.ip, widget.folderPath);
    setState(() {
      url = cover;
    });
  }

  @override
  Widget build(BuildContext context) {
    var u = url;
    return u == null
        ? const Placeholder()
        : Image.network(
            u,
            fit: BoxFit.fitHeight,
            height: double.infinity,
          );
  }
}
