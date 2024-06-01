import 'package:hive/hive.dart';

class SettingStore {

  static Box settingBox = Hive.box("setting");

  static final Setting _setting = Setting(
    settingBox.get("ip", defaultValue: ""),
    settingBox.get("name", defaultValue: ""),
    settingBox.get("password", defaultValue: ""),
    settingBox.get("path", defaultValue: "")
  );

  static Setting getSetting() {
    return Setting(_setting.ip, _setting.name, _setting.password, _setting.path);
  }

  static String getIp() { return _setting.ip; }

  static String getName() { return _setting.name; }

  static String getPassword() { return _setting.password; }

  static String getPath() { return _setting.path; }

  static void changeIp(String newIp) {
    settingBox.put("ip", newIp);
    _setting.ip = newIp;
  }

  static void changeName(String newName) {
    settingBox.put("name", newName);
    _setting.name = newName;
  }

  static void changePassword(String newPassword) {
    settingBox.put("password", newPassword);
    _setting.password = newPassword;
  }

  static void changePath(String newPath) {
    settingBox.put("path", newPath);
    _setting.path = newPath;
  }
}

class Setting {
  String ip = "";
  String name = "";
  String password = "";
  String path = "";

  // 构造函数，全部参数都可空

  Setting([this.ip = "", this.name = "", this.password = "", this.path = ""]);
}