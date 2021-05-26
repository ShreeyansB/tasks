import 'package:flutter/material.dart';
import 'package:tasks/models/task_model.dart';
import 'package:tasks/util/database_helper.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateListCallback;

  AddTaskScreen({this.task, this.updateListCallback});
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String priority = "";
  DateTime date = DateTime.now().add(Duration(minutes: 5));
  List<bool> chipStates = [true, false, false];
  ScrollController _scrollController = ScrollController();

  final DateFormat _dateFormatter = DateFormat('dd MMMM, yyyy');
  final DateFormat _timeFormatter = DateFormat('hh:mm a');

  TextEditingController _dateController = TextEditingController();

  TextEditingController _timeController = TextEditingController();

  FocusNode _focusNode;
  FocusNode _focusNodeDate;
  FocusNode _focusNodeTime;

  FlutterLocalNotificationsPlugin flutterNotif;
  Future<List<Task>> _taskList;

  _handleDatePicker() async {
    final DateTime mydate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
    );

    if (mydate != null && mydate != date) {
      setState(() {
        date = mydate;
        _dateController.text = _dateFormatter.format(date);
      });
    }
  }

  _handleTimePicker() async {
    final TimeOfDay mytime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if ((mytime != null) &&
        (mytime.hour != date.hour || mytime.minute != date.minute)) {
      setState(() {
        DateTime newDate = DateTime(date.year, date.month, date.day,
            mytime.hour, mytime.minute, 0, date.millisecond, date.microsecond);
        date = newDate;
        _timeController.text = _timeFormatter.format(date);
      });
    }
  }

  Future getTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print(tz.local);
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
    _updateTaskList();

    List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterNotif.pendingNotificationRequests();
    List<Task> myTasks;
    await _taskList.then((value) => myTasks = value);
    myTasks.forEach((t) {
      if (t.title == task.title && t.date == task.date) {
        if (pendingNotificationRequests.isNotEmpty) {
          pendingNotificationRequests.forEach((notif) {
            if (notif.id == t.id) {
              flutterNotif.cancel(t.id);
            }
          });
        }
        tz.TZDateTime tt = tz.TZDateTime.from(t.date, tz.local);
        print(tt.toString());
        flutterNotif.zonedSchedule(
            t.id,
            t.title,
            "Due at ${_timeFormatter.format(t.date)}",
            tz.TZDateTime.from(t.date, tz.local),
            notifDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
      }
    });
  }

  _deleteNotif(Task task) {
    flutterNotif.cancel(task.id);
  }

  _updateTaskList() {
    _taskList = DatabaseHelper.instance.getTaskList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _focusNodeDate = FocusNode();
    _focusNodeTime = FocusNode();

    // notif
    getTimeZone();
    var androidInitSettings =
        AndroidInitializationSettings("ic_stat_notifications_active");
    var iOSInitSettings = IOSInitializationSettings();
    var initSettings = InitializationSettings(
        android: androidInitSettings, iOS: iOSInitSettings);
    flutterNotif = FlutterLocalNotificationsPlugin();
    flutterNotif.initialize(initSettings, onSelectNotification: notifSelected);

    if (widget.task != null) {
      if (widget.task.priority == "High") {
        chipStates = [false, false, true];
      } else if (widget.task.priority == "Medium") {
        chipStates = [false, true, false];
      }
      title = widget.task.title;
      date = widget.task.date;
      priority = widget.task.priority;
    }
    _dateController.text = _dateFormatter.format(date);
    _timeController.text = _timeFormatter.format(date);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeDate.dispose();
    _focusNodeTime.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _requestFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _requestFocusDate() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeDate);
    });
  }

  void _requestFocusTime() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeTime);
    });
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (chipStates[0] == true) {
        priority = "Low";
      } else if (chipStates[1] == true) {
        priority = "Medium";
      } else {
        priority = "High";
      }
      print(title + date.toString() + priority);

      // Insert/Update Task to DB
      Task task = Task(title: title, date: date, priority: priority);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      _showNotif(task);
      widget.updateListCallback();
      Navigator.pop(context);
    }
  }

  _delete() {
    print("deleting..");
    _deleteNotif(widget.task);
    DatabaseHelper.instance.deleteTask(widget.task);
    widget.updateListCallback();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.safeBlockVertical * 3.3,
                bottom: SizeConfig.safeBlockVertical * 7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        top: SizeConfig.safeBlockVertical * 6), // Top Space
                    child: Text(
                      widget.task == null ? "Add Task" : "Edit Task",
                      style: MyThemes.headTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 3,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 8.6,
                        right: SizeConfig.safeBlockHorizontal * 8.6),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Title",
                                style: MyThemes.fieldHeadTextStyle,
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical * 1.2,
                              ),
                              TextFormField(
                                focusNode: _focusNode,
                                onTap: () {
                                  _requestFocus();
                                  Future.delayed(
                                      Duration(milliseconds: 200),
                                      () => _scrollController.animateTo(
                                          _scrollController
                                                  .position.maxScrollExtent -
                                              SizeConfig.safeBlockVertical *
                                                  16.6,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeOut));
                                },
                                validator: (value) => value.trim().isEmpty
                                    ? "Please enter a Title"
                                    : null,
                                onSaved: (input) {
                                  title = input;
                                },
                                initialValue: title,
                                style: MyThemes.fieldTextStyle,
                                cursorColor: Theme.of(context).primaryColor,
                                cursorHeight: SizeConfig.safeBlockVertical * 3,
                                decoration: InputDecoration(
                                  errorStyle:
                                      TextStyle(fontFamily: 'Circular Std'),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width:
                                            SizeConfig.safeBlockVertical * 0.2,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7),
                                  ),
                                  fillColor: _focusNode.hasFocus
                                      ? Colors.transparent
                                      : (Theme.of(context)
                                                  .scaffoldBackgroundColor ==
                                              Colors.white
                                          ? Color(0xfff2f3f3)
                                          : Color(0xff1c1c1c)),
                                  filled: true,
                                  focusColor: Colors.black,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical:
                                          SizeConfig.safeBlockVertical * 1.5,
                                      horizontal:
                                          SizeConfig.safeBlockHorizontal * 4),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 3,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date",
                                style: MyThemes.fieldHeadTextStyle,
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical * 1.2,
                              ),
                              TextFormField(
                                focusNode: _focusNodeDate,
                                readOnly: true,
                                onTap: () {
                                  _requestFocusDate();
                                  _handleDatePicker();
                                },
                                controller: _dateController,
                                style: MyThemes.fieldTextStyle,
                                cursorColor: Theme.of(context).primaryColor,
                                cursorHeight: SizeConfig.safeBlockVertical * 3,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width:
                                            SizeConfig.safeBlockVertical * 0.2,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7),
                                  ),
                                  fillColor: _focusNodeDate.hasFocus
                                      ? Colors.transparent
                                      : (Theme.of(context)
                                                  .scaffoldBackgroundColor ==
                                              Colors.white
                                          ? Color(0xfff2f3f3)
                                          : Color(0xff1c1c1c)),
                                  filled: true,
                                  focusColor: Colors.black,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical:
                                          SizeConfig.safeBlockVertical * 1.5,
                                      horizontal:
                                          SizeConfig.safeBlockHorizontal * 4),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 3,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Time",
                                style: MyThemes.fieldHeadTextStyle,
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical * 1.2,
                              ),
                              TextFormField(
                                focusNode: _focusNodeTime,
                                readOnly: true,
                                onTap: () {
                                  _requestFocusTime();
                                  _handleTimePicker();
                                },
                                controller: _timeController,
                                style: MyThemes.fieldTextStyle,
                                cursorColor: Theme.of(context).primaryColor,
                                cursorHeight: SizeConfig.safeBlockVertical * 3,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width:
                                            SizeConfig.safeBlockVertical * 0.2,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7),
                                  ),
                                  fillColor: _focusNodeDate.hasFocus
                                      ? Colors.transparent
                                      : (Theme.of(context)
                                                  .scaffoldBackgroundColor ==
                                              Colors.white
                                          ? Color(0xfff2f3f3)
                                          : Color(0xff1c1c1c)),
                                  filled: true,
                                  focusColor: Colors.black,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical:
                                          SizeConfig.safeBlockVertical * 1.5,
                                      horizontal:
                                          SizeConfig.safeBlockHorizontal * 4),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 3,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Priority",
                                style: MyThemes.fieldHeadTextStyle,
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical * 1.2,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ChoiceChip(
                                    label: Text(
                                      "Low",
                                      style: MyThemes.fieldTextStyle,
                                    ),
                                    shadowColor: Colors.transparent,
                                    selectedShadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.safeBlockVertical *
                                                0.7)),
                                    labelPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.safeBlockHorizontal * 3,
                                        vertical:
                                            SizeConfig.safeBlockVertical * 0.6),
                                    selected: chipStates[0],
                                    onSelected: (value) {
                                      setState(() {
                                        chipStates = [value, !value, !value];
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: Text(
                                      "Medium",
                                      style: MyThemes.fieldTextStyle,
                                    ),
                                    shadowColor: Colors.transparent,
                                    selectedShadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.safeBlockVertical *
                                                0.7)),
                                    labelPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.safeBlockHorizontal * 3,
                                        vertical:
                                            SizeConfig.safeBlockVertical * 0.6),
                                    selected: chipStates[1],
                                    onSelected: (value) {
                                      setState(() {
                                        chipStates = [!value, value, !value];
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: Text(
                                      "High",
                                      style: MyThemes.fieldTextStyle,
                                    ),
                                    shadowColor: Colors.transparent,
                                    selectedShadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.safeBlockVertical *
                                                0.7)),
                                    labelPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.safeBlockHorizontal * 3,
                                        vertical:
                                            SizeConfig.safeBlockVertical * 0.6),
                                    selected: chipStates[2],
                                    onSelected: (value) {
                                      setState(() {
                                        chipStates = [!value, !value, value];
                                      });
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 5.6,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              widget.task != null
                                  ? (Container(
                                      child: Tooltip(
                                        decoration: BoxDecoration(
                                          color: (Theme.of(context)
                                                      .scaffoldBackgroundColor ==
                                                  Colors.white
                                              ? Color(0xfff2f3f3)
                                              : Color(0xff1c1c1c)),
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.safeBlockHorizontal *
                                                  1),
                                        ),
                                        textStyle: TextStyle(
                                          color: (Theme.of(context)
                                                      .scaffoldBackgroundColor ==
                                                  Colors.white
                                              ? Colors.black
                                              : Colors.white),
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  3.4,
                                          fontFamily: "Circular Std",
                                        ),
                                        message: "Delete Task",
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            primary: (Theme.of(context)
                                                        .scaffoldBackgroundColor ==
                                                    Colors.white
                                                ? Colors.white
                                                : Colors.black),
                                            backgroundColor: (Theme.of(context)
                                                        .scaffoldBackgroundColor ==
                                                    Colors.white
                                                ? Colors.black
                                                : Colors.white),
                                            animationDuration:
                                                Duration(milliseconds: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(SizeConfig
                                                          .safeBlockVertical *
                                                      0.7),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: SizeConfig
                                                        .safeBlockHorizontal *
                                                    7,
                                                vertical: 0),
                                          ),
                                          onPressed: () {
                                            _delete();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: SizeConfig
                                                        .safeBlockVertical *
                                                    0.6,
                                                bottom: SizeConfig
                                                        .safeBlockVertical *
                                                    0.6,
                                                right: SizeConfig
                                                        .safeBlockHorizontal *
                                                    1,
                                                left: SizeConfig
                                                        .safeBlockHorizontal *
                                                    1),
                                            child: Text(
                                              "×",
                                              style:
                                                  MyThemes.fieldButtonTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                  : (SizedBox()),
                              SizedBox(
                                width: SizeConfig.safeBlockHorizontal * 10,
                              ),
                              Container(
                                child: Tooltip(
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
                                  message: "Add Task",
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      backgroundColor: MyThemes.kPrimaryColor.value,
                                      animationDuration:
                                          Duration(milliseconds: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.safeBlockVertical * 0.7),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              SizeConfig.safeBlockHorizontal *
                                                  7,
                                          vertical: 0),
                                    ),
                                    onPressed: () {
                                      _submit();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: SizeConfig.safeBlockVertical *
                                              0.6,
                                          bottom: SizeConfig.safeBlockVertical *
                                              0.6,
                                          right:
                                              SizeConfig.safeBlockHorizontal *
                                                  1,
                                          left: SizeConfig.safeBlockHorizontal *
                                              1),
                                      child: Text(
                                        widget.task == null ? "+" : "≈",
                                        style: MyThemes.fieldButtonTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
