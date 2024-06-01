abstract class VideoSource {
  String getUrl(String ip);
}

class HTTPVideoSource extends VideoSource {
  String url;
  HTTPVideoSource(this.url);

  @override
  String getUrl(String ip) {
    return url;
  }
}

class HTTPVideoSourceGroup extends VideoSource {
  int pos;
  List<String> urls;

  HTTPVideoSourceGroup(this.urls, this.pos);

  @override
  String getUrl(String ip) {
    return urls[pos];
    // var uri = Uri.http('$ip:1111', urls[pos], {'cmd': 'file'});
    // return uri.toString();
  }
}