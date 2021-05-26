import 'package:flutter/material.dart';
import 'package:tasks/util/shared_prefs_helper.dart';
import 'package:tasks/util/size_config.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

class MyThemes {
  static double themeblockhz;
  static double themeblockvt;
  static BuildContext myContext;
  static Color kPrimaryColor;

  static List<String> themeColors = [
    "#ff495c", //red
    "#eb49ac", // pink
    "#a944e3", // purple
    "#4056ed", // violet
    "#269fe0", //blue
    "#22c99a", // teal
    "#FFA000", // yellow
    "#ff6d49", // orange
  ];

  static void initPrimaryColor() {
    MyThemes.kPrimaryColor = sharedPrefs.primColor.toColor();
  }

  void initBlock(BuildContext context) {
    myContext = context;
    SizeConfig().init(context);
    themeblockhz = SizeConfig.safeBlockHorizontal;
    themeblockvt = SizeConfig.safeBlockVertical;
  }

  static ThemeData myLightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: MyThemes.kPrimaryColor,
    colorScheme: ColorScheme.light(primary: MyThemes.kPrimaryColor),
    chipTheme: ThemeData.light().chipTheme.copyWith(
          backgroundColor: Color(0xfff2f3f3),
          secondaryLabelStyle: TextStyle(color: Colors.white),
          secondarySelectedColor: MyThemes.kPrimaryColor,
        ),
    floatingActionButtonTheme:
        ThemeData.light().floatingActionButtonTheme.copyWith(elevation: 0),
    tooltipTheme: ThemeData.light().tooltipTheme.copyWith(),
  );

  static ThemeData myDarkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: MyThemes.kPrimaryColor,
    colorScheme: ColorScheme.dark(primary: MyThemes.kPrimaryColor),
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: Color(0xff1c1c1c),
          secondaryLabelStyle: TextStyle(color: Colors.black),
          secondarySelectedColor: MyThemes.kPrimaryColor,
        ),
    floatingActionButtonTheme:
        ThemeData.dark().floatingActionButtonTheme.copyWith(elevation: 0),
  );

  static ThemeData subTextTheme = myLightTheme.copyWith();

  static TextStyle headTextStyle = TextStyle(
    fontSize: themeblockvt * 4.5,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w700,
  );

  static TextStyle subTextStyle = TextStyle(
    fontSize: themeblockvt * 2.2,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w500,
  );

  static TextStyle fieldHeadTextStyle = TextStyle(
    fontSize: themeblockvt * 2,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w500,
  );

  static TextStyle fieldTextStyle = TextStyle(
    fontSize: themeblockvt * 2.4,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w500,
  );

  static TextStyle fieldButtonTextStyle = TextStyle(
    fontSize: themeblockvt * 4,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w700,
  );

  static TextStyle settingsHeadTextStyle = TextStyle(
    fontSize: SizeConfig.safeBlockVertical * 2.7,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w700,
  );

  static TextStyle settingsSubtitleTextStyle = TextStyle(
    fontSize: SizeConfig.safeBlockVertical * 2.2,
    fontFamily: "Circular Std",
    fontWeight: FontWeight.w600,
  );
}
