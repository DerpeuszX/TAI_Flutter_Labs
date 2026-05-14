import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasksBox');

  runApp(MyApp());
}

// ================= FILTER BAR =================
class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ["wszystkie", "do zrobienia", "wykonane"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: filters.map((filter) {
        final isActive = selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: isActive
                  ? Colors.deepPurpleAccent
                  : Colors.transparent,
              foregroundColor: isActive
                  ? Colors.white
                  : Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.deepPurpleAccent,
                  width: isActive ? 0 : 1,
                ),
              ),
            ),
            onPressed: () {
              onFilterChanged(filter);
            },
            child: Text(
              filter == "wszystkie"
                  ? "Wszystkie"
                  : filter == "do zrobienia"
                  ? "Do zrobienia"
                  : "Wykonane",
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ================= TASK CARD =================
class TaskCard extends StatelessWidget {
  final String title;
  final String deadline;
  final String priority;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onIconTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.priority,
    required this.deadline,
    required this.icon,
    this.onTap,
    this.onIconTap,
  });

  // switch w zaleznosci od sparsowanej wartosci priorytetu, zwraca odpowiedni kolor. Jesli priorytet jest nieznany, zwraca szary.

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "bardzo wysoki":
        return Colors.redAccent;
      case "wysoki":
        return Colors.orangeAccent;
      case "średni":
        return const Color.fromARGB(255, 184, 184, 4);
      case "niski":
        return Colors.greenAccent;
      default:
        return Colors.grey; // domyślny kolor dla nieznanych priorytetów
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: IconButton(icon: Icon(icon), onPressed: onIconTap),
        title: Text(
          title,
          style: TextStyle(
            decoration: icon == Icons.check_circle
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: icon == Icons.check_circle ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deadline: $deadline'),
            const SizedBox(height: 4),
            Text(
              'Priorytet: $priority',
              style: TextStyle(
                color: _getPriorityColor(priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// ================= APP =================

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

// ================= HOME SCREEN =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ================= HOME SCREEN STATE =================

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie"; // aktualnie wybrany filtr
  final TaskLocalDatabase _taskLocalDatabase = TaskLocalDatabase();
  late final TaskSyncService _taskSyncService;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _taskSyncService = TaskSyncService(db: _taskLocalDatabase);
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await _taskSyncService.getAllFromDb();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeleteAllTasks() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () async {
                await _taskSyncService.deleteAll();
                if (!context.mounted) return;
                Navigator.pop(context);
                await _loadFromDb();
              },
              child: const Text("Usuń"),
            ),
          ],
        );
      },
    );
  }

  // Fetchowanie future danych z API, ustawianie stanu ładowania i obsługa błędów. Po udanym pobraniu danych, aktualizujemy listę zadań w repozytorium i pokazujemy snackbar z informacją o sukcesie. W przypadku błędu, ustawiamy komunikat błędu i pokazujemy snackbar z informacją o błędzie.

  Future<void> _loadFromApi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _taskSyncService.fetchFromApiAndSaveToDb();
      setState(() {
        _tasks = _taskSyncService.db.getAllTasks();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Pobrano zadania z API'))),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Błąd: ${e.toString()}'))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    final updatedTask = task.copyWith(isDone: !task.isDone);
    await _taskSyncService.addOrUpdate(updatedTask);
    await _loadFromDb();
  }

  Future<void> removeTask(Task task) async {
    await _taskSyncService.deleteById(task.id);
    await _loadFromDb();
  }

  @override
  Widget build(BuildContext context) {
    // zmienna pomocnicza przetrzymująca obecnie przefiltrowaną listę
    List<Task> filteredTasks = _tasks;
    // logika filtrowania
    if (selectedFilter == "wykonane") {
      filteredTasks = _tasks.where((task) => task.isDone).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = _tasks.where((task) => !task.isDone).toList();
    }

    return Scaffold(
      // jest scaffold
      appBar: AppBar(
        // poprawilem troche appbar, zeby ladniej wpasowal sie w wybrana przeze mnie kolorystyke, podstawowy material design
        title: const Text(
          "KrakFlow",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (_tasks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(child: Text("Brak zadań do usunięcia!")),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                _confirmDeleteAllTasks();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cloud_download),
                    onPressed: _loadFromApi,
                  ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Błąd: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: Center(
              // zrezygnowalem z padding, wedle pliku z zadania.
              child: Column(
                children: [
                  const SizedBox(height: 10), // większy spacer
                  // sekcja statystyk
                  Text(
                    "Masz dziś ${_tasks.length} zadania",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 6), // większy spacer
                  // nagłówek
                  const Text(
                    "Dzisiejsze zadania",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),
                  // button row do filtrowania zadan
                  FilterBar(
                    selectedFilter: selectedFilter,
                    onFilterChanged: (newFilter) {
                      setState(() {
                        selectedFilter = newFilter;
                      });
                    },
                  ),

                  const SizedBox(height: 18), // spacerS

                  Expanded(
                    // musi byc expanded, inaczej jest problem z renderowaniem takiej listy.
                    child: ListView.builder(
                      // lista zadań, zrobiona za pomocą ListView.builder
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];

                        return Dismissible(
                          key: ValueKey(task.id),
                          direction:
                              DismissDirection.startToEnd, // tylko w prawo
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 16),
                            color: Colors.redAccent,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            removeTask(task); // usun zadanie po przesunieciu
                            ScaffoldMessenger.of(context).showSnackBar(
                              // pokaz snackbar potwierdzajacy usuniecie zadania
                              SnackBar(
                                content: Center(
                                  child: Text(
                                    'Zadanie "${task.title}" usunięte',
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: TaskCard(
                            title: task.title,
                            deadline: task.deadline,
                            priority: task.priority,
                            icon: task.isDone
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            onIconTap: () {
                              toggleTaskStatus(task);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                    child: Text(
                                      task.isDone
                                          ? 'Zadanie "${task.title}" oznaczone jako zrobione'
                                          : 'Zadanie "${task.title}" oznaczone jako do zrobienia',
                                    ),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            onTap: () async {
                              // otwórz ekran edycji
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTaskScreen(task: task),
                                ),
                              );
                              if (updated != null && updated is Task) {
                                await _taskSyncService.addOrUpdate(updated);
                                await _loadFromDb();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text(
                                        'Zadanie "${updated.title}" zostało zaktualizowane',
                                      ),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // dodalem floating action button
        onPressed: () async {
          // dodanie akcji floatingactionbutton, po kliknieciu przechodzi do AddTaskScreen.
          final Task? newTask = await Navigator.push(
            // tzw "optional", czyli moze byc nullem (pusta)
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return AddTaskScreen();
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0, 1.0); // z dołu do góry.
                    const end = Offset.zero;

                    final tween = Tween(begin: begin, end: end);
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
            ),
          );
          if (newTask != null) {
            // jesli nowe zadanie nie jest nullem, dodajemy je do listy zadan i odswiezamy ekran.
            await _taskSyncService.addOrUpdate(newTask);
            await _loadFromDb();
          }
        },
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ================= AddTaskScreen =================

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Tytuł zadania"),
            ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(labelText: "Deadline"),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(labelText: "Priorytet"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    deadlineController.text.isEmpty ||
                    priorityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text("Wszystkie pola muszą być wypełnione!"),
                      ),
                      duration: Duration(seconds: 2),
                    ), // dodalem jeszcze snackbar z informacja o pustych polach.
                  );
                  return; // nie przechodzimy dalej, jesli jakies pole jest puste
                } else {
                  final newTask = Task.create(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                  );

                  Navigator.pop(
                    context,
                    newTask,
                  ); // powrót do poprzedniego ekranu zwrot kontekstu
                }
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;

  EditTaskScreen({super.key, required this.task});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = task.title;
    deadlineController.text = task.deadline;
    priorityController.text = task.priority;

    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Tytuł zadania"),
            ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(labelText: "Deadline"),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(labelText: "Priorytet"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    deadlineController.text.isEmpty ||
                    priorityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text("Wszystkie pola muszą być wypełnione!"),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                } else {
                  final updatedTask = task.copyWith(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                  );

                  Navigator.pop(context, updatedTask);
                }
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}
