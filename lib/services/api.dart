import 'dart:convert';
import 'package:http/http.dart' as http;
import '/task_repository.dart';

class Api {
  // pobieramy dane z API i mapujemy je na model listy zadan Task
  // API zwraca dane w formacie JSON, więc musimy je zdekodować i przekształcić na listę obiektów Task
  static Future<List<Task>> fetchTodos() async {
    final uri = Uri.parse('https://dummyjson.com/todos');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(resp.body);
        final List<dynamic> todos =
            body['todos'] ??
            []; // sprawdzenie czy klucz 'todos' w ogole istnieje, w innym przypadku przypisanie pustej listy, aby uniknąć błędów podczas mapowania danych.

        List<Task> tasks = todos.map((dynamic t) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(t);
          final int? userId = json['userId'] is int
              ? json['userId'] as int
              : null;

          // losowe przypisanie priorytetu na podstawie userId, aby dodać różnorodność do danych

          String priorityFromUserId(int? id) {
            if (id == null) return 'średni';
            switch (id % 4) {
              case 0:
                return 'bardzo wysoki';
              case 1:
                return 'wysoki';
              case 2:
                return 'średni';
              default:
                return 'niski';
            }
          }

          // zwracanie gotowej listy zadań Task, gdzie każdy element jest mapowany z danych JSON, a priorytet jest losowo przypisany na podstawie userId, aby dodać różnorodność do danych.

          return Task(
            title: (json['todo'] ?? '').toString(),
            deadline: json['due']?.toString() ?? 'brak',
            priority: priorityFromUserId(userId),
            isDone: (json['completed'] ?? false) as bool,
          );
        }).toList();

        return tasks;
      } else {
        throw Exception('Failed to load todos: ${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
