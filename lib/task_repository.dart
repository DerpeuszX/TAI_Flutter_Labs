class Task {
  final String title;
  final String deadline;
  final String priority; // dodalem pole priority
  bool isDone;

  Task({
    required this.title,
    required this.deadline,
    required this.priority,
    required this.isDone,
  });
}



class TaskRepository {


  static List<Task> tasks = [
    Task(
      title: "Zrobić projekt z TAI",
      deadline: "jutro",
      priority: "wysoki",
      isDone: false,
    ),
    Task(
      title: "Pouczyć się do kolokwium",
      deadline: "dzisiaj",
      priority: "uber wysoki",
      isDone: true,
    ),
    Task(
      title: "Ogarnąć Fluttera",
      deadline: "w piątek",
      priority: "średni",
      isDone: false,
    ),
    Task(
      title: "Nie mam pomysłu", 
      deadline: "jutro", 
      priority: "niski", 
      isDone: true
    ),
  ];

}