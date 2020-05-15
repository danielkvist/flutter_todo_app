import 'package:uuid/uuid.dart';

class Task {
  String _id;
  String _text;
  bool _done = false;

  Task(String text) {
    this._id = Uuid().v4().toString();
    this._text = text;
  }

  // Getter
  String get id => this._id;
  String get text => this._text;
  bool get done => this._done;

  // Setters
  set done(bool done) {
    this._done = done;
  }
}
