//TODO: copyright

import 'package:uploader/src/types/modality.dart';

//TODO: what should be included in an Audit Log Event
class Event {
  String name;
  String dicomName; //TODO: needed? = "General";
  Event examName;
  String fileName;
  Modality modality;
  //int unitNo;
  //int applicationNo = CreateFullModality(modality, modalityNumber);
  //String modalityAndUnitNo = CreateFullModality(modality, modalityNumber, unitNumber);

  Event(this.name, this.dicomName, this.examName) {

  }
}
