import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(MyApp());
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

  void toggleTaskStatus(int index) {
    setState(() {
      TaskRepository.tasks[index].isDone = !TaskRepository.tasks[index].isDone; // prosty switch logiczny.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // jest scaffold
        appBar: AppBar( // poprawilem troche appbar, zeby ladniej wpasowal sie w wybrana przeze mnie kolorystyke, podstawowy material design
          title: const Text(
            "KrakFlow",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
        ),
        body: Center( // zrezygnowalem z padding, wedle pliku z zadania.
          child: Column(
            children: [

              const SizedBox(height: 10), // większy spacer

              // sekcja statystyk
              Text(
                "Masz dziś ${TaskRepository.tasks.length} zadania",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),

              const SizedBox(height: 6), // większy spacer

              // nagłówek
              const Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 18), // spacerS

              Expanded( // musi byc expanded, inaczej jest problem z renderowaniem takiej listy.
                child:   
                ListView.builder( // lista zadań, zrobiona za pomocą ListView.builder
                  itemCount: TaskRepository.tasks.length,
                  itemBuilder: (context, index) {
                    final task = TaskRepository.tasks[index];
                    
                    return GestureDetector( // dodalem gesture detector, skoro mamy juz stateful widget, mozemy zmieniac stan zadania po "tapnięciu" na nie, owijamy jakby kazda karte zadania w GestureDetector.
                      onTap: () => toggleTaskStatus(index), // zmiana statusu zadania po kliknięciu
                      child: TaskCard(
                        title: task.title,
                        subtitle: "Deadline: ${task.deadline} | Priority: ${task.priority}\nStatus: ${task.isDone ? "Zrobione" : "Do zrobienia"}",
                        icon: task.isDone ? Icons.check_circle : Icons.circle_outlined, // ikona zależna od statusu zadania, mozna je dowolnie zmieniac klikajac w karte zadania.
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton( // dodalem floating action button

          onPressed: () async {
             // dodanie akcji floatingactionbutton, po kliknieciu przechodzi do AddTaskScreen.
              final Task? newTask = await Navigator.push( // tzw "optional", czyli moze byc nullem (pusta)
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return AddTaskScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            if (newTask != null) { // jesli nowe zadanie nie jest nullem, dodajemy je do listy zadan i odswiezamy ekran.
              setState(() {
                TaskRepository.tasks.add(newTask);
              });
            }
          },

          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          child: const Icon(
            Icons.add,
            color: Colors.black,
            ),
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
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
              ),
            ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Deadline",
              ),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { 

               if(titleController.text.isEmpty || deadlineController.text.isEmpty || priorityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Center( child: Text("Wszystkie pola muszą być wypełnione!")), duration: Duration(seconds: 2),), // dodalem jeszcze snackbar z informacja o pustych polach.
                  );
                  return; // nie przechodzimy dalej, jesli jakies pole jest puste
                }else {
               
                  final newTask = Task(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                    isDone: false,
                  );

                  Navigator.pop(context, newTask); // powrót do poprzedniego ekranu zwrot kontekstu

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