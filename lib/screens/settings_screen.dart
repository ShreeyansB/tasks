import 'package:flutter/material.dart';
import 'package:tasks/main.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:tasks/util/shared_prefs_helper.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

enum ThemeType { Auto, Light, Dark }

ThemeMode getThemeMode(ThemeType theme) {
  if (theme == ThemeType.Auto)
    return ThemeMode.system;
  else if (theme == ThemeType.Light)
    return ThemeMode.light;
  else
    return ThemeMode.dark;
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeType themeRadioType = ThemeType.Light;

  String themeEnumToString(ThemeType value) {
    if (value == ThemeType.Auto)
      return "Auto";
    else if (value == ThemeType.Light)
      return "Light";
    else
      return "Dark";
  }

  ThemeType themeStringToEnum(String value) {
    if (value == "Auto")
      return ThemeType.Auto;
    else if (value == "Light")
      return ThemeType.Light;
    else
      return ThemeType.Dark;
  }

  @override
  void initState() {
    super.initState();
    themeRadioType = themeStringToEnum(sharedPrefs.appTheme);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.safeBlockVertical * 3.3,
              bottom: SizeConfig.safeBlockVertical * 7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.safeBlockHorizontal * 3.6,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: SizeConfig.safeBlockVertical * 4,
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 3,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.safeBlockHorizontal * 8.6,
                      top: SizeConfig.safeBlockVertical * 6),
                  child: Text(
                    "Settings",
                    style: MyThemes.headTextStyle,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.safeBlockHorizontal * 8.6,
                      top: SizeConfig.safeBlockVertical * 3),
                  child: GestureDetector(
                    onTap: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey.shade50
                                      : Color(0xff0f0f0f),
                                  title: Text(
                                    "Select Theme",
                                    style: MyThemes.settingsHeadTextStyle
                                        .copyWith(
                                            fontSize:
                                                SizeConfig.safeBlockVertical *
                                                    2.6,
                                            fontWeight: FontWeight.w500),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: SizeConfig.safeBlockHorizontal * 4,
                                      right: SizeConfig.safeBlockHorizontal * 4,
                                      top: SizeConfig.safeBlockVertical * 1),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                            splashColor: Colors.transparent,
                                            highlightColor: (Theme.of(context)
                                                        .scaffoldBackgroundColor ==
                                                    Colors.white
                                                ? Colors.black12
                                                : Colors.white
                                                    .withOpacity(0.05))),
                                        child: RadioListTile<ThemeType>(
                                            contentPadding: EdgeInsets.all(0),
                                            value: ThemeType.Auto,
                                            groupValue: themeRadioType,
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            title: Text(
                                              "Auto",
                                              style: MyThemes
                                                  .settingsSubtitleTextStyle
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: SizeConfig
                                                              .safeBlockVertical *
                                                          2.1),
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                themeRadioType = val;
                                              });
                                              print(themeRadioType);
                                            }),
                                      ),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                            splashColor: Colors.transparent,
                                            highlightColor: (Theme.of(context)
                                                        .scaffoldBackgroundColor ==
                                                    Colors.white
                                                ? Colors.black12
                                                : Colors.white
                                                    .withOpacity(0.05))),
                                        child: RadioListTile<ThemeType>(
                                            value: ThemeType.Light,
                                            contentPadding: EdgeInsets.all(0),
                                            groupValue: themeRadioType,
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            title: Text(
                                              "Light",
                                              style: MyThemes
                                                  .settingsSubtitleTextStyle
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: SizeConfig
                                                              .safeBlockVertical *
                                                          2.1),
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                themeRadioType = val;
                                              });
                                              print(themeRadioType);
                                            }),
                                      ),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                            splashColor: Colors.transparent,
                                            highlightColor: (Theme.of(context)
                                                        .scaffoldBackgroundColor ==
                                                    Colors.white
                                                ? Colors.black12
                                                : Colors.white
                                                    .withOpacity(0.05))),
                                        child: RadioListTile<ThemeType>(
                                            value: ThemeType.Dark,
                                            contentPadding: EdgeInsets.all(0),
                                            groupValue: themeRadioType,
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            title: Text(
                                              "Dark",
                                              style: MyThemes
                                                  .settingsSubtitleTextStyle
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: SizeConfig
                                                              .safeBlockVertical *
                                                          2.1),
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                themeRadioType = val;
                                              });
                                              print(themeRadioType);
                                            }),
                                      )
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.safeBlockVertical *
                                                    1.9,
                                            fontFamily: "Circular Std",
                                            letterSpacing: 1.5),
                                      ),
                                      onPressed: () {
                                        sharedPrefs.appTheme =
                                            themeEnumToString(themeRadioType);
                                        print(sharedPrefs.appTheme);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                      Get.changeThemeMode(getThemeMode(themeRadioType));
                      MyApp.setSystemComponentsTheme();
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.safeBlockVertical * 1),
                      width: SizeConfig.safeBlockHorizontal * 90,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "App Theme",
                            style: MyThemes.settingsHeadTextStyle,
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 0.7,
                          ),
                          Text(
                            themeEnumToString(themeRadioType),
                            style: MyThemes.settingsSubtitleTextStyle.copyWith(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Colors.grey
                                        : Colors.grey.shade600),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
