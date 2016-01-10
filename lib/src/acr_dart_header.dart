//TODO: copyright

import 'dart:typed_data';
import 'package:odw/content_type.dart';
import 'package:odw/uuid.dart';


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
  final Uuid id;

  // An identifier for an object stored in DART.
  final DateTime created;
  final DateTime modified;
  final int revision;
  final String workflowStep;

  // max length 32
  final ObjectType _type;

  // max length 32
  final ContentType contentType;
  final Project project;
  final Site site;

  // max length 16
  final Case acrCase;

  // max length 16
  final Uint8List payload;

  DartHeader.create

  (

  String oType, String

  cType

  ,

  this

  project

  ,

  this

      .

  site

  ,

  this

      .

  acrCcase

  ,

  this

      .

  payload

  )

  {
  DateTime now = new DateTime(now);
  id = new Uuid();
  created = now;
  modified = now;
  revision = 0;
  workflowStep = WorkflowStep.submitted; //TODO: finish
  type = ObjectType.parse(otype);
  contentType = ContentType.parse(cType);
  project = Project.lookup(projId);
  projectName = Project.name.lookup(projName);
  siteId = Id.lookup(projId);
  }

  //TODO: can this be string and/or Uint8List
  static DartHeader parse(String header) {

  }

  static DartHeader readJson(String s) {

  }

  static void writeJson(DartHeader header) {

  }

}
