import 'package:flutter/material.dart';
import 'task.dart';

void main() {
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
      ),
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Task> _tasks = [];

  void _addTask(String text) {
    if (text.length > 1) {
      setState(() {
        _tasks.add(Task(text));
      });
    }
  }

  void _showModal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task',
                ),
                onSubmitted: (value) {
                  _addTask(value);
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
      appBar: AppBar(
        title: Text(
          'Todo',
          style: TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: _tasks.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Checkbox(
              value: _tasks[index].done,
            ),
            title: Text(
              _tasks[index].text,
              style: TextStyle(
                fontWeight: FontWeight.w300,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showModal,
        tooltip: 'Add Task',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
