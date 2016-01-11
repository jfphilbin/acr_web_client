//TODO: copyright

import 'dart:typed_data';

import 'package:odw/content_type.dart';
import 'package:odw/uuid.dart';

import 'case.dart';
import 'project.dart';
import 'site.dart';

enum WorkflowStep { submitted, revisionRequired, published }

enum ObjectType {
  imagingStudy,
  annotation,
  image,
  pathologyImage,
  clinicalForm,
  bioSpecimen,
  genomic,
  meg,
  matlabScript,
  matlabDataset,
  rScript,
  rDataset,
  sasScript,
  sasDataset
}

/// The ACR DART (TODO: fix Data Archive Research Technology) header
///
class DartHeader {
  //TODO: make fields immutable
  Uuid uuid;

  // An identifier for an object stored in DART.
  DateTime created;
  DateTime modified;
  int revision;
  WorkflowStep workflowStep;

  // max length 32
  final ObjectType oType;

  // max length 32
  final ContentType contentType;
  final Project project;
  final Site site;

  // max length 16
  final Case acrCase;

  // max length 16
  final Uint8List payload;

  DartHeader(this.oType, this.contentType, this.project,
      this.site, this.acrCase, this.payload) {
    uuid = new Uuid();
    created = new DateTime.now();
    modified = created;
    revision = 0;
    workflowStep = WorkflowStep.submitted;
  }

  //TODO: can this be string and/or Uint8List
  static DartHeader parse(String header) {
    return new DartHeader();
  }

  static DartHeader readJson(String s) {
    return new DartHeader();
  }

  static void writeJson(DartHeader header) {

  }

}
