//TODO: copyright

///
///
import 'dart:html';

/// An Audit Log Entry
class LogEntry {
  String   user;
  DateTime timestamp;
  String   status;
  String   message;

  LogEntry(this.status, this.message) {
    user = User.user;
    timestamp = new DateTime.now();
  }
}
