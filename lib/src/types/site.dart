//TODO: copyright

import 'dart:convert';
import 'package:odw/Uuid.dart';
import 'package:uploader/src/types/address.dart';
import 'package:uploader/src/types/group.dart';
//TODO: what are the values of a site?

class Site {
  static const String $separator = ":";
  final Uuid uuid;
  final String id;

  //max length 16
  final String name;

  //max length 256
  final String ctepId;

  //TODO: should this be a code
  final String idSource;

  // NRDR, CTEP, DART, etc.
  /// The CTMS [Group] that claimed the [Site]
  final Group group;

  //TODO: create code table

  /// The parent [Site] of this [Site]
  final Site parent;

  /// The CTEP ID of the parent [Site]
  final Address address;

  /// Constant Constructor
  const Site._(this.uuid, this.id, this.name, this.ctepId, this.idSource, this.group, this.parent,
      this.address);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: finish
  static const foo = const Site._("0001-xyz", "foo");

  static Site parse(String s) {
    List<String> l = s.split($separator);
    return new Site._(l[0], l[1]);
  }

  static Site fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Site._(json['uuid'], json['id'], json['name'], json['ctepId'], json['idSourse'],
        json['group'], json['parent'], json['address'] );
  }

}
