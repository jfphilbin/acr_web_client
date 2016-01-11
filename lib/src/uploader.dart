// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library uploader;

import 'dart:html';

import 'app_state.dart';
import 'package:uploader/src/types/exam.dart';
import 'selection_file.dart';
import 'package:uploader/src/types/modality.dart';
import 'submission.dart';
import 'package:uploader/src/types/user.dart';

/// 
class Uploader {
  var fileReader;
  String savedFilename;
  int sliceNumber = 0;
  int totalChunks;
  String fileToUpload;
  //String divLogsTab;
  int totalChunksInSelection;
  int numberOfFileToUpload;
  List<String> allFiles;
  int currentFileIndex;
  String commandGuid;
  List<String> uploadFailedFiles;
  //TODO: more uploader stuff group in module
  int currentSliceNumber;
  int currentFileTotalChunks;
  int currentTotalChunksInSelection;
  String currentCommandGuid; //GUID, UUID could be binary

  Uploader()
  start() {
    var activeUploaderDiv = GetActiveUploaderContainer();
    var examId = activeUploaderDiv.attr("examid");

    //var divLogsTab = jquery211("div[id^='divLogsTab']", jquery211(activeUploaderDiv));
    divLogsTab.text('');

    jquery211('a[id^="mainLink"]').each(
        (index) {
      if (jquery211(this).attr("onclick") != null && jquery211(this).attr("onclick").indexOf(returnFalse) == -1)
        jquery211(this).attr("onclick", returnFalse + jquery211(this).attr("onclick"));
    });

    var selectedFiles = [];
    selectedFiles.length = 0;
    var commandGuid = guid();

    var isUploadedStarted = false;
    isUploadedStarted = IsAnyUploadInProgress();
    var anyChange = false;
    for (int k = 0; k < fileSelectionStatusesInCurrentExam.length; k++)
      if (fileSelectionsInCurrentExam[k] != null &&
          (fileSelectionStatusesInCurrentExam[k].Status == adding_to_queue_status ||
              fileSelectionStatusesInCurrentExam[k].Status == re_upload_status)) {
        fileSelectionStatusesInCurrentExam[k].Status = in_queue_status;
        fileSelectionStatusesInCurrentExam[k].DisplayedText = in_queue_status;
        anyChange = true;
      }

    if (anyChange)
      GenerateUploadUIForFilesSelections(examId);

    if (!isUploadedStarted) {
      for (i = 0; i < fileSelectionStatusesInCurrentExam.length; i++)
        if (fileSelectionsInCurrentExam[i] != null && fileSelectionStatusesInCurrentExam[i].Status == in_queue_status){
          fileSelectionStatusesInCurrentExam[i].WithRetry = false;
          break;
        }

      if (i < fileSelectionStatusesInCurrentExam.length) {
        selectedFiles = fileSelectionsInCurrentExam[i];
        numberOfChunksUploaded[i] = 0;
        numberOfChunksUploaded.length = fileSelectionsInCurrentExam.length;
        var totalNumberOfChunksInSelection = GetTotalNumberOfChunksForUpload(selectedFiles);
        var sliceNumber = 0;
        var startFromFile = 0
        var numberOfChunks = Math.ceil(selectedFiles[startFromFile].size / TriadUploadChunckSize);
        var fileReader = new FileReader();
        var uploadFailedFiles = [];
        DisableUploadForExams(examId);
        loadSliceToServer(fileReader, selectedFiles[startFromFile].name, sliceNumber, numberOfChunks, selectedFiles[startFromFile], divLogsTab, totalNumberOfChunksInSelection, i, selectedFiles, startFromFile, commandGuid, uploadFailedFiles );
      }
    }
  }

  retry(rowNumber, button) {
    button.css['display'] = 'none';
    lastUploadsCommandGuids = [];
    //lastUploadsCommandGuids.length = 0;
    singleCanceledFileNames = [];
    //singleCanceledFileNames.length = 0;
    if (isAsperaOn) {
      RetryAsperaUploadToServer(rowNumber);
    } else {
      RetryUploadToServer(rowNumber);
    }
  }

// TODO: move to upload.dart
  RetryUploadToServer(rowIndex) {
    jquery211('.tblLogStatus').css('display', 'none');
    fileSelectionStatusesInCurrentExam[rowIndex - 1].Status = adding_to_queue_status;
    fileSelectionStatusesInCurrentExam[rowIndex - 1].WithRetry = true;
    start();
  }

