import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tasks/models/task_model.dart';
import 'package:tasks/util/shared_prefs_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  static int switchPriority(String priority) {
    switch (priority) {
      case "Low":
        return 0;
        break;
      case "Medium":
        return 1;
        break;
      case "High":
        return 2;
        break;
      default:
        return -1;
    }
  }

  Comparator<Task> priorityComparator = (a, b) {
    if (a.status == b.status) {
      if (switchPriority(a.priority) > switchPriority(b.priority)) {
        return -1;
      } else if (switchPriority(a.priority) < switchPriority(b.priority)) {
        return 1;
      } else {
        if (a.date.difference(b.date).inSeconds > 0) {
          return -1;
        } else if (a.date.difference(b.date).inSeconds < 0) {
          return 1;
        } else {
          return 0;
        }
      }
    } else if (a.status < b.status) {
      return -1;
    } else {
      return 1;
    }
  };

  Comparator<Task> dateComparator = (a, b) {
    if (a.status == b.status) {
      return a.date.compareTo(b.date);
    } else if (a.status < b.status) {
      return -1;
    } else {
      return 1;
    }
  };

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }

    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $tasksTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority Text, $colStatus INTEGER)",
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(tasksTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });

    if (sharedPrefs.isSortingByDate) {
      taskList.sort(dateComparator);
    } else {
      taskList.sort(priorityComparator);
    }

    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(tasksTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      tasksTable,
      task.toMap(),
      where: "$colId = ?",
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(Task task) async {
    Database db = await this.db;
    final int result = await db.delete(
      tasksTable,
      where: "$colId = ?",
      whereArgs: [task.id],
    );
    print("DEBUG: $result");
    return result;
  }
}
