// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library files;

import 'package:path/path.dart' as Path;
///

/// 
class SelectionFile {
  String name;
  String type;
  String status;
  //TODO: what else

  String get extension(String filename) => Path.extension(filename);

  static const List<String> imageFileExtensions = const [ "jpg", "jpeg", "png", "gif", "bmp", "tif", "raw"];
  static const List<String> movieFileExtensions = const ["avi", "mpg", "mp4", "mov", "wmv"];
  static const List<String> dicomFileExtensions = const ["dcm", ""];

  String getFileType(String filename) {
    String ext = Path.extension(filename).toLowerCase();
    int offset = imageFileExtensions.indexOf(ext);
    if (offset > 0) return "IMAGE";
    offset = movieFileExtensions.indexOf(ext);
    if (offset > 0) return "MOVIE";
    offset = dicomFileExtensions.indexOf(ext);
    if (offset > 0) return "dicom";
    return "OTHERS";
  }
}
