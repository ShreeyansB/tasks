import 'package:flutter/material.dart';
import 'package:tasks/screens/add_task_screen.dart';
import 'package:tasks/util/size_config.dart';
import 'package:tasks/util/themes.dart';
import 'package:tasks/util/task_icons_icons.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    MyThemes().initBlock(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(TaskIcons.add_variable, color: Theme.of(context).scaffoldBackgroundColor,),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return AddTaskScreen();
            }));
          },
        ),
        body: ListView.builder(
          padding: EdgeInsets.only(
              top: SizeConfig.safeBlockVertical * 3.3,
              bottom: SizeConfig.safeBlockVertical * 10),
          itemCount: 10,
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
                        "1 of 10",
                        style: MyThemes.subTextStyle.copyWith(
                          color: Theme.of(context).scaffoldBackgroundColor ==
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
                index: index,
              );
            }
          },
        ),
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  final int index;

  TaskTile({@required this.index});

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool myValue = true;

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
            title: Text(
              "Task Title",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: "Circular Std",
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.safeBlockVertical * 2.3),
            ),
            subtitle: Text(
              "March 2nd 2021 • High",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: "Circular Std",
                  fontWeight: FontWeight.normal,
                  fontSize: SizeConfig.safeBlockVertical * 1.7),
            ),
            trailing: Checkbox(
              checkColor: Theme.of(context).scaffoldBackgroundColor == Colors.white ? Colors.white : Colors.black,
              onChanged: (value) {
                setState(() {
                  myValue = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              value: myValue,
            ),
          ),
        ),
      ],
    );
  }
}
