// Copyright (c) 2016, American College of Radiology. All rights reserved.
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
//TODO: copyright
library acr.client.ati_uploader.group;

///

/// 

import 'dart:convert';

//TODO: what are the values of a case?

class Group {
  static const String $separator = ":";
  //TODO: add pattern
  static final RegExp idFormat = new RegExp("");
  //TODO: what is format of case id?
  //max length 16
  final String id;

  //max length?
  final String name;

  const Group._(this.id, this.name);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  static const foo = const Group._("0001-xyz", "foo");

  static Group parse(String s) {
    List<String> l = s.split($separator);
    return new Group._(l[0], l[1]);
  }


  static Group fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Group._(json['uuid'], json['id'], json['name'], json['ctepId'], json['idSourse'],
        json['group'], json['parent'], json['address'] );
  }
}