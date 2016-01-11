//TODO: copyright

import 'dart:convert';

//TODO: what are the values of a case?

class Case {
  static const String $separator = ":";
  //TODO: add pattern
  static final RegExp idFormat = new RegExp("");
  //TODO: what is format of case id?
  //max length 16
  final String id;

  //max length?
  final String name;



  const Case._(this.id, this.name);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  static const foo = const Case._("0001-xyz", "foo");

  static Case parse(String s) {
    List<String> l = s.split($separator);
    return new Case._(l[0], l[1]);
  }

  static Case fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Case._(json['uuid'], json['id'], json['name'], json['ctepId'], json['idSourse'],
        json['group'], json['parent'], json['address'] );
  }
}
