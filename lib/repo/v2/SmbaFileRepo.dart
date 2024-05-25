import 'package:logger/logger.dart';
import 'package:samba_browser/samba_browser.dart';
import 'package:x_plore_remote_ui/model/Path.dart';
import 'package:x_plore_remote_ui/repo/v2/IFileRepo.dart';

class SmbFileRepo implements IFileRepo {

  Logger logger = Logger();

  @override
  void init() {

  }

  @override
  List<DirectoryData> getDirectory() {
    SambaBrowser.getShareList('smb://192.168.31.36/', 'domain.net', '', '')
    .then((shares) => logger.d('[SmbFileRepo] [getDirectory] ${shares.cast<String>()}'))
    ;




    return [];
  }

}