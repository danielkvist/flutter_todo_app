import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  String _id;
  @HiveField(1)
  String _text;
  @HiveField(2)
  bool _done = false;

  Task(this._id, this._text);

  // Getter
  String get id => this._id;
  String get text => this._text;
  bool get done => this._done;

  // Setters
  set done(bool done) {
    this._done = done;
  }
}
