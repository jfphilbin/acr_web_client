// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library submission;

import 'dart:convert';
import 'dart:typed_data';

// ACR Client packages
import 'package:uploader/src/types/exam.dart';
import 'selection_file.dart';
import 'package:uploader/src/types/modality.dart';
import 'triad_id.dart';
import 'package:uploader/src/types/user.dart';

/// A Triad Submission
class Submission {
  final TriadId id;
  final Exam exam;
  final User user;
  final Modality modality;
  final List<SelectionFile> files;
  final String savedFileName;
  final bool isAppend;
  final bool isFileCompleted;
  final bool isAppeal;

  String get examId => exam.id;

  String get totalBytes => getTotalBytes();

  Submission(this.id, this.exam, this.modality, this.files, this.savedFileName);

  int getTotalBytes() {
    //TODO: walk [files] and get a total
  }

  String getPayload() {
    Map payload = {
      "fileInfo": {
        "Domain": 'ATI',
        "TransactionGuid": user.commandGuid,
        "UserDetail": user.name,
        "PrimaryParentId": id.primary,
        "SecondaryParentId": id.secondary,
        "TertiaryParentId": examId,
        "ExpTotalNoOfFiles": files.length, //numberOfFilesInCurrentUploadSelection,
        "ExpTotalFileSize": totalBytes,
        "ExamName": exam.name,
        "ExamType": exam.type,
        "Modality": modality,
        "FileName": savedFileName,
        "FileType": getFileType(filename),
        "AppendFlag": (isAppend == false) ? 0 : 1,
        "FileCompletedFlag": (sliceNumber == numberOfChunks - 1) ? 0 : 2,
        "IsAppeal": (isAppeal == '1') ? 'true' : 'false'
      },
      "base64FileContent": base64String
    };

    return JSON.encode(payload);
  }
}
