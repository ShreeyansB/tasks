import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasks/models/task_model.dart';
import 'package:tasks/screens/add_task_screen.dart';
import 'package:tasks/screens/settings_screen.dart';
import 'package:tasks/util/database_helper.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:tasks/util/shared_prefs_helper.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  FlutterLocalNotificationsPlugin flutterNotif;
  final DateFormat _timeFormatter = DateFormat('hh:mm a');

  Future<List<Task>> _taskList;

  FlareControls _flrController;
  bool orderPaused = true;
  bool orderOnDate = sharedPrefs.isSortingByDate;
  String animInit;

  final List<double> invertMatrix = [
    //R  G   B    A  Const
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  final List<double> identityMatrix = [
    //R  G   B    A  Const
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  Future getTimeZone() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    if(timeZoneName == "Asia/Calcutta") {
      timeZoneName = "Asia/Kolkata";
    }

    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future notifSelected(String payload) async {
    print(payload);
  }

  Future _showNotif(Task task) async {
    var androidDetails = AndroidNotificationDetails(
        'Tasks', 'Task Alert', 'Sends alerts to User when the Task is due',
        importance: Importance.high);
    var iOSDetails = IOSNotificationDetails();
    var notifDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    flutterNotif.zonedSchedule(
        task.id,
        task.title,
        "Due at ${_timeFormatter.format(task.date)}",
        tz.TZDateTime.from(task.date, tz.local),
        notifDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  _deleteNotif(Task task) {
    flutterNotif.cancel(task.id);
  }

  @override
  void initState() {
    super.initState();
    _flrController = FlareControls();
    animInit = orderOnDate ? "DateToPri" : "PriToDate";
    _updateTaskList();
    getTimeZone();
    var androidInitSettings =
        AndroidInitializationSettings("ic_stat_notifications_active");
    var iOSInitSettings = IOSInitializationSettings();
    var initSettings = InitializationSettings(
        android: androidInitSettings, iOS: iOSInitSettings);
    flutterNotif = FlutterLocalNotificationsPlugin();
    flutterNotif.initialize(initSettings, onSelectNotification: notifSelected);
  }

  _notifCallback(bool status, Task task) {
    if (status) {
      _deleteNotif(task);
    } else {
      _showNotif(task);
    }
  }

  _updateTaskList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _taskList = DatabaseHelper.instance.getTaskList();
      });
    });
  }

  void _playAnimation() {
    setState(() {
      orderPaused = false;
      _updateTaskList();
    });
    if (orderOnDate) {
      _flrController.play("DateToPri");
      orderOnDate = false;
    } else {
      _flrController.play("PriToDate");
      orderOnDate = true;
    }
    sharedPrefs.isSortingByDate = orderOnDate;
    print(orderOnDate);
    print(sharedPrefs.isSortingByDate);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    MyThemes().initBlock(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Theme(
          data: Theme.of(context).copyWith(
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color:
                    (Theme.of(context).scaffoldBackgroundColor == Colors.white
                        ? Color(0xfff2f3f3)
                        : Color(0xff1c1c1c)),
                borderRadius:
                    BorderRadius.circular(SizeConfig.safeBlockHorizontal * 1),
              ),
              textStyle: TextStyle(
                color:
                    (Theme.of(context).scaffoldBackgroundColor == Colors.white
                        ? Colors.black
                        : Colors.white),
                fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                fontFamily: "Circular Std",
              ),
            ),
          ),
          child: Obx(
            () => FloatingActionButton(
              tooltip: "Add Task",
              backgroundColor: MyThemes.kPrimaryColor.value,
              child: Text(
                "+",
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: SizeConfig.safeBlockVertical * 4.5,
                    fontFamily: "Circular Std"),
              ),
              onPressed: () {
                Get.to(
                  () => AddTaskScreen(
                    updateListCallback: _updateTaskList,
                  ),
                  transition: Transition.fadeIn,
                  curve: Curves.easeInCubic,
                  duration: Duration(milliseconds: 300),
                );
                // Navigator.push(
                //   context,
                //   PageTransition(
                //     type: PageTransitionType.fade,
                //     child: AddTaskScreen(
                //       updateListCallback: _updateTaskList,
                //     ),
                //     curve: Curves.easeInCubic,
                //     duration: Duration(milliseconds: 300),
                //     reverseDuration: Duration(milliseconds: 300),
                //   ),
                // );
              },
            ),
          ),
        ),
        body: FutureBuilder<List<Task>>(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Container(
                  height: SizeConfig.safeBlockVertical * 0.5,
                  width: SizeConfig.safeBlockHorizontal * 40,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        MyThemes.kPrimaryColor.value),
                    backgroundColor:
                        MyThemes.kPrimaryColor.value.withOpacity(0.3),
                    value: null,
                  ),
                ),
              );
            }

            final int completedTaskCount = snapshot.data
                .where((Task task) => task.status == 1)
                .toList()
                .length;

            return ListView.builder(
              padding: EdgeInsets.only(
                  top: SizeConfig.safeBlockVertical * 3.3,
                  bottom: SizeConfig.safeBlockVertical * 10),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.safeBlockVertical,
                        horizontal: SizeConfig.safeBlockHorizontal * 8.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "My Tasks",
                              style: MyThemes.headTextStyle,
                            ),
                            Row(
                              children: [
                                Tooltip(
                                  message: "Sort Tasks",
                                  decoration: BoxDecoration(
                                    color: (Theme.of(context)
                                                .scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Color(0xfff2f3f3)
                                        : Color(0xff1c1c1c)),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockHorizontal * 1),
                                  ),
                                  textStyle: TextStyle(
                                    color: (Theme.of(context)
                                                .scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Colors.black
                                        : Colors.white),
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3.4,
                                    fontFamily: "Circular Std",
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _playAnimation(),
                                    child: SizedBox(
                                      height:
                                          SizeConfig.safeBlockHorizontal * 7,
                                      width: SizeConfig.safeBlockHorizontal * 7,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                SizeConfig.safeBlockVertical *
                                                    0.2),
                                        child: ColorFiltered(
                                          colorFilter: (Theme.of(context)
                                                      .scaffoldBackgroundColor ==
                                                  Colors.white
                                              ? ColorFilter.matrix(invertMatrix)
                                              : ColorFilter.matrix(
                                                  identityMatrix)),
                                          child: FlareActor(
                                            "assets/images/order_by.flr",
                                            isPaused: orderPaused,
                                            controller: _flrController,
                                            animation: animInit,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: SizeConfig.safeBlockHorizontal * 3,
                                ),
                                Tooltip(
                                  message: "Settings",
                                  decoration: BoxDecoration(
                                    color: (Theme.of(context)
                                                .scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Color(0xfff2f3f3)
                                        : Color(0xff1c1c1c)),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockHorizontal * 1),
                                  ),
                                  textStyle: TextStyle(
                                    color: (Theme.of(context)
                                                .scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Colors.black
                                        : Colors.white),
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3.4,
                                    fontFamily: "Circular Std",
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => SettingsScreen(),
                                        transition: Transition.fadeIn,
                                        curve: Curves.easeInCubic,
                                        duration: Duration(milliseconds: 300),
                                      );
                                      // Navigator.push(
                                      //   context,
                                      //   PageTransition(
                                      //     type: PageTransitionType.fade,
                                      //     child: SettingsScreen(),
                                      //     curve: Curves.easeInCubic,
                                      //     duration: Duration(milliseconds: 300),
                                      //     reverseDuration:
                                      //         Duration(milliseconds: 300),
                                      //   ),
                                      // );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom:
                                              SizeConfig.safeBlockVertical * 0),
                                      child: Icon(
                                        Icons.tune,
                                        size: SizeConfig.safeBlockHorizontal *
                                            8.5,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 1,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.safeBlockHorizontal * 0.5),
                          child: Text(
                            "$completedTaskCount of ${snapshot.data.length}",
                            style: MyThemes.subTextStyle.copyWith(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey
                                      : Colors.grey.shade700,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return TaskTile(
                    task: snapshot.data[index - 1],
                    callback: _updateTaskList,
                    notifCallback: _notifCallback,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  final Task task;
  final Function callback;
  final Function notifCallback;
  TaskTile({@required this.task, this.callback, this.notifCallback});

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool myValue = true;

  final DateFormat _dateFormatter = DateFormat('dd MMMM, yyyy');
  final DateFormat _timeFormatter = DateFormat('hh:mm a');

  Color _setPriorityColor(Task task) {
    if (task.priority == "High") {
      return MyThemes.kPrimaryColor.value;
    } else if (task.priority == "Medium") {
      return MyThemes.kPrimaryColor.value.withOpacity(0.84);
    } else {
      return MyThemes.kPrimaryColor.value.withOpacity(0.72);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: SizeConfig.safeBlockVertical * 1.2,
                bottom: SizeConfig.safeBlockVertical * 1.2,
                left: SizeConfig.safeBlockHorizontal * 5.6,
                right: SizeConfig.safeBlockHorizontal * 4),
            child: ListTile(
              onTap: () {
                Get.to(
                  () => AddTaskScreen(
                    updateListCallback: widget.callback,
                    task: widget.task,
                  ),
                  transition: Transition.fadeIn,
                  curve: Curves.easeInCubic,
                  duration: Duration(milliseconds: 300),
                );
                // Navigator.push(
                //   context,
                //   PageTransition(
                //     type: PageTransitionType.fade,
                //     child: AddTaskScreen(
                //       updateListCallback: widget.callback,
                //       task: widget.task,
                //     ),
                //     curve: Curves.easeInCubic,
                //     duration: Duration(milliseconds: 300),
                //     reverseDuration: Duration(milliseconds: 300),
                //   ),
                // );
              },
              title: Text(
                widget.task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "Circular Std",
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.safeBlockVertical * 2.3,
                  decoration: widget.task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "${_dateFormatter.format(widget.task.date)} @ ${_timeFormatter.format(widget.task.date)} • ",
                      style: TextStyle(
                          fontFamily: "Circular Std",
                          fontWeight: FontWeight.normal,
                          fontSize: SizeConfig.safeBlockVertical * 1.7,
                          color: Theme.of(context).scaffoldBackgroundColor ==
                                  Colors.white
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white70,
                          decoration: widget.task.status == 0
                              ? TextDecoration.none
                              : TextDecoration.lineThrough),
                    ),
                    TextSpan(
                      text: "${widget.task.priority}",
                      style: TextStyle(
                          fontFamily: "Circular Std",
                          fontWeight: FontWeight.normal,
                          fontSize: SizeConfig.safeBlockVertical * 1.7,
                          color: _setPriorityColor(widget.task),
                          decoration: widget.task.status == 0
                              ? TextDecoration.none
                              : TextDecoration.lineThrough),
                    ),
                  ],
                ),
              ),
              trailing: Obx(
                () => Checkbox(
                  checkColor:
                      Theme.of(context).scaffoldBackgroundColor == Colors.white
                          ? Colors.white
                          : Colors.black,
                  onChanged: (value) {
                    widget.task.status = value ? 1 : 0;
                    DatabaseHelper.instance.updateTask(widget.task);
                    widget.notifCallback(value, widget.task);
                    widget.callback();
                    setState(() {});
                  },
                  activeColor: MyThemes.kPrimaryColor.value,
                  value: widget.task.status == 1 ? true : false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Text(
//               "${_dateFormatter.format(widget.task.date)} @ ${_timeFormatter.format(widget.task.date)} • ${widget.task.priority}",
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                   fontFamily: "Circular Std",
//                   fontWeight: FontWeight.normal,
//                   fontSize: SizeConfig.safeBlockVertical * 1.7,
//                   decoration: widget.task.status == 0
//                       ? TextDecoration.none
//                       : TextDecoration.lineThrough),
//             )
