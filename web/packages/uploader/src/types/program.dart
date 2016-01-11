//TODO: copyright

import 'package:odw/date.dart';
import 'package:odw/uuid.dart';

import 'package:uploader/src/types/category.dart';

class Program {
  static const String $separator = ":";
  final Uuid id;

  // max length 36
  final String name;

  // max length 256
  final Category category;
  final Date startDate;
  final Date endDate;

  const Program._(this.id, this.name, this.category, this.startDate, this.endDate);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  static const foo = const Program._("0001-xyz", "foo");

  static Program parse(String s) {
    List<String> l = s.split($separator);
    return new Program._(l[0], l[1]);
  }

  static Program fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Program._(json['uuid'], json['id'], json['name'], json['ctepId'], json['idSourse'],
        json['group'], json['parent'], json['address'] );
  }
}
