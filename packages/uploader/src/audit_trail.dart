
library audit_trail;

import "dart:io";
import "package:uploader/src/types/modality.dart";
import "submission.dart";
import "package:uploader/src/types/user.dart";

class AuditTrail {

    static const String testUrl = "http://localhost/TriadAuditService.svc/LogWebUserAction";
    String serviceUrl;

    AuditTrail(this.serviceUrl, this.userName) {
        serviceUrl = serviceUrl + "/LogWebUserAction";  // make constant
    }

    //Log submit files event
    LogTransferFiles(examName, unitNumber, modality, modalityNumber, fileName) {
      if (FileIsDicom(fileName)) {
        BeginTransferringDICOMInstance(examName, unitNumber, modality, modalityNumber);
      } else {
        SubmitNonDicon(examName, unitNumber, modality, modalityNumber, fileName);
      }
    }

    //Begin Transferring DICOM Instance
    BeginTransferringDICOMInstance(examName, unitNumber, modality, modalityNumber) {

        var data = {};
        data.EventName = "DICOM Study Submission";
        data.DICOMEventName = "Begin Transferring DICOM Instances";        
        data.ExamName = examName;
        data.UnitNo = unitNumber;
        data.ApplicationNo = CreateFullModality(modality, modalityNumber);

        LogMessage(serviceUrl, data, "BeginTransferringDICOMInstances");
    }

    //Non-DICOM file Submission
    SubmitNonDicon(examName, unitNumber, modalityName, modalityNumber, fileName) {

        var data = {};
        data.EventName = "Non-DICOM file Submission";
        data.DICOMEventName = "General";
        
        data.ExamName = examName;
        data.UnitNo = unitNumber;
        data.FileName = fileName;
        data.FileTypeExtension = GetExtension(fileName);
        data.ApplicationNo = CreateFullModality(modalityName, modalityNumber);

        LogMessage(serviceUrl, data, "NonDICOMFileSubmission");
    }

    //View DICOM Images
    ViewDicom(examName, modality, modalityNumber, unitNumber) {

        var data = {};

        data.EventName = "View DICOM Images";
        data.DICOMEventName = "DICOM Instances Accessed";
        data.ExamName = examName;
        data.ModalityNo = modalityNumber;
        data.UnitNo = unitNumber;

        LogMessage(serviceUrl, data, "ViewDICOMData");
    }

    //View or Download non-DICOM files
    ViewNonDicom(examName, modality, modalityNumber, unitNumber, fileName) {

        var e = new Event(
            name: "View or Download non-DICOM files",
            dicomEventName: "General",
            examName: examName,
            fileName: fileName,
            fileTypeExtension: GetExtension(fileName), //TODO fix
            unitNo: unitNumber,
            applicationNo: CreateFullModality(modality, modalityNumber),
            modalityAndUnitNo: CreateFullModality(modality, modalityNumber, unitNumber
            );

        data.EventName =
        data.DICOMEventName = "General";
        data.ExamName = examName;
        data.FileName = fileName;
        data.FileTypeExtension = GetExtension(fileName);
        data.UnitNo = unitNumber;
        data.ApplicationNo = CreateFullModality(modality, modalityNumber);
        data.ModalityAndUnitNo = CreateFullModality(modality, modalityNumber, unitNumber);

        LogMessage(serviceUrl, data, "ViewNonDICOMFiles");
    }

    //User succesfully logged in
    Login() {
        var data = {};
        data.EventName = "Login or Logout";
        data.DICOMEventName = "User Authentication";

        LogMessage(serviceUrl, data, LogIn);
    }
}




//process log message before sending
//TODO what is type
LogMessage(String url, data, type, errorMessage) {
     //prevent execute the send log operation.
     //Your time has not come yet!
  LogEntry entry = new LogEntry()




     if (errorMessage == "undefined") {
         data.Status = "Success";
     } else {
         data.Status = "Failure";
         data.FailureMessage = errorMessage;
     }

     SendLogMessage(url, data, type);
 }

//TODO
//send log message to the audit trail server
SendLogMessage(String url, jsonData, type) {
    
    var eventData = JSON.stringify(jsonData);
    var message = { Type: type, Message: eventData.split('"').join("'") };
    var serializedMessage = JSON.stringify(message);
/* TODO
    $.ajax({url: url,
            type: 'POST',
            dataType: 'json',
            //contentType: "application/json",
            data: serializedMessage
    });
  */
}

//determine file type by extension
//TODO document criteria
 FileIsDicom(String fileName) {
  //TODO fix
    var extension = GetExtension(fileName);
    return extension == 'dcm' || extension == '' || extension == null;
}

//get extension from file name
/* TODO use Dart Path
GetExtension(String fileName) {
    Path path =
    var splitResult = fileName.split('.');
    if (splitResult.length > 1)
        return splitResult.pop();
    else
        return null;
}
*/

//create full-name modality for Application number and ModalityAndUnitNo fields
//example: MRAP#50123-01
CreateFullModality(String modalityName, int modalityNumber, int unitNumber) {
    var modality = '$modalityName#$modalityNumber';
        var unit = (unitNumber == null || unitNumber == '') ? '' : '-$unitNumber';
    return modality + unit;
}

//moment.js format: YYYY-MM-DD HH:mm:ss
/* TODO flush
FormatDate(date) {
    
    var fullDate = [FomatPartOfDate(date.getMonth()), FomatPartOfDate(date.getDay()), date.getFullYear()].join('-');
    var fullTime = [FomatPartOfDate(date.getHours()), FomatPartOfDate(date.getMinutes()), FomatPartOfDate(date.getSeconds())].join(':');

    return fullDate + ' ' + fullTime;
}

FomatPartOfDate(data) {
    if (data < 10)
        data = '0' + data;

    return data;
}
*/

// Change to JSON
//Note: used to be AuditTrailHelper() {
createAuditTrailUrlParameters(auditTrailIsOn) {
  addQueryParam(paramName, value) => (value == null) ? '' : '&' + paramName + '=' + value;

  getSpanValue(id) {
    var selector = querySelectorAll('span[id\$="' + id + '"]');
    return (selector.length == 0) ? null : querySelector(selector[0]).text;
  }

  var examName = getSpanValue('lblTitle');
  var modality = getSpanValue('lblModalityName');
  var modalityNumber = getSpanValue('lblFacilityNumber');

  var result = addQueryParam('examName', examName) + addQueryParam('modality', modality) +
      addQueryParam('modalityNumber', modalityNumber) +
      addQueryParam('auditTrailIsOn', auditTrailIsOn);
  return result;
}
class AuditEntry {
  String lblTitle;
  String lblModalityName;
  String lblFacilityNumber;
  String examName;
  Modality modality;
}
