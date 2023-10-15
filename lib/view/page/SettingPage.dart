import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';

class SettingPage extends StatefulWidget {

  final String Function() getIP;
  final void Function(String newIp) changeIp;

  const SettingPage(this.getIP, this.changeIp, {super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  String ip = "";

  @override
  void initState() {
    super.initState();
    ip = widget.getIP.call();
  }

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: 'Enter server IP',
      child: TextBox(
        placeholder: 'IP',
        expands: false,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
      ),
    );
  }

  void onChanged(String value) {
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

