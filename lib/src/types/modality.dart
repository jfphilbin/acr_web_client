// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library modality;

///

/// A specific modality, identifying one machine

class Modality {
  String name;
  int    number;
  String id;
  String unitId;
  String infoId;

  Modality(this.name, this.number, this.id, this.unitId, this.infoId);

  //TODO: what should the format be?
  toString()=> 'Modality: $name, $number';
}
