library appeal_letter_service;
//TODO: add copyright

import 'dart:convert';

import 'triad.dart';

//TODO merge with below
class AppealLetterSvc {

  //TODO what is localStorage
  var storage;  // = localStorage;
  //TODO doc
  //TODO trim should only be done on input
  getKey(modalityId, unitId, modalityInfoId) {
    var unitIdPart = (unitId != null) ? unitId.trim() : null;
    var modalityInfoIdPart = (modalityInfoId != null) ? modalityInfoId.trim() : null;
    return "AppealLetter: $modalityId/$unitIdPart/$modalityInfoIdPart";
  }

  //TODO doc
  getFilesEntries(String key) {
    var filesEntries = storage.getItem(key);
    if (filesEntries == null) return null;
    return JSON.decode(filesEntries);
  }

  //TODO doc, what is [key]? what is [value]?
  saveFilesEntries(String key, value) {
    storage.setItem(key, JSON.encode(value));
  }

  //TODO doc
  clearAppealLetterStorage() {
    Object.keys(storage).forEach((key) {
      //TODO fix
      //if (/^AppealLetter/.test (key))
      //AppealLetter.test(key) {
      //  storage.removeItem(key);
      }
    }
    }


  //TODO create an object for modality and use it
AppealLetterService(modalityId, unitId, modalityInfoId) {
  var key = getKey(modalityId, unitId, modalityInfoId);
  if (getFilesEntries(key) != null) return null;

  clearAppealLetterStorage();

  var appealLetterDeferred = $.Deferred();

  //TODO use Modality instead
  var input = {
    "ModalityId": modalityId,
    "UnitId": unitId,
    "ModalityInfoId": modalityInfoId
  };
  //TODO what is wcf?
  var wcfTriadAcreditServiceUrl = TriadUrl.get() + "TriadAcreditService.svc";

  //TODO make httpRequest
  HTTPRequest({
                "url": wcfTriadAcreditServiceUrl + '/HttpGetAppealLetter',
                "type": 'POST',
                "dataType": 'json',
                "contentType": "application/json; charset=utf-8",
                "data": JSON.encode(input),
                "async": true,
                "success": (result) {
                  saveFilesEntries(key, result.FileEntrys);
                  appealLetterDeferred.resolve();
                },
                "error": () {
                  appealLetterDeferred.resolve();
                }
              });
}

}



