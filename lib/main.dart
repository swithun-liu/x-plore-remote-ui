
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:x_plore_remote_ui/view/page/HomePage.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}