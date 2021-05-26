import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  // Setters and Getters for Keys

  // Sorting State
  bool get isSortingByDate => _sharedPrefs.getBool("isSortingByDate") ?? true;

  set isSortingByDate(bool value) {
    _sharedPrefs.setBool("isSortingByDate", value);
  }

  // Theme Setting
  String get appTheme => _sharedPrefs.getString("appTheme") ?? "Auto";

  set appTheme(String value) {
    _sharedPrefs.setString("appTheme", value);
  }

  String get primColor => _sharedPrefs.getString("primColor") ?? "#ff495c";

  set primColor(String value) {
    _sharedPrefs.setString("primColor", value);
  }
}


final sharedPrefs = SharedPrefs();
