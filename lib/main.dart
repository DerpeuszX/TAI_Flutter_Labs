import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// ================= MODEL =================
class Task {
  final String title;
  final String deadline;

  Task({
    required this.title,
    required this.deadline,
  });
}

// ================= TASK CARD =================
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// ================= APP =================
class MyApp extends StatelessWidget {
  MyApp({super.key});

  // lista 4 zadań (inne niż w przykładzie)
  final List<Task> tasks = [
    Task(title: "Zrobić projekt z TAI", deadline: "jutro"),
    Task(title: "Pouczyć się do kolokwium", deadline: "dzisiaj"),
    Task(title: "Ogarnąć Fluttera", deadline: "w piątek"),
    Task(title: "Zrobić zakupy", deadline: "w weekend"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("KrakFlow"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              // sekcja statystyk
              Text(
                "Masz dziś ${tasks.length} zadania",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),

              const SizedBox(height: 12), // większy spacer

              // nagłówek
              const Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 16), // spacer

              // lista
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline}",
                      icon: Icons.radio_button_unchecked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}