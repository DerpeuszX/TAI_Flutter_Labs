import 'package:hive_ce/hive_ce.dart';
import '../models/task.dart';

class TaskLocalDatabase {
  final String boxName = 'tasksBox';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  List<Task> getAllTasks() {
    final box = Hive.box(boxName);
    final List<Task> tasks = [];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        tasks.add(Task.fromMap(Map<dynamic, dynamic>.from(data)));
      }
    }
    return tasks;
  }

  Task? getTaskById(String id) {
    final box = Hive.box(boxName);
    final data = box.get(id);
    if (data == null) return null;
    return Task.fromMap(Map<dynamic, dynamic>.from(data));
  }

  Future<void> saveTask(Task task) async {
    final box = Hive.box(boxName);
    await box.put(task.id, task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await saveTask(task);
  }

  Future<void> deleteTask(String id) async {
    final box = Hive.box(boxName);
    await box.delete(id);
  }

  Future<void> deleteAll() async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}
