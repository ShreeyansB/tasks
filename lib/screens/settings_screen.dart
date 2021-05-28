import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tasks/main.dart';
import 'package:tasks/util/database_helper.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:tasks/util/shared_prefs_helper.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

FlutterLocalNotificationsPlugin flutterNotif;
final DateFormat _timeFormatter = DateFormat('hh:mm a');
Random random = Random();
VideoPlayerController _controller;

enum ThemeType { Auto, Light, Dark }
var selectedColor = 0.obs;

Future<bool> checkInternet() async {
  final result = await InternetAddress.lookup('google.com');
  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    return true;
  } else
    return false;
}

List<String> mediaURL = [
  "https://i.imgur.com/wi6ry3t.jpg",
  "https://i.imgur.com/d9Da2sn.jpg",
  "https://i.imgur.com/NnilJHc.jpg",
  "https://i.imgur.com/epRYtr0.jpg",
  "https://i.imgur.com/0yzzmDv.jpg",
  "https://i.imgur.com/lmQPsVz.mp4",
  "https://i.imgur.com/Yi1aCef.mp4",
  "https://i.imgur.com/uKVm4WT.mp4"
];

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

  initColor() {
    String color = sharedPrefs.primColor;
    int index = 0;
    for (index = 0; index < MyThemes.themeColors.length; index++) {
      if (MyThemes.themeColors[index] == color) {
        break;
      }
    }
    return index;
  }

  Future getTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  @override
  void initState() {
    super.initState();
    getTimeZone();
    _controller = VideoPlayerController.network(mediaURL[random.nextInt(3) + 5])
      ..initialize().then((value) => setState(() {}));
    themeRadioType = themeStringToEnum(sharedPrefs.appTheme);
    selectedColor.value = initColor();
    //print("init color: "+initColor().toString());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
        .platformBrightness;

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
                    onTap: () {
                      Get.back();
                    },
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
                                                MyThemes.kPrimaryColor.value,
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
                                                MyThemes.kPrimaryColor.value,
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
                                                MyThemes.kPrimaryColor.value,
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
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                          colorScheme: brightness ==
                                                  Brightness.light
                                              ? (ColorScheme.light().copyWith(
                                                  primary: MyThemes
                                                      .kPrimaryColor.value,
                                                ))
                                              : ColorScheme.dark().copyWith(
                                                  primary: MyThemes
                                                      .kPrimaryColor.value,
                                                )),
                                      child: TextButton(
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
                                          print("Pressed OK: " +
                                              sharedPrefs.appTheme);
                                          Get.back();
                                          // Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                      Get.changeThemeMode(getThemeMode(themeRadioType));
                      Get.forceAppUpdate();
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
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.safeBlockHorizontal * 8.6,
                      top: SizeConfig.safeBlockVertical * 3),
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
                          "Theme Color",
                          style: MyThemes.settingsHeadTextStyle,
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 1.5,
                        ),
                        Container(
                          height: SizeConfig.safeBlockVertical * 7,
                          padding: EdgeInsets.only(
                              right: SizeConfig.safeBlockHorizontal * 10,
                              left: SizeConfig.safeBlockHorizontal * 0.7),
                          child: ListView.builder(
                            itemCount: MyThemes.themeColors.length,
                            itemBuilder: (context, index) {
                              return ColorTile(
                                color: MyThemes.themeColors[index].toColor(),
                                index: index,
                              );
                            },
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            primary: false,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Directory dir = await getApplicationDocumentsDirectory();
                    String path = dir.path + '/todo_list.db';
                    String bakPath = dir.path +
                        '/backup-' +
                        DateTime.now().toIso8601String() +
                        '.bak';
                    File myDB = File(path);
                    myDB.copy(bakPath);
                    File bak = File(bakPath);
                    await Share.shareFiles([bakPath], text: "Tasks Backup");
                    bak.delete();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 8.6,
                        top: SizeConfig.safeBlockVertical * 3),
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
                            "Backup",
                            style: MyThemes.settingsHeadTextStyle,
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 0.7,
                          ),
                          Text(
                            "Take a backup of your current tasks",
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
                GestureDetector(
                  onTap: () async {
                    FilePickerResult result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      File file = File(result.files.single.path);
                      Directory dir = await getApplicationDocumentsDirectory();
                      String path = dir.path + '/todo_list.db';
                      File oldDB = File(path);
                      oldDB.delete();
                      File restored = await file.copy(path);
                      dir.list().forEach((element) {
                        print(element.path);
                      });
                      Get.snackbar("Restoring your data",
                          "App will close in 5 seconds. Please restart the app",
                          snackPosition: SnackPosition.BOTTOM);

                      // Reinit Notifs Start
                      var _taskList =
                          await DatabaseHelper.instance.getTaskList();
                      var androidDetails = AndroidNotificationDetails(
                          'Tasks',
                          'Task Alert',
                          'Sends alerts to User when the Task is due',
                          importance: Importance.high);
                      var iOSDetails = IOSNotificationDetails();
                      var notifDetails = NotificationDetails(
                          android: androidDetails, iOS: iOSDetails);

                      for (var task in _taskList) {
                        if (task.status == 0) {
                          flutterNotif.zonedSchedule(
                              task.id,
                              task.title,
                              "Due at ${_timeFormatter.format(task.date)}",
                              tz.TZDateTime.from(task.date, tz.local),
                              notifDetails,
                              uiLocalNotificationDateInterpretation:
                                  UILocalNotificationDateInterpretation
                                      .absoluteTime,
                              androidAllowWhileIdle: true);
                        }
                      }
                      // Reinit Notifs End
                      Future.delayed(
                          Duration(seconds: 5),
                          () => SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop'));
                    } else {}
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 8.6,
                        top: SizeConfig.safeBlockVertical * 3,
                        right: SizeConfig.safeBlockHorizontal * 11),
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
                            "Restore",
                            style: MyThemes.settingsHeadTextStyle,
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 0.7,
                          ),
                          Text(
                            "Restore and replace your current tasks with the backup",
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
                GestureDetector(
                  onTap: () async {
                    Widget media;
                    checkInternet().then((value) {
                      if (value == true) {
                        int randInt = random.nextInt(9);
                        if (randInt < 5) {
                          media = Image.network(mediaURL[randInt]);
                        } else {
                          media = _controller.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                )
                              : Container();
                              _controller.play();
                              _controller.setLooping(true);
                        }
                      } else {
                          media = Image.asset("assets/images/flopper.jpg");
                        }
                    });
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Colors.grey.shade50
                                        : Color(0xff0f0f0f),
                                title: Text(
                                  "Now you have",
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
                                content: SizedBox(
                                  height: SizeConfig.safeBlockVertical * 30,
                                  width: SizeConfig.safeBlockHorizontal * 70,
                                  child: media,
                                ),
                                actions: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                        colorScheme:
                                            brightness == Brightness.light
                                                ? (ColorScheme.light().copyWith(
                                                    primary: MyThemes
                                                        .kPrimaryColor.value,
                                                  ))
                                                : ColorScheme.dark().copyWith(
                                                    primary: MyThemes
                                                        .kPrimaryColor.value,
                                                  )),
                                    child: TextButton(
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
                                        Get.back();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 8.6,
                        top: SizeConfig.safeBlockVertical * 3,
                        right: SizeConfig.safeBlockHorizontal * 11),
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
                            "Have you seen Floppa?",
                            style: MyThemes.settingsHeadTextStyle,
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 0.7,
                          ),
                          Text(
                            "Press to know additional info",
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

class ColorTile extends StatefulWidget {
  final Color color;
  final int index;
  ColorTile({@required this.color, @required this.index});

  @override
  _ColorTileState createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  bool state = false;

  bool checkState(RxInt value) {
    if (value.value == widget.index) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        height: SizeConfig.safeBlockVertical * 4,
        width: SizeConfig.safeBlockHorizontal * 17,
        decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.only(
              topLeft: (widget.index == 0
                  ? Radius.circular(SizeConfig.safeBlockVertical * 1.2)
                  : Radius.zero),
              bottomLeft: (widget.index == 0
                  ? Radius.circular(SizeConfig.safeBlockVertical * 1.2)
                  : Radius.zero),
              bottomRight: (widget.index == 7
                  ? Radius.circular(SizeConfig.safeBlockVertical * 1.2)
                  : Radius.zero),
              topRight: (widget.index == 7
                  ? Radius.circular(SizeConfig.safeBlockVertical * 1.2)
                  : Radius.zero),
            )),
        child: Center(
          child: SizedBox(
            child: Transform.scale(
              scale: 1.5,
              child: Checkbox(
                activeColor: Colors.transparent,
                checkColor: Theme.of(context).scaffoldBackgroundColor,
                fillColor: MaterialStateProperty.all(Colors.transparent),
                value: checkState(selectedColor),
                onChanged: (value) {
                  if (value == true) {
                    selectedColor.value = widget.index;
                    sharedPrefs.primColor =
                        MyThemes.themeColors[selectedColor.value];
                    MyThemes.initPrimaryColor();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
