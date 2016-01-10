import 'package:odw/date.dart';

class Category {
  static const String $separator = ":";
  final Uuid id;

  // max length 36
  final String name;

  // max length 256
  final Category category;
  final Date startDate;
  final Date endDate;

  const Program._(this.id, this.name) {

  }

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  const foo = const Program._("0001-xyz", "foo");

  static Program parse(String s) {
    List<String> l = s.split($separator);
    return new Project(l[0], l[1]);
  }
}
