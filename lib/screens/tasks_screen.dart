import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks/models/task_model.dart';
import 'package:tasks/screens/add_task_screen.dart';
import 'package:tasks/util/database_helper.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:tasks/util/task_icons_icons.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Future<List<Task>> _taskList;

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _taskList = DatabaseHelper.instance.getTaskList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    MyThemes().initBlock(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            TaskIcons.approve,
            color: Theme.of(context).scaffoldBackgroundColor,
            size: SizeConfig.safeBlockVertical * 4,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return AddTaskScreen(
                updateListCallback: _updateTaskList,
              );
            }));
          },
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
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    backgroundColor: kPrimaryColor.withOpacity(0.3),
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
                        Text(
                          "My Tasks",
                          style: MyThemes.headTextStyle,
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
  TaskTile({@required this.task, this.callback});

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool myValue = true;

  final DateFormat _dateFormatter = DateFormat('dd MMMM, yyyy');
  final DateFormat _timeFormatter = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: SizeConfig.safeBlockVertical * 1.2,
              bottom: SizeConfig.safeBlockVertical * 1.2,
              left: SizeConfig.safeBlockHorizontal * 5.6,
              right: SizeConfig.safeBlockHorizontal * 4),
          child: ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return AddTaskScreen(
                    task: widget.task,
                    updateListCallback: widget.callback,
                  );
                },
              ));
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
            subtitle: Text(
              "${_dateFormatter.format(widget.task.date)} @ ${_timeFormatter.format(widget.task.date)} • ${widget.task.priority}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: "Circular Std",
                  fontWeight: FontWeight.normal,
                  fontSize: SizeConfig.safeBlockVertical * 1.7,
                  decoration: widget.task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            trailing: Checkbox(
              checkColor:
                  Theme.of(context).scaffoldBackgroundColor == Colors.white
                      ? Colors.white
                      : Colors.black,
              onChanged: (value) {
                widget.task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(widget.task);
                widget.callback();
                setState(() {});
              },
              activeColor: Theme.of(context).primaryColor,
              value: widget.task.status == 1 ? true : false,
            ),
          ),
        ),
      ],
    );
  }
}
