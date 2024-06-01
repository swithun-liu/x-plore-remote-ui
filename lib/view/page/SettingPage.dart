import 'dart:ffi';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:x_plore_remote_ui/channel/SMBChannel.dart';

class SettingPage extends StatefulWidget {
  final String Function() getIP;
  final String Function() getName;
  final String Function() getPassword;
  final String Function() getPath;
  final void Function(String newIp) changeIp;
  final void Function(String newName) changeName;
  final void Function(String newName) changePassword;
  final void Function(String newName) changePath;

  const SettingPage(this.getIP, this.getName, this.getPassword, this.getPath,
      this.changeIp, this.changeName, this.changePassword, this.changePath,
      {super.key});

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
    var rememberIp = widget.getIP.call() as String?;
    if (rememberIp != null) {
      ip = rememberIp;
    }
    var rememberName = widget.getName.call() as String?;
    if (rememberName != null) {
      name = rememberName;
    }
    var rememberPassword = widget.getPassword.call() as String?;
    if (rememberPassword != null) {
      password = rememberPassword;
    }
    var rememberPath = widget.getPath.call() as String?;
    if (rememberPath != null) {
      path = rememberPath;
    }
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
    widget.changeName.call(value);
  }

  void onPasswordChanged(String value) {
    password = value;
    widget.changePassword.call(value);
  }

  void onPathChanged(String value) {
    path = value;
    widget.changePath.call(value);
  }

  void onIPChanged(String value) {
    var logger = Logger();
    logger.d("onEditingComplete $value");
    ip = value;
    widget.changeIp.call(value);
  }

  void onEditingComplete() {
    var logger = Logger();
    logger.d("onEditingComplete");
  }
}
