import '../models/task.dart';
import 'api.dart';
import 'task_local_database.dart';

class TaskSyncService {
  final TaskLocalDatabase db;

  TaskSyncService({required this.db});

  /// Pobiera zadania z API i zapisuje je do lokalnej bazy (nadpisuje istniejące o tym samym id)
  Future<List<Task>> fetchFromApiAndSaveToDb() async {
    await db.init();
    final List<Task> remote = await Api.fetchTodos();
    for (final t in remote) {
      await db.saveTask(t);
    }
    return db.getAllTasks();
  }

  Future<List<Task>> getAllFromDb() async {
    await db.init();
    return db.getAllTasks();
  }

  Future<void> addOrUpdate(Task task) async {
    await db.init();
    await db.saveTask(task);
  }

  Future<void> deleteById(String id) async {
    await db.init();
    await db.deleteTask(id);
  }

  Future<void> deleteAll() async {
    await db.init();
    await db.deleteAll();
  }
}
