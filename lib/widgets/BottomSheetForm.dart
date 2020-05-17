import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class BottomSheetForm extends StatefulWidget {
  const BottomSheetForm({
    Key key,
    @required Task existingTask,
  })  : _task = existingTask,
        super(key: key);

  final Task _task;

  @override
  _BottomSheetFormState createState() => _BottomSheetFormState();
}

class _BottomSheetFormState extends State<BottomSheetForm> {
  final _uuid = Uuid();
  final _tasksBox = Hive.box('flutter_tasks');

  void _addTask(String text) {
    if (text.length > 1) {
      final task = Task(_uuid.v4(), text);
      _tasksBox.put(task.id, task);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            textCapitalization: TextCapitalization.sentences,
            controller: TextEditingController(
              text: widget._task != null ? widget._task.text : '',
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Task',
            ),
            onSubmitted: (value) {
              if (widget._task == null) {
                _addTask(value);
              } else if (widget._task != null && value.length > 1) {
                widget._task.text = value;
                _tasksBox.put(widget._task.id, widget._task);
              }

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
