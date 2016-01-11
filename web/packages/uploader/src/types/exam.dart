// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library exams;

///TODO: document

import 'dart:convert';

import "modality.dart";

/// A Medical Imaging Examination (Study).
class Exam {
  String id;
  String name;
  String type;
  Modality modality;
  String filename;
  String fileType;
  List<String> files;

  Exam(this.name, this.type, this.modality, this.files, this.filename, this.fileType);

  void add(String file) { files.add(file); }

  static Exam fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Exam._(json['uuid'], json['id'], json['name'], json['ctepId'], json['idSourse'],
        json['group'], json['parent'], json['address'] );
  }
}

//TODO: add Map Mixin
class AllExams {
  Map<String, Exam> _exams;

  Exam operator [](String name) => _exams[name];
  void operator []=(String name, Exam exam) { _exams[name] = exam; }

  /// Returns a [Map<String, Exam>] of the current list of [Exam]s.
  Map<String, Exam> get map => _exams;

  void add(String name, Exam exam) { _exams[name] = exam; }

  void remove(String name, Exam exam) { _exams.remove(name); }
}
