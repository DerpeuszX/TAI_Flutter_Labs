class Task {
  String id;
  String title;
  String deadline;
  String priority;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.priority,
    required this.isDone,
  });

  factory Task.create({
    required String title,
    required String deadline,
    required String priority,
    bool isDone = false,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return Task(
      id: id,
      title: title,
      deadline: deadline,
      priority: priority,
      isDone: isDone,
    );
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id:
          map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      deadline: map['deadline']?.toString() ?? '',
      priority: map['priority']?.toString() ?? '',
      isDone: map['isDone'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'priority': priority,
      'isDone': isDone,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? deadline,
    String? priority,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }
}
