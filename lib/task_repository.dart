import 'models/task.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task.create(
      title: "Zrobić projekt z TAI",
      deadline: "jutro",
      priority: "wysoki",
    ),
    Task.create(
      title: "Pouczyć się do kolokwium",
      deadline: "dzisiaj",
      priority: "wysoki",
      isDone: true,
    ),
    Task.create(
      title: "Ogarnąć Fluttera",
      deadline: "w piątek",
      priority: "średni",
    ),
    Task.create(
      title: "Nie mam pomysłu",
      deadline: "jutro",
      priority: "niski",
      isDone: true,
    ),
  ];
}
