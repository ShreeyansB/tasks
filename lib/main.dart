import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasks/screens/tasks_screen.dart';
import 'package:tasks/util/themes.dart';
import 'package:tasks/util/shared_prefs_helper.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  print("Main init shared prefs:");
  print(sharedPrefs.isSortingByDate);
  print(sharedPrefs.appTheme);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static void setSystemComponentsTheme() {

    var brightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
    print(brightness);
    if (sharedPrefs.appTheme == "Auto") {
      if (brightness == Brightness.light) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white, // navigation bar color
          statusBarColor: Colors.white, // status bar color
          statusBarBrightness: Brightness.dark, //status bar brigtness
          statusBarIconBrightness: Brightness.dark, //status barIcon Brightness
          systemNavigationBarDividerColor:
              Colors.transparent, //Navigation bar divider color
          systemNavigationBarIconBrightness:
              Brightness.light, //navigation bar icon
        ));
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black, // navigation bar color
          statusBarColor: Colors.black, // status bar color
          statusBarBrightness: Brightness.light, //status bar brigtness
          statusBarIconBrightness: Brightness.light, //status barIcon Brightness
          systemNavigationBarDividerColor:
              Colors.transparent, //Navigation bar divider color
          systemNavigationBarIconBrightness:
              Brightness.dark, //navigation bar icon
        ));
      }
    } else if (sharedPrefs.appTheme == "Light") {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // navigation bar color
        statusBarColor: Colors.white, // status bar color
        statusBarBrightness: Brightness.dark, //status bar brigtness
        statusBarIconBrightness: Brightness.dark, //status barIcon Brightness
        systemNavigationBarDividerColor:
            Colors.transparent, //Navigation bar divider color
        systemNavigationBarIconBrightness:
            Brightness.light, //navigation bar icon
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black, // navigation bar color
        statusBarColor: Colors.black, // status bar color
        statusBarBrightness: Brightness.light, //status bar brigtness
        statusBarIconBrightness: Brightness.light, //status barIcon Brightness
        systemNavigationBarDividerColor:
            Colors.transparent, //Navigation bar divider color
        systemNavigationBarIconBrightness:
            Brightness.dark, //navigation bar icon
      ));
    }
  }

  ThemeData setPrimTheme() {
    if (sharedPrefs.appTheme == "Auto")
      return MyThemes.myLightTheme;
    else if (sharedPrefs.appTheme == "Light")
      return MyThemes.myLightTheme;
    else
      return MyThemes.myDarkTheme;
  }

  ThemeData setSecTheme() {
    if (sharedPrefs.appTheme == "Auto")
      return MyThemes.myDarkTheme;
    else if (sharedPrefs.appTheme == "Light")
      return MyThemes.myLightTheme;
    else
      return MyThemes.myDarkTheme;
  }


  @override
  Widget build(BuildContext context) {
    setSystemComponentsTheme();
    return GetMaterialApp(
      title: 'Tasks',
      debugShowCheckedModeBanner: false,
      theme: setPrimTheme(),
      darkTheme: setSecTheme(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      home: TasksScreen(),
    );
  }
}

// To Remove Overscroll Glow

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
