//TODO: copyright

import 'dart:convert';

import 'package:odw/date.dart';
import 'package:odw/uuid.dart';



class Category {
  static const String $separator = ":";
  final Uuid uuid;

  // max length 36
  final String name;

  // max length ???
  final Date startDate;
  final Date endDate;

  const Category._(this.uuid, this.name, this.startDate, this.endDate);

  //TODO: what syntax
  String toString() => '$uuid:$name';

  //TODO: define projects
  static final foo = new Category._('0001-xyz', 'foo', '01Jan2015', '01Jan2016');

  static Category parse(String s) {
    List<String> l = s.split($separator);
    Date startDate = new Date(l[2]);
    Date endDate = new Date(l[2]);
    return new Category._(l[0], l[1], startDate, endDate);
  }

  static Category fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Category._(json['uuid'], json['id'], json['name'], json['ctepId'], json['idSourse'],
        json['group'], json['parent'], json['address'] );
  }
}
