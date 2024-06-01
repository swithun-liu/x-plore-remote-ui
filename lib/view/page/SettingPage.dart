import 'dart:ffi';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/channel/SMBChannel.dart';

import '../../model/Setting.dart';

class SettingPage extends StatefulWidget {

  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String ip = "";
  String name = "";
  String password = "";
  String path = "";

  @override
  void initState() {
    super.initState();
    ip = SettingStore.getIp();
    name = SettingStore.getName();
    password = SettingStore.getPassword();
    path = SettingStore.getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoLabel(
          label: 'Enter server IP',
          child: TextBox(
            placeholder: ip,
            expands: false,
            onChanged: onIPChanged,
            onEditingComplete: onEditingComplete,
          ),
        ),
        InfoLabel(
          label: '用户名',
          child: TextBox(
            placeholder: name,
            expands: false,
            onChanged: onNameChanged,
          ),
        ),
        InfoLabel(
          label: '密码',
          child: TextBox(
            placeholder: password,
            expands: false,
            onChanged: onPasswordChanged,
          ),
        ),
        InfoLabel(
          label: '路径',
          child: TextBox(
            placeholder: path,
            expands: false,
            onChanged: onPathChanged,
          ),
        ),
        Button(onPressed: connectSMB, child: const Text("连接"))
      ],
    );
  }

  void connectSMB() {
    SMBChannel.connectSMB(ip, "", path, name, password);
  }

  void onNameChanged(String value) {
    name = value;
    SettingStore.changeName(value);
  }

  void onPasswordChanged(String value) {
    password = value;
    SettingStore.changePassword(value);
  }

  void onPathChanged(String value) {
    path = value;
    SettingStore.changePath(value);
  }

  void onIPChanged(String value) {
    ip = value;
    SettingStore.changeIp(value);
  }

  void onEditingComplete() {
    var logger = Logger();
    logger.d("onEditingComplete");
  }
}
