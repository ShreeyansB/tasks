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
}

final sharedPrefs = SharedPrefs();