  RetryAsperaUploadToServer(rowIndex) {
    jquery211('.tblLogStatus').css('display', 'none');
    fileSelectionsInCurrentExam.splice(rowIndex - 1, 1)
    fileSelectionStatusesInCurrentExam.splice(rowIndex - 1, 1);
    setPrimarySecondaryIds(primaryparentID, secondaryparentID, paramExamID);
    fileControls.uploadFiles();
  }

  NcancelOrRemoveUpload(String fileNames, String rowNumber, String examId) {
    var context = querySelector('#cancelOrRemoveButton' + rowNumber).closest('tr').find('td:nth-child(3)');
    var isCancelled = context
        .querySelector('[id^=btnUploadFiles]')
        .length == 0;
    if (isCancelled) CancelOneFileUpload(fileNames.toString(), rowNumber);
    else DeleteSelectionOfFilesForUploadByIndex(rowNumber);
    querySelector("#divReadyForSubmission" + examId).css('display', '');
    GenerateUploadUIForFilesSelections(examId);
    EnableUploadForExams();
  }

  EnableAllUploadButtons(String examId) {
    var isReadyForSubmission = querySelector("#cbxReadyForSubmission" + examId).checked;
    if (!isReadyForSubmission) {
      Element e = querySelector("#btnUploader" + examId);
      e.attributes.remove("disabled");
      e.attributes.removeClass("btn-disabled");
    }
    var btnSelectFiles = jquery211("#btnSelectFiles" + examId);
    btnSelectFiles.attribures.remove("disabled");
    btnSelectFiles.parent().removeClass("btn-disabled");

    var btnSelectFolder = jquery211("#btnSelectFiles" + examId + "Folders");
    btnSelectFolder.removeAttr("disabled");
    btnSelectFolder.parent().removeClass("btn-disabled");
  }

  DisableAllUploadButtons(examId) {
    jquery211("#btnUploader" + examId).prop("disabled", "true").addClass("btn-disabled");

    var btnSelectFiles = jquery211("#btnSelectFiles" + examId);
    btnSelectFiles.prop("disabled", "true");
    btnSelectFiles.parent().addClass("btn-disabled");

    var btnSelectFolder = jquery211("#btnSelectFiles" + examId + "Folders");
    btnSelectFolder.prop("disabled", "true");
    btnSelectFolder.parent().addClass("btn-disabled");
  }

//TODO: finish
  DisableUploadForExams(String currentExamId) {
    querySelectorAll('input[id^="btnUploader"]').not("#btnUploader" + currentExamId).forEach((item) {
      item.prop('disabled', 'true');
      item.css('background-color', 'lightgrey');
      item.css('border-color', 'lightgrey');
      item.css('cursor', 'default');
    });
    var currentBtnUploader = querySelector("#btnUploader" + currentExamId);
    currentBtnUploader.prop('disabled', 'true');
    currentBtnUploader.css('background-color', activeUploadButtonColor);
    currentBtnUploader.css('border-color', '');
    currentBtnUploader.css('cursor', 'default');
  }

  EnableUploadForExams() {
    if (!IsAnyUploadInProgress())
      querySelectorAll('div[id^="uploaderDiv"]').forEach((element) {
        var examId = element["examid"];
        var btnUploader = element['#btnUploader' + examId];
        btnUploader.css['background-color'] = '';
        btnUploader.css['border-color'] = '';
        btnUploader.css['cursor'] = 'pointer';
        if (!element["#cbxReadyForSubmission" + examId].checked) btnUploader.removeAttr('disabled');
      });
  }

  GetTotalNumberOfChunksForUpload(selectedFiles) {
    var totalNumberOfChunksInSelection = 0;
    for (k = 0; k < selectedFiles.length; k++) {
      if (typeof selectedFiles[k] != "undefined") {
        totalNumberOfChunksInSelection += Math.ceil(selectedFiles[k].size / TriadUploadChunckSize);
      }
    }
    return totalNumberOfChunksInSelection;
  }

// Load one Chunck at a time
// TODO change name to uploadChunk
  loadSliceToServer(fileReader, savedFileNameForServer, sliceNumber, numberOfChunks, fileToUpload,
      divLogsTab, totalNumberOfChunksInSelection, numberOfFileSelectionInUpload, allFiles,
      currentFileIndex, commandGuid, uploadFailedFiles) {
    currentSliceNumber = sliceNumber;
    currentFileTotalChunks = numberOfChunks;
    currentTotalChunksInSelection = totalNumberOfChunksInSelection;
    currentCommandGuid = commandGuid;

    var sizeinbytes = fileToUpload.size;
    var filename = fileToUpload.name;

    if (sliceNumber == 0) {
      lastUploadsCommandGuids[lastUploadsCommandGuids.length] = commandGuid + "|" + filename;
      lastUploadsCommandGuids.length++;
    }

    if (jquery211.inArray(filename, singleCanceledFileNames) != -1) {
      singleCanceledFileNames.splice(0, singleCanceledFileNames.length);
      for (k = 0; k < fileSelectionStatusesInCurrentExam.length; k++)
        if (typeof fileSelectionsInCurrentExam[k] != "undefined" && fileSelectionStatusesInCurrentExam[k].Status == in_queue_status) {
          fileSelectionStatusesInCurrentExam[k].Status = re_upload_status;
          anyChange = true;
        }

      start();
      return;
    }

    fileReader.onerror = (event) {
      console.error("File could not be read! Code " + event.target.error.code);
    };

    var endOfPeace = fileToUpload.size;
    if (endOfPeace > TriadUploadChunckSize * (sliceNumber + 1))
      endOfPeace = TriadUploadChunckSize * (sliceNumber + 1);
    var fileContent = fileToUpload.slice(TriadUploadChunckSize * sliceNumber, endOfPeace);
    fileReader.readAsArrayBuffer(fileContent);

    fileReader.onloadend = (e) {
      if (jquery211.inArray(filename, singleCanceledFileNames) != -1) {
        singleCanceledFileNames.splice(0, singleCanceledFileNames.length);
        for (k = 0; k < fileSelectionStatusesInCurrentExam.length; k++)
          if (typeof fileSelectionsInCurrentExam[k] != "undefined" && fileSelectionStatusesInCurrentExam[k].Status == in_queue_status) {
            fileSelectionStatusesInCurrentExam[k].Status = re_upload_status;
            anyChange = true;
          }

        start();
        return;
      }

      if (e.target.readyState == FileReader.DONE) {
        var activeUploaderDiv = GetActiveUploaderContainer();
        if (activeUploaderDiv == null) return;
        var examId = activeUploaderDiv.attribute["examid"];

        var divReady = '#divReadyForSubmission' + examId + ' input[type="checkbox"]';
        querySelector(divReady).prop('disabled', 'true');

        var base64String = _arrayBufferToBase64(new Uint8Array(e.target.result));

        var uploaderDivId = "uploaderDiv" + examId;
        var examUploader = querySelector('#' + uploaderDivId);
        var examName = examUploader.attributes["examname"];
        var examType = examUploader.attributes["examtype"];
        var modality = examUploader.attr("modality");
        var modalityNumber = examUploader.attr("modalityAccreditationNumber");

        var numberOfFilesInCurrentUploadSelection = allFiles.length;
        var totalBytesInSelection = 0;
        for (int k = 0; k < allFiles.length; k++) {
          if (allFiles[k] != null) {
            totalBytesInSelection += allFiles[k].size;
          }
        }



        if (auditTrailIsOn) {
          var auditTrailLogger = new AuditTrail(wcfAuditTrailUrl, userName);
          auditTrailLogger.LogTransferFiles(examName, secondaryparentID, modality, modalityNumber, fileToUpload.name);
        }
//TODO factor out UI
        jquery211.ajax({

                       url: wcfAtiServiceUrl + '/HttpChunkingUpload',
                       type: 'POST',
                       chunkNumber: sliceNumber,
                       dataType: '',
                       contentType: "application/json",
                       data: JSON.encode(uploadInput),
                       //      async: false,
                       success (data) {
                       sliceNumber = currentSliceNumber;
                       numberOfChunks = currentFileTotalChunks;
                       totalNumberOfChunksInSelection = currentTotalChunksInSelection;
                       commandGuid = currentCommandGuid;

                       if (isdebugmode == '1')
                       alert(JSON.encode(data));

                       if (jquery211.inArray(filename, singleCanceledFileNames) != -1) {
                       singleCanceledFileNames.splice(0, singleCanceledFileNames.length);
                       for (k = 0; k < fileSelectionStatusesInCurrentExam.length; k++)
                       if (typeof fileSelectionsInCurrentExam[k] != "undefined" && fileSelectionStatusesInCurrentExam[k].Status == in_queue_status) {
                       fileSelectionStatusesInCurrentExam[k].Status = re_upload_status;
                       anyChange = true;
                       }

                       start();
                       return;
                       }
                       var displayedName = GenerateSelectionNameForUploadTable(allFiles);
                       var tableRows = jquery211("tr", jquery211('#tblUploadFiles' + examId));
                       var tableRow;
                       if (tableRows.length == 0){
                       return;
                       }
                       else{
                       tableRow = tableRows[numberOfFileSelectionInUpload - deletedSelectionsCount + 1];
                       if (typeof tableRow == 'undefined') {
                       return;
                       }
                       };

                       var progressBar = jquery211("progress", jquery211('td:nth-child(3)', tableRow));
                       progressBar.remove();

                       numberOfChunksUploaded[numberOfFileSelectionInUpload]++;

                       jquery211('td:nth-child(2)', tableRow).text(allFiles.length);
                       jquery211('td:nth-child(3)', tableRow).empty();
                       jquery211('td:nth-child(3)', tableRow).append('<div id="progress"><span id="percent">'+ (currentFileIndex + 1) +'/' + allFiles.length + '</span> <div id="bar" style="width:' + parseInt((numberOfChunksUploaded[numberOfFileSelectionInUpload]) * 100 / totalNumberOfChunksInSelection) + '%"></div></div> ');

                       var removeCancelButton = jquery211('img.deleteFileUploadSelection', tableRow).parent().parent();
                       if (typeof removeCancelButton.attr('title') !== typeof undefined && removeCancelButton.attr('title') !== "")
                       {
                       removeCancelButton.attr('title', 'Cancel Upload');
                       }

                       sliceNumber++;

                       var failedToUpload = false;
                       if (sliceNumber < numberOfChunks) {

                       if (data.ChunkingUploadResult.ErrorReason != null && data.ChunkingUploadResult.ErrorReason != '') {
                       //DisplayErrorInExam(examId, '<b>Some files failed to upload. </b><br/><b>Server error details:</b> <br/>' + data.ChunkingUploadResult.ErrorReason);
                       numberOfChunksUploaded[numberOfFileSelectionInUpload] += numberOfChunks - sliceNumber;
                       sliceNumber = numberOfChunks;

                       failedToUpload = true;
                       }
                       else {
                       loadSliceToServer(fileReader, data.ChunkingUploadResult.SavedFilename, sliceNumber, numberOfChunks, fileToUpload, divLogsTab, totalNumberOfChunksInSelection, numberOfFileSelectionInUpload, allFiles, currentFileIndex, commandGuid, uploadFailedFiles);
                       return;
                       }
                       }
                       else {
                       if (data.ChunkingUploadResult.ErrorReason != null && data.ChunkingUploadResult.ErrorReason != '') {
                       //DisplayErrorInExam(examId, '<b>Some files failed to upload. </b><br/><b>Server error details:</b> <br/>' + data.ChunkingUploadResult.ErrorReason);
                       failedToUpload = true;
                       }
                       }

                       //one file upload completed
                       if (failedToUpload){
                       uploadFailedFiles.push({
                       name: fileToUpload.name, sizeinbites: fileToUpload.size, errorReason: data.ChunkingUploadResult.ErrorReason
                       });
                       }

                       var totalNumberOfChunksUploaded = numberOfChunksUploaded[numberOfFileSelectionInUpload];

                       if (currentFileIndex < allFiles.length - 1 /*&& !failedToUpload*/) {

                       currentFileIndex++;
                       var numberOfChunks = Math.ceil(allFiles[currentFileIndex].size / TriadUploadChunckSize);
                       var sliceNumber = 0;

                       loadSliceToServer(fileReader, allFiles[currentFileIndex].name, sliceNumber, numberOfChunks, allFiles[currentFileIndex], divLogsTab, totalNumberOfChunksInSelection, numberOfFileSelectionInUpload, allFiles, currentFileIndex, commandGuid, uploadFailedFiles);
                       return;
                       }
                       else {
                       var isUploadCompleted = false;
                       //if (!failedToUpload && totalNumberOfChunksUploaded > 0)

                       numberOfFileSelectionInUpload = getNumberOfFileSelectionInUpload();
                       // fileSelectionStatusesInCurrentExam.indexOf(in_queue_status);

                       if (uploadFailedFiles.length < allFiles.length)
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status = completed_status;
                       else
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status = failed_to_upload_status;

                       if (uploadFailedFiles.length <= 0){
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].DisplayedText = allFiles.length +' file(s) are uploaded successfully';
                       }
                       else {
                       var temp = allFiles.length - uploadFailedFiles.length;
                       if (temp != 0) {
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].DisplayedText = uploadFailedFiles.length + ' invalid file(s). ' + temp + ' file(s) uploaded successfully.';
                       }
                       else {
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].DisplayedText = uploadFailedFiles.length + ' file(s) failed to upload';
                       }
                       }

                       ReloadExam(examId);

                       deletedSelectionsCount = 0;

                       GenerateUploadUIForFilesSelections(examId);

                       //One file selection completed
                       //Show the failed files list
                       if (uploadFailedFiles.length > 0)
                       {
                       //var unfoundFilesMessage = '<label id = "unfound-files-message">Some files are not found from the selected folder path:</label>';
                       var unfoundFilesMessage = "<table id='unfound-files-table'><tr><th>File Name</th><th>Extension</th><th>Size</th></tr>";
                       var unfoundFilesCount = 0;

                       //var failedFilesMessage = '<label id = "invalid-files-message">The file selection contains ' + uploadFailedFiles.length + " file(s) with file types that are not supported for this modality/exam type. Please refer to the list of supported file types.</label>";
                       var failedFilesMessage = "<table id='invalid-files-table'><tr><th>File Name</th><th>Extension</th><th>Size</th></tr>";
                       var failedFilesCount = 0;

                       for (var ffIndex = 0; ffIndex < uploadFailedFiles.length; ffIndex++) {
                       if (uploadFailedFiles[ffIndex].errorReason != null && uploadFailedFiles[ffIndex].errorReason.indexOf("The input parameter is null or empty for the upload operation") >= 0)
                       {
                       //DisplayErrorInExam(examId, '<b>Some files failed to upload. </b><br/><b>Server error details:</b> <br/>' + data.ChunkingUploadResult.ErrorReason);
                       unfoundFilesMessage += "<tr><td>";
                       unfoundFilesMessage += uploadFailedFiles[ffIndex].name;
                       unfoundFilesMessage += "</td><td>";
                       unfoundFilesMessage += getExtension(uploadFailedFiles[ffIndex].name, true);
                       unfoundFilesMessage += "</td><td>";
                       unfoundFilesMessage += formatBytes(uploadFailedFiles[ffIndex].sizeinbites, 4);
                       unfoundFilesMessage += "</td>";
                       unfoundFilesMessage += "</tr>";
                       unfoundFilesCount++;
                       }
                       else
                       {
                       failedFilesMessage += "<tr><td>";
                       failedFilesMessage += uploadFailedFiles[ffIndex].name;
                       failedFilesMessage += "</td><td>";
                       failedFilesMessage += getExtension(uploadFailedFiles[ffIndex].name, true);
                       failedFilesMessage += "</td><td>";
                       failedFilesMessage += formatBytes(uploadFailedFiles[ffIndex].sizeinbites, 4);
                       failedFilesMessage += "</td>";
                       failedFilesMessage += "</tr>";
                       failedFilesCount++;
                       }

                       };
                       failedFilesMessage += "</table>";
                       unfoundFilesMessage += "</table>";

                       if (unfoundFilesCount == 0) unfoundFilesMessage = "";
                       else unfoundFilesMessage = '<label id = "unfound-files-message">'+unfoundFilesCount+' file(-s) is(are) not found from the selected folder path:</label>' + unfoundFilesMessage;

                       if (failedFilesCount == 0) failedFilesMessage = "";
                       else failedFilesMessage = '<label id = "invalid-files-message">The file selection contains ' + failedFilesCount + ' file(s) with file types that are not supported for this modality/exam type. Please refer to the list of supported file types.</label>' + failedFilesMessage;

                       DisplayErrorInExam(examId, failedFilesMessage + unfoundFilesMessage + "<div id='closePopUpBtn'>Close</div>");
                       }

                       for (numberOfFileSelectionInUpload = 0; numberOfFileSelectionInUpload < fileSelectionStatusesInCurrentExam.length; numberOfFileSelectionInUpload++)
                       if (typeof fileSelectionsInCurrentExam[numberOfFileSelectionInUpload] != "undefined" && fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status == in_queue_status){
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].WithRetry = false;
                       break;
                       }

                       if (numberOfFileSelectionInUpload < fileSelectionStatusesInCurrentExam.length) {
                       var selectedFiles = fileSelectionsInCurrentExam[numberOfFileSelectionInUpload];
                       numberOfChunksUploaded[numberOfFileSelectionInUpload] = 0;
                       numberOfChunksUploaded.length = fileSelectionsInCurrentExam.length;
                       var totalNumberOfChunksInSelection = GetTotalNumberOfChunksForUpload(selectedFiles);
                       var k = 0;

                       var numberOfChunks = Math.ceil(selectedFiles[k].size / TriadUploadChunckSize);
                       var sliceNumber = 0;

                       var commandGuid = guid();
                       lastUploadsCommandGuids[lastUploadsCommandGuids.length] = commandGuid + "|" + filename;
                       lastUploadsCommandGuids.length++;
                       uploadFailedFiles = [];
                       loadSliceToServer(fileReader, selectedFiles[k].name, sliceNumber, numberOfChunks, selectedFiles[k], divLogsTab, totalNumberOfChunksInSelection, numberOfFileSelectionInUpload, selectedFiles, k, commandGuid, uploadFailedFiles);
                       return;

                       }

                       var isAllUploadSuccess = true;
                       for (numberOfFileSelectionInUpload = 0; numberOfFileSelectionInUpload < fileSelectionStatusesInCurrentExam.length; numberOfFileSelectionInUpload++)
                       if (typeof fileSelectionsInCurrentExam[numberOfFileSelectionInUpload] != "undefined" && fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status == failed_to_upload_status) {
                       isAllUploadSuccess = false;
                       break;
                       }

                       var isUploadOver = true;
                       for (numberOfFileSelectionInUpload = 0; numberOfFileSelectionInUpload < fileSelectionStatusesInCurrentExam.length; numberOfFileSelectionInUpload++)
                       if (typeof fileSelectionsInCurrentExam[numberOfFileSelectionInUpload] != "undefined" && fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status == in_queue_status) {
                       isUploadOver = false;
                       break;
                       }

                       //all file selection upload completed
                       if (isUploadOver) {

                       //Modified on 6-11-2015 to fix
                       if (uploadFailedFiles.length == 0) EnableReadyForSubmissionCheckBox(examId);

                       jquery211('a[id^="mainLink"]').each(
                       (index) {
                       if (jquery211(this).attr("onclick") != null && jquery211(this).attr("onclick").indexOf(returnFalse) == 0)
                       jquery211(this).attr("onclick", jquery211(this).attr("onclick").substring(returnFalse.length));
                       });

                       EnableUploadForExams();
                       }

                       GenerateUploadUIForFilesSelections(examId);

                       jquery211('#divReadyForSubmission' + examId).css('display', '');
                       var aPackage = jquery211('#mainLink' + examId);
                       if (aPackage.attr("loaded") == 1) {
                       aPackage.attr("loaded", "");
                       }
                       var slidingDivId = "slidingDiv" + examId;
                       var slidingDiv = jquery211('#' + slidingDivId);
                       var aPackage = jquery211('#mainLink' + examId);
                       aPackage.show ();
                       }
                       },
                       beforeSend (jqXHR, settings) {
                       jqXHR.url = settings.url;
                       },
                       error(jqXHR, exception){

                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].DisplayedText = allFiles.length + ' file(s) failed to upload';
                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status = failed_to_upload_status;

                       if (jqXHR.status == 0) {
                       DisplayErrorLogInExam(examId, 'Connection Error. Please verify your network connection and reload the page.');
                       } else {
                       DisplayErrorLogInExam(examId, 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
                       }

                       fileSelectionStatusesInCurrentExam[numberOfFileSelectionInUpload].Status == failed_to_upload_status
                       GenerateUploadUIForFilesSelections(examId);
                       }
                       });
      }
    }
  }

//TODO: move to upload.dart
  PrepareForUpload(oldExamId, newExamId) {
    fileSelectionsInAllExams[oldExamId] = fileSelectionsInCurrentExam;
    fileSelectionsInCurrentExam = fileSelectionsInAllExams[newExamId];
    if (fileSelectionsInCurrentExam == null) {
      fileSelectionsInCurrentExam = [];
      fileSelectionsInCurrentExam.length = 0;
    }

    fileSelectionStatusesInAllExams[oldExamId] = fileSelectionStatusesInCurrentExam;
    fileSelectionStatusesInCurrentExam = fileSelectionStatusesInAllExams[newExamId];
    if (fileSelectionStatusesInCurrentExam == null) {
      fileSelectionStatusesInCurrentExam = [];
      fileSelectionStatusesInCurrentExam.length = 0;
    }

    GenerateUploadUIForFilesSelections(newExamId);

    var uploaderDivId = "uploaderDiv" + newExamId;
    var examUploader = jquery211('#' + uploaderDivId);
    var divLogsTab = jquery211("div[id^='divLogsTab']", jquery211(examUploader));
    var examName = examUploader.attr("examname");
    var examType = examUploader.attr("examtype");
    var modality = examUploader.attr("modality");

    if (viewType == ViewType.upload)
      GetUploadValidationMessage(newExamId, modality, examName, examType, divLogsTab);
  }

  AddInputFilesToQueue(event, examid) {
    var isAnyUndefinedFound = false;
    for (j = 0; j < fileSelectionsInCurrentExam.length; j++)
      if (fileSelectionsInCurrentExam[j] == null) {
        fileSelectionsInCurrentExam[j] = event.target.files;
        fileSelectionStatusesInCurrentExam[j] = adding_to_queue_status;
        isAnyUndefinedFound = true;
        break;
      }
    var tempFilesArray = [];
    tempFilesArray.length = 0;

    for (i = 0; i < event.target.files.length; i++) {
      tempFilesArray[tempFilesArray.length] = event.target.files[i];
    }
    if (!isAnyUndefinedFound) {
      var len = fileSelectionsInCurrentExam.length;
      fileSelectionsInCurrentExam[len] = tempFilesArray;
      fileSelectionStatusesInCurrentExam[len] = {Status: adding_to_queue_status, DisplayedText: adding_to_queue_status};
    }
    GenerateUploadUIForFilesSelections(examid);

    HideExamMessage(examid);
    lastUploadsCommandGuids = [];
    lastUploadsCommandGuids.length = 0;
    singleCanceledFileNames = [];
    singleCanceledFileNames.length = 0;
    StartUploadingFilesToServer();
  }

  IsAnyUploadInProgress() {
    var isUploadOver = true;
    for (i = 0; i < fileSelectionStatusesInCurrentExam.length; i++)
      if (typeof fileSelectionsInCurrentExam[i] != "undefined" && fileSelectionStatusesInCurrentExam[i].Status == in_queue_status) {
        isUploadOver = false;
        break;
      }

    return !isUploadOver;
  }

}
