
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:x_plore_remote_ui/view/page/HomePage.dart';
import 'package:x_plore_remote_ui/view/window/MediaDetailPage.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("setting");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      theme: FluentThemeData(),
      initialRoute: '/home',
      routes: {
        RouterName.home: (context) => const MyHomePage(title: 'haha'),
        RouterName.mediaDetail: (context) => const MediaDetailPage(),
      },
    );
  }
}

class RouterName {
  static const String home = '/home';
  static const String mediaDetail = '/media_detail';
}