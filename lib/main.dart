import 'package:flutter/material.dart';
import 'package:tasks/screens/tasks_screen.dart';
import 'package:tasks/util/themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks',
      debugShowCheckedModeBanner: false,
      theme: MyThemes.myLightTheme,
      // darkTheme: MyThemes.myDarkTheme,

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
