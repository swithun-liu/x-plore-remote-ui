import 'package:tmdb_api/tmdb_api.dart';
import 'package:logger/logger.dart' as SysLogger;

class ScrapUtil {
  static TMDB? tmdbWithCustomLogs = null;
  static SysLogger.Logger logger = SysLogger.Logger();

  static void init(apiKey, token) {
    tmdbWithCustomLogs = TMDB(ApiKeys(apiKey, token),
        logConfig: const ConfigLogger(showLogs: true, showErrorLogs: true));
  }

  static Future<ScrapData?> scrapMedia(String name, bool isMovie) async {
    var tmdb = tmdbWithCustomLogs;
    if (tmdb == null) {
      return null;
    }

    var postUrl = "";
    try {
      if (isMovie) {
        var result = await tmdb.v3.search.queryMovies(name);
        logger.i('[ScrapUtil] [scrapMedia] $name $isMovie result $result');
        var innerResult = result['results'];
        if (innerResult != null) {
          var firstResult = innerResult[0];
          if (firstResult != null) {
            var url = firstResult['poster_path'];
            if (url != null) {
              postUrl = url;
            }
          }
        }
      } else {
        var result = await tmdb.v3.search.queryTvShows(name);
        logger.i('[ScrapUtil] [scrapMedia] $name $isMovie result $result');
        var innerResult = result['results'];
        if (innerResult != null) {
          var firstResult = innerResult[0];
          if (firstResult != null) {
            var url = firstResult['poster_path'];
            if (url != null) {
              postUrl = url;
            }
          }
        }
      }
    } catch(exception) {
      logger.e('[ScrapUtil] [scrapMedia] $name $isMovie failed $exception');
    }

    return ScrapData(postUrl);
  }
}

class ScrapData {
  String postUrl;

  ScrapData(this.postUrl);

}