// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library odw.toolkit.dictionary.dart.aspera_requests;

///

/// ASPERA Requests
class aspera_requests {

  //TODO: what is format of selection files - why isn't it a list?
  GenerateSelectionNameForAsperaUploadTable(selectionFiles) {
    var fileNames = '';
    for (int j = 0; j < selectionFiles.length; j++)
      if (selectionFiles[j] != null && selectionFiles[j].name != null) {
        if (fileNames == '') {
          fileNames += selectionFiles[j].replace(/^.*[\\\/]/, '');
        } else {
          fileNames += ", " + selectionFiles[j].replace(/^.*[\\\/]/, '');
        }
      }

    if (fileNames.length > numberOfSymbolsToShowForLongFileNames)
      fileNames = fileNames.substring(0, numberOfSymbolsToShowForLongFileNames) + '..........';

    return fileNames;
  }

  IsAsperaInstalled() {
    //TODO: where defined?
    setupConnectApplication();
    //    setup();
    var connectApp = connectApplication.version().connect;
    var connectPlugin = connectApplication.version().plugin;
    return (connectApp.installed && connectPlugin.installed) ? true : false;
  }

  IsAsperaEnabled() => IsAsperaInstalled();

  ShowAsperaStatus(status, percentage, filename) {
    var activeUploaderDiv = GetActiveUploaderContainer();

    bool isUploadedStarted = false;
    isUploadedStarted = IsAnyUploadInProgress();

    bool anyChange = false;
    for (int k = 0; k < fileSelectionStatusesInCurrentExam.length; k++)
      if ((fileSelectionsInCurrentExam[k] != null) &&
          (fileSelectionStatusesInCurrentExam[k].Status == adding_to_queue_status ||
              fileSelectionStatusesInCurrentExam[k].Status == re_upload_status)) {
        fileSelectionStatusesInCurrentExam[k].Status = in_queue_status;
        fileSelectionStatusesInCurrentExam[k].DisplayedText = in_queue_status;
        anyChange = true;
      }

    var examid = activeUploaderDiv.attr("examid");
    if (anyChange)
      GenerateUploadUIForFilesSelections(examid);

    for (int i = 0; i < fileSelectionStatusesInCurrentExam.length; i++)
      if (fileSelectionsInCurrentExam[i] != null && fileSelectionStatusesInCurrentExam[i].Status == in_queue_status)
        break;

    if (i < fileSelectionStatusesInCurrentExam.length) {
      var activeUploaderDiv = GetActiveUploaderContainer();
      var examId = activeUploaderDiv.attr("examid");

      jquery211('#divReadyForSubmission' + examId).css('display', 'none');

      var uploaderDivId = "uploaderDiv" + examId;
      var examUploader = jquery211('#' + uploaderDivId);
      var examName = examUploader.attr("examname");
      var examType = examUploader.attr("examtype");
      var modality = examUploader.attr("modality");

      var tableRow = jquery211("tr", jquery211('#tblUploadFiles' + examId))[i + 1];
      var progressBar = jquery211("progress", jquery211('td:nth-child(3)', tableRow));
      progressBar.remove();

      jquery211('td:nth-child(3)', tableRow).empty();
      jquery211('td:nth-child(3)', tableRow).append(
          '<div id="progress"><span id="percent">' + parseInt(percentage * 100) + '%</span> <div id="bar" style="width:' +
              parseInt(percentage * 100) + '%"></div></div> ');
      fileSelectionStatusesInCurrentExam[i].Status = status;
      if (status == completed_status) {
        //  DisplayLogInExam(examId, displayedName + ' is uploaded successfully');
      } else if (status == failed_to_upload_status) {
        //   DisplayLogInExam(examId, ' Some files failed to upload.');
        //   DisplayErrorInExam(examId, '<b>Failed to upload the following files. </b><br/>'+ filename);
        failedToUpload = true;
      }
      GenerateUploadUIForFilesSelections(examid);
    }
  }

  AsperaAddInputFilesToQueue(pathArray) {
    var isAnyUndefinedFound = false;
    var activeUploaderDiv = GetActiveUploaderContainer();
    var examid = activeUploaderDiv.attr("examid");
    for (int j = 0; j < fileSelectionsInCurrentExam.length; j++)
      if (fileSelectionsInCurrentExam[j] == null) {
        fileSelectionsInCurrentExam[j] = pathArray;
        fileSelectionStatusesInCurrentExam[j] = adding_to_queue_status;
        isAnyUndefinedFound = true;
        break;
      }
    List tempFilesArray = [];
    //tempFilesArray.length = 0;

    for (int i = 0; i < pathArray.length; i++) {
      tempFilesArray[tempFilesArray.length] = pathArray[i].name;
    }
    if (!isAnyUndefinedFound) {
      int len = fileSelectionsInCurrentExam.length;
      fileSelectionsInCurrentExam[len] = tempFilesArray;
      fileSelectionStatusesInCurrentExam[len] =
      //TODO fix
      { "Status": adding_to_queue_status,
        "DisplayedText": adding_to_queue_status
      };
    }
    GenerateUploadUIForFilesSelections(examid);

    HideExamMessage(examid);
    lastUploadsCommandGuids = [];
    //lastUploadsCommandGuids.length = 0;
    singleCanceledFileNames = [];
    //singleCanceledFileNames.length = 0;
  }

  IsAnyUploadInProgress() {
    var isUploadOver = true;
    for (int i = 0; i < fileSelectionStatusesInCurrentExam.length; i++) {
      if ((fileSelectionsInCurrentExam[i] != null) &&
          (fileSelectionStatusesInCurrentExam[i].Status == in_queue_status)) {
        isUploadOver = false;
        break;
      }
    }
    return !isUploadOver;
  }

  GetAsperaSettings() {
    //TODO: HTTPRequest
    /*
  jquery211.ajax({
                   "url": wcfTriadApplicationServiceUrl + '/GetAsperaSettings',
                   "type": 'GET',
                   "dataType": 'json',
                   "contentType": "application/json; charset=utf-8",
                   "cache": false,
                   "async": false,
                   "success": (result) {
                     atiAsperaHost = result.Host;
                     atiAsperaUsername = result.UserName;
                     atiAsperaPassword = result.Password;
                     atiAsperaSSHPort = result.SshPort;
                   },
                   "beforeSend": (jqXHR, settings) {
                     jqXHR.url = settings.url;
                   },
                   "error": (jqXHR, exception) {
                     if (jqXHR.status == 0) {
                       showNotification('Connection Error', 'Please verify your network connection and reload the page.');
                     } else {
                       showNotification('Error', 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
                     }
                   }
                 });
  */
    var url = wcfTriadApplicationServiceUrl + '/GetAsperaSettings';
    HttpRequest
  }
}