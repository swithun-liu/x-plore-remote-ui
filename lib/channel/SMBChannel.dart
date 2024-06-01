import 'package:flutter/services.dart';

class SMBChannel {
  static const _channelName = "com.swithun/SMB";
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<String> testChannel() async {
    return await _channel.invokeMethod("testChannel");
  }

  static Future getPathList(String parent) async {
    return _channel.invokeMethod("getPathList", {'parent': parent});
    // // 调用平台方法并将结果转换为 List<dynamic>
    // final List<dynamic> result = await _channel.invokeMethod("getPathList", parent);
    // // 将 List<dynamic> 转换为 List<String>
    // return result.cast<String>();
  }

  static Future connectSMB(
      String ip, String port, String path, String uname, String upassword) {
    return _channel.invokeMethod("connectSMB", {
      'ip': ip,
      'port': port,
      'path': path,
      'uname': uname,
      'upassword': upassword
    });
  }
}
