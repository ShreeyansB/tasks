import 'package:flutter/material.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String priority;
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

    if (mytime != null &&
        (mytime.hour != date.hour && mytime.minute != date.minute)) {
      setState(() {
        DateTime newDate = DateTime(date.year, date.month, date.day, mytime.hour,
            mytime.minute, date.second, date.millisecond, date.microsecond);
        date = newDate;
        _timeController.text = _timeFormatter.format(date);
      });

    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _focusNodeDate = FocusNode();
    _focusNodeTime = FocusNode();
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
    print("${date.hour} - ${date.minute}");
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print(title + date.toString() + chipStates.toString());

      // Insert/Update Task to DB

      Navigator.pop(context);
    }
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
                      "Add Task",
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
                                              SizeConfig.safeBlockVertical * 16.6,
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
                          Align(
                            alignment: Alignment.centerRight,
                                                      child: Container(
                              child: FlatButton(
                                colorBrightness:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Brightness.dark
                                        : Brightness.light,
                                color: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.safeBlockVertical * 0.7)),
                                onPressed: () {
                                  _submit();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: SizeConfig.safeBlockVertical *0.6,
                                    bottom: SizeConfig.safeBlockVertical*0.6,
                                    right: SizeConfig.safeBlockHorizontal*1,
                                    left: SizeConfig.safeBlockHorizontal*1
                                  ),
                                  child: Text(
                                    "+",
                                    style: MyThemes.fieldButtonTextStyle,
                                  ),
                                ),
                              ),
                            ),
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
