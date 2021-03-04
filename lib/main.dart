import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasks/screens/tasks_screen.dart';
import 'package:tasks/util/themes.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  void setSystemComponentsTheme(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
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

  @override
  Widget build(BuildContext context) {
    setSystemComponentsTheme(context);

    return MaterialApp(
      title: 'Tasks',
      debugShowCheckedModeBanner: false,
      theme: MyThemes.myLightTheme,
      darkTheme: MyThemes.myDarkTheme,

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
