import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialization
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(TaskAdapter());

  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: Colors.transparent,
      ),
      home: FutureBuilder(
        future: Hive.openBox('flutter_tasks'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Check if box is open
          if (snapshot.connectionState == ConnectionState.done) {
            // Check if operation had errors
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return TodoList();
            }
          } else {
            // Show an empty Scaffold while box is opening
            return Scaffold(
              backgroundColor: Colors.white,
            );
          }
        },
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  var _uuid = Uuid();
  final _tasksBox = Hive.box('flutter_tasks');

  void _addTask(String text) {
    if (text.length > 1) {
      final task = Task(_uuid.v4(), text);
      final tasksBox = Hive.box('flutter_tasks');
      tasksBox.put(task.id, task);
    }
  }

  void _showModal(Task existingTask) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return AnimatedContainer(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                autofocus: true,
                autocorrect: true,
                controller: TextEditingController(
                  text: existingTask.text,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task',
                ),
                onSubmitted: (value) {
                  if (existingTask == null) {
                    _addTask(value);
                  } else if (existingTask != null && value.length > 1) {
                    existingTask.text = value;
                    _tasksBox.put(existingTask.id, existingTask);
                  }

                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Todo',
          style: TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _tasksBox.listenable(),
        builder: (context, box, widget) => ListView.separated(
          itemCount: _tasksBox.length,
          separatorBuilder: (context, index) {
            final task = _tasksBox.getAt(index) as Task;
            return Visibility(
              visible: !task.done,
              child: Divider(),
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final task = _tasksBox.getAt(index) as Task;

            return Visibility(
              visible: !task.done,
              replacement: Container(),
              child: Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red[500],
                  child: Padding(
                    padding: EdgeInsets.only(right: 9.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onDismissed: (direction) => {_tasksBox.delete(task.id)},
                child: ListTile(
                  onLongPress: () => {_showModal(task)},
                  leading: Checkbox(
                    value: task.done,
                    onChanged: (value) {
                      task.done = value;
                      _tasksBox.put(task.id, task);
                    },
                  ),
                  title: Text(
                    task.text,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_showModal(null)},
        tooltip: 'Add Task',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up Hive when app is closed
    Hive.close();
    super.dispose();
  }
}
