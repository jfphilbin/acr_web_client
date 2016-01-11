
library review;

import "dart:convert";
import 'dart:html';

import 'triad.dart';

//SETTINGS BEGIN
//?var wcfAtiServiceUrl = opener.window.wcfAtiServiceUrl;
//?var wcfTriadAcreditServiceUrl = opener.window.wcfTriadAcreditServiceUrl;
//?var wcfAuditTrailUrl = opener.window.wcfAuditTrailUrl;

var TriadUploadChunckSize = 2097152; // 2MB
//SETTINGS END

//CONSTANTS BEGIN
//file selection statuses
String adding_to_queue_status = 'Adding To Queue';
String in_queue_status = 'In Queue';
String failed_to_upload_status = 'Failed To Upload';
String canceled_status = 'Canceled';
String re_upload_status = 'Re-upload';
String completed_status = 'Completed';

//view types
//TODO fix globally
enum ViewType {dicom, nonDicom, supportDoc}
String dicomViewType = 'dicom';
String nondicomViewType = 'nondicom';
String supportDocViewType = 'supportdoc';

//TODO: move to CSS
String activeUploadButtonColor = 'rgb(255, 165, 0)';
String  returnFalse = "return false;";
//CONSTANTS END

//APPLICATION VARIABLES BEGIN
var domain;
var primaryparentID;
var secondaryparentID;
var paramExamID;
var acredittestpackageID;
var modalityID;
var unitID;
var modalityInfoID;
var isdebugmode;
var userName;
var viewType;
//adittional log variables
var auditTrailIsOn;
var examName;
var modality;
var modalityNumber;
var auditTrailLogger;

List fileSelectionsInCurrentExam = [];
//fileSelectionsInCurrentExam.length = 0;
Map fileSelectionsInAllExams = {};

List fileSelectionStatusesInCurrentExam = [];
//fileSelectionStatusesInCurrentExam.length = 0;
Map fileSelectionStatusesInAllExams = {};

List numberOfChunksUploaded = [];
//numberOfChunksUploaded.length = 0;

List lastUploadsCommandGuids = [];
//lastUploadsCommandGuids.length = 0;

List singleCanceledFileNames = [];
//singleCanceledFileNames.length = 0;

int currentFileInUploadSliceNumber;
int currentFileInUploadTotalNumberOfChunks;
int currentTotalNumberOfChunksInSelection;
Uuid currentCommandGuid;

var currentRequestedContentToken;
var currentIframeId;
//APPLICATION VARIABLES END

//Page events begin
/* TODO fix
$(document).ready( () {

    viewType = getParameterByName('viewType');
    if (viewType == null || viewType == '')
        viewType = 'dicom';
		
    $('#divListOfExamsInTestingPackage').attr('style', 'display:');

    var $loading = $('#loadingDiv');
    $loading.show();

    domain = getParameterByName('domain');
    if (domain == null || domain == '')
        domain = 'ATI';
		
    primaryparentID = getParameterByName('primaryparentID');
    if (primaryparentID == null || primaryparentID == '')
        primaryparentID = 'AtiPrimaryId';
		
    secondaryparentID = getParameterByName('secondaryparentID');
    if (secondaryparentID == null || secondaryparentID == '')
        secondaryparentID = 'AtiSecondaryId';

    paramExamID = getParameterByName('examID');
    if (paramExamID == null || paramExamID == '')
        paramExamID = 'examID';

    acredittestpackageID = getParameterByName('primaryparentID');
    if (acredittestpackageID == null || acredittestpackageID == '')
        acredittestpackageID = '1';

    userName = getParameterByName('user');
    if (userName == null || userName == '')
        userName = 'ATI/1mroseberry@acr.org';

    isdebugmode = getParameterByName('isdebugmode');
    if (isdebugmode == null || isdebugmode == '')
        isdebugmode = '0';

    modalityID = getParameterByName('modalityId');

    unitID = getParameterByName('unitId');
    if (unitID == '') unitID = null; //when UAP

    modalityInfoID = getParameterByName('modInfoId');
    if (modalityInfoID == '') modalityInfoID = null;

	//audit trail log params
    auditTrailIsOn = getParameterByName('auditTrailIsOn');
    auditTrailIsOn = auditTrailIsOn != 'false';

    examName = getParameterByName('examName');
    if (examName == '') examName = null;

    modality = getParameterByName('modality');
    if (modality == '') modality = null;

    modalityNumber = getParameterByName('modalityNumber');
    if (modalityNumber == '') modalityNumber = null;

    auditTrailLogger = new AuditTrail(Trial.wcfAuditTrailUrl, userName);
	if (viewType == dicom_view_type)
        GetDependentExamIdsWithView(GetDicomView);
	else if (viewType == nondicom_view_type)
		GetDependentExamIdsWithView(GetNonDicomView); 
    else if (viewType == supportdoc_view_type)
	    GetDependentExamIdsWithView(GetSupportDocsView);
		  
    var $loading = $('#loadingDiv').hide();	  
});
*/
//Page events end


//USER INTERFACE BEGIN


GetDependentExamIdsWithView(callbackForGettingOfView) {
  var input = {
    "ModalityId": modalityID,
    "SelectedExamId": paramExamID};
  //TODO what does this mean?
  $.ajax({
    "url": Triad.wcfTriadAcreditServiceUrl + '/GetDependentSelectedExams',
           "type": 'POST',
           "dataType": 'json',
           "contentType": "application/json; charset=utf-8",
           "data": JSON.encode(input),
           "async": false,
           "success": (result) {
             callbackForGettingOfView(result.DependentExams);
           },
           "beforeSend": (jqXHR, settings) {
             jqXHR.url = settings.url;
           },
    "error": () => ServiceFailed()
         });
}

GetDicomView(dependentExams) {
  var dicomPromises = [];
  var dicomFiles = [];
  //TODO create input class
  var input = {
    "PackageId": primaryparentID,
    "UnitId": secondaryparentID,
    "ExamId": paramExamID,
    "UserName": userName
  };

  //TODO what does this mean
  $.each(dependentExams, (index, value) {
    input.ExamId = value.ExamId;
    var promise = GetFilesInfo(input, value.ExamName, Triad.wcfTriadAcreditServiceUrl + "/GetDicomF"
        "iles", dicomFiles, "DicomStudies");
    dicomPromises.push(promise);
  });

  //TODO what does this mean
  $.when.apply($, dicomPromises).then((schemas) {
    var parendDiv = $('#divListOfExamsInTestingPackage');
    parendDiv.empty();
    var totalFilesCount = 0;
    for (int j = 0; j < dicomFiles.length; j++) {
      if (dicomFiles[j].files.length > 0) {
        parendDiv.append("<div class='examsSeparator'>" + dicomFiles[j].examName + "</div>");
        parendDiv.append(
            "<div style='max-height:200px; overflow:auto;'><table class='reviewTable' cellpadding='0' cellspacing='0' id='dicomFiles" + j +
                "' style='overflow:hidden;width:100%;'>" +
                "<tr><th>Study Description</th><th>Patient Name</th><th>Series Count</th><th>File Count</th><th>View Files</th></tr>" +
                "</table></div>");
        var tblDicom = $('#dicomFiles' + j);
        for (int i = 0; i < dicomFiles[j].files.length; i++) {
          var tbl4tr1 = $('<tr/>').appendTo(tblDicom);

          var td = $('<td/>').text(dicomFiles[j].files[i].Description).css("width", "40%").appendTo(tbl4tr1);
          td = $('<td/>').text(dicomFiles[j].files[i].PatientName).css("width", "30%").appendTo(tbl4tr1);
          td = $('<td/>').text(dicomFiles[j].files[i].SeriesCount).css("width", "10%").appendTo(tbl4tr1);
          td = $('<td/>').text(dicomFiles[j].files[i].FileCount).css("width", "5%").appendTo(tbl4tr1);
          td = $('<td/>').append(
              " <a class='linkButton' onclick='ShowDicom(\"" + dicomFiles[j].files[i].DicomStudyUrl + "\", this);' >View </a>").css(
              "width", "10%").appendTo(tbl4tr1);
        }
        totalFilesCount += dicomFiles[j].files.length;
      }
    }

    parendDiv.append(
        '<div style="position: relative;"><iframe id="dicomFrame" frameborder="0" style="overflow:hidden;min-height:1024px;min-width:100%";height="100%";width="100%"></iframe><div id="iframeLoadingDiv"><img src="images/loader.gif" width="45px" repeat /></div></div>');
    $("#iframeLoadingDiv", parendDiv).hide();

    parendDiv.prepend('<div class="divStaticViewHeader" style="background-color:white; color:black;">DICOM IMAGE REVIEW</div>');

    if (totalFilesCount == 1) $('.linkButton', parendDiv).click();
  });
}

GetFilesInfo(input, examName, url, filesInfoCollection, resultPropertyName) {
  var deferral = new $.Deferred();
  //TODO fix
  $.ajax({
           "url": url,
           "type": 'POST',
           "dataType": 'json',
           "contentType": "application/json; charset=utf-8",
           "data": JSON.encode(input),
           "async": false,
           "success": (result) {
             filesInfoCollection.push({examName: examName, files: result[resultPropertyName]});
             deferral.resolve();
           },
           "beforeSend": (jqXHR, settings) => jqXHR.url = settings.url,
           "error": () {
             ServiceFailed();
             deferral.resolve();
           }
         });
  return deferral.promise();
}

ShowDicom(studyurl, ctrl) {
  $("[id^='dicomFiles'] tr").removeClass("selected");
  $(ctrl).closest('tr').addClass("selected");
  $('#dicomFrame').attr('src', studyurl);
  $('#dicomFrame').load(() {
    $('#iframeLoadingDiv').hide ();
    if (auditTrailIsOn) {
      auditTrailLogger.ViewDicom(examName, modality, modalityNumber, secondaryparentID);
    }
  });
  $('#iframeLoadingDiv').show();
}

GetNonDicomView(dependentExams) {
  var nonDicomPromises = [];
  var nonDicomFiles = [];
  var input = {
    "PackageId": primaryparentID,
    "UnitId": secondaryparentID,
    "ExamId": paramExamID
  };

  //TODO fix
  $.each(dependentExams, (index, value) {
    input.ExamId = value.ExamId;
    var promise = GetFilesInfo(input, value.ExamName, Triad.wcfTriadAcreditServiceUrl + "/GetNonDic"
        "omFiles", nonDicomFiles, "NonDicomFiles");
    nonDicomPromises.push(promise);
  });

  $.when.apply($, nonDicomPromises).then((schemas) {
    var parendDiv = $('#divListOfExamsInTestingPackage');
    parendDiv.empty();
    var totalFilesCount = 0;
    for (int j = 0; j < nonDicomFiles.length; j++) {
      if (nonDicomFiles[j].files.length > 0) {
        parendDiv.append("<div class='examsSeparator'>" + nonDicomFiles[j].examName + "</div>");
        parendDiv.append(
            "<div style='max-height:200px; overflow:auto;'><table class='reviewTable' cellpadding='0' cellspacing='0'  id='nonDicomFiles" +
                j + "' style='overflow:hidden;width:100%;'>" +
                "<tr><th>File Name</th><th>File Size</th><th>File Type</th><th>View Files</th></tr>" +
                "</table></div>");
        var tblNonDicom = $('#nonDicomFiles' + j);
        for (int i = 0; i < nonDicomFiles[j].files.length; i++) {
          var tbl4tr1 = $('<tr/>').appendTo(tblNonDicom);
          var td = $('<td/>').text(nonDicomFiles[j].files[i].FileName).css("text-align", "left").css("width", "40%").appendTo(tbl4tr1);
          td = $('<td/>').text(nonDicomFiles[j].files[i].FileSize).css("width", "10%").appendTo(tbl4tr1);
          td = $('<td/>').text(nonDicomFiles[j].files[i].FileType).css("width", "10%").appendTo(tbl4tr1);
          td = $('<td/>').append(
              " <a class='linkButton' onclick='ShowNonDicom(\"" + Triad.wcfTriadAcreditServiceUrl +
                  "/GetNonDicomFileContent?fileId=" +
                  nonDicomFiles[j].files[i].NonDicomFileId + "&fileType=" + nonDicomFiles[j].files[i].FileType + "&fileName=" +
                  nonDicomFiles[j].files[i].FileName + "\", this);' >View</a>").css("width", "10%").appendTo(tbl4tr1);
        }
        totalFilesCount += nonDicomFiles[j].files.length;
      }
    }

    parendDiv.append(
        '<div style="position: relative;"><iframe id="nondicomFrame" frameborder="0" style="overflow:auto;min-height:1024px;min-width:100%";height="100%";width="100%" scrolling="auto"></iframe><div id="iframeLoadingDiv"><img src="images/loader.gif" width="45px" repeat /></div></div>');
    $("#iframeLoadingDiv", parendDiv).hide();

    parendDiv.prepend('<div class="divStaticViewHeader" style="background-color:white; color:black;">NON-DICOM REVIEW</div>');

    if (totalFilesCount == 1) $('.linkButton', parendDiv).click();
  });
}

ShowNonDicom(fileurl, ctrl, fileName) {
  currentRequestedContentToken = new DateTime.now();
  currentIframeId = '#nondicomFrame';
  $("[id^='nonDicomFiles'] tr").removeClass("selected");
  $(ctrl).closest('tr').addClass("selected");
  $('#nondicomFrame').attr('src', fileurl + "&contentRequestToken=" + currentRequestedContentToken);
  $('#nondicomFrame').load(() {
    $('#iframeLoadingDiv').hide();
    if (auditTrailIsOn) {
      auditTrailLogger.ViewNonDicom(examName, modality, modalityNumber, secondaryparentID, fileName);
    }
  });
  $('#iframeLoadingDiv').show();
  isContentDownloaded(0);
}

GetSupportDocsView(dependentExams) {
  List supportingDocs = [];
  Map input = {
      "PackageId": primaryparentID,
    "UnitId": secondaryparentID,
    "ExamId": paramExamID
  };
  var supportingDocsPromise = GetFilesInfo(input,
                                               "",
      Triad.wcfTriadAcreditServiceUrl + "/GetSupportingDo"
          "cs",
                                               supportingDocs,
                                               "SupportingDocs");
  $.when.apply($, supportingDocsPromise).then((schemas) {
  var parendDiv = $('#divListOfExamsInTestingPackage');
  parendDiv.empty();
  var totalFilesCount = 0;
  for (int j =0; j<supportingDocs.length; j++) {
if (supportingDocs[j].files.length > 0) {
parendDiv.append("<div class='examsSeparator'>"+supportingDocs[j].examName+"</div>");
parendDiv.append(
"<div style='max-height:200px; overflow:auto;'><table class='reviewTable' cellpadding='0' cellspacing='0'  id='tblSupportingDocs" + j + "' style='overflow:hidden;width:100%;'>" +
"<tr><th>Doc Name</th><th>View Files</th></tr>" +
"</table></div>");
var tblSupportingDocs = $('#tblSupportingDocs' + j);
AddRowsToSupportingDocsTable(tblSupportingDocs, supportingDocs[j].files);
}
totalFilesCount += supportingDocs[j].files.length;
}

  var appealLetter = appealLetterService.getFilesEntries(modalityID, unitID, modalityInfoID);

  AddRowsToAppealLetterTable($('[id^="tblSupportingDocs"]:last-child'), appealLetter);
  totalFilesCount+=appealLetter.length;

  parendDiv.append('<div style="position: relative;"><iframe id="supportdocFrame" frameborder="0" style="overflow:hidden;min-height:1024px;min-width:100%";height="100%";width="100%"></iframe><div id="iframeLoadingDiv"><img src="images/loader.gif" width="45px" repeat /></div></div>');
  $("#iframeLoadingDiv", parendDiv).hide ();
  parendDiv.prepend('<div class="divStaticViewHeader" style="background-color:white; color:black;">SUPPORT FILES</div>');

  if (totalFilesCount == 1) $('.linkButton', parendDiv).click();
  });
}

AddRowsToSupportingDocsTable(table, files) {
  for (int i = 0; i < files.length; i++) {
    var tbl4tr1 = $('<tr/>').appendTo(table);
    var td = $('<td/>').text(files[i].FileName).appendTo(tbl4tr1);
    var url = Triad.wcfTriadAcreditServiceUrl + "/GetSupportDocument?fileId=" + files[i]
        .SupportingDocId + "&fileName=" + files[i].FileName;
    if (files[i].SupportingDocId < 0) url = files[i].PageUrl;
    td =
        $('<td/>').append(" <a class='linkButton' onclick='ShowSupportDoc(\"" + url + "\", this);' >View</a>").css("width", "10%").appendTo(
            tbl4tr1);
  }
}

AddRowsToAppealLetterTable(table, files) {
  for (int i = 0; i < files.length; i++) {
    var tbl4tr1 = $('<tr/>').appendTo(table);
    var td = $('<td/>').text(files[i].FileName).appendTo(tbl4tr1);
    var url = Triad.wcfTriadAcreditServiceUrl + "/GetSupportDocument?fileId=" + files[i].FileId + ""
        "&fileName=" + files[i].FileName;
    if (files[i].FileId < 0) url = files[i].ViewUrl;
    td =
        $('<td/>').append(" <a class='linkButton' onclick='ShowSupportDoc(\"" + url + "\", this);' >View</a>").css("width", "10%").appendTo(
            tbl4tr1);
  }
}

ShowSupportDoc(url, ctrl) {
  currentRequestedContentToken = new DateTime.now();
  currentIframeId = '#supportdocFrame';
  $("[id^='tblSupportingDocs'] tr").removeClass("selected");
  $(ctrl).closest('tr').addClass("selected");
  $('#supportdocFrame').attr('src', url + "&output=embed&contentRequestToken=" + currentRequestedContentToken);
  $('#supportdocFrame').load(() {
    $('#iframeLoadingDiv').hide();
  });
  $('#iframeLoadingDiv').show();
  isContentDownloaded(0);
}

isContentDownloaded(safetyCounter) {
  var contentRequestToken = readCookie("contentRequestToken");
  if (currentRequestedContentToken == contentRequestToken) {
    if ($('#iframeLoadingDiv').css('display') != 'none') {
      $(currentIframeId).attr('src', 'about:blank');
      $('#iframeLoadingDiv').hide();
    }
    return;
  }
  if (++safetyCounter > 300) return;
  setTimeout(() {
    isContentDownloaded(safetyCounter);
  }, 1000);
}


showWarning(title, message) {
  $("#popupNotification").html(message);

  $("#popupNotification").dialog({
                                   "resizable": false,
                                   "width": 450,
                                   "modal": true,
                                   "dialogClass": "main-dialog-class",
                                   "buttons": [
                                     {
                                       "text": "Ok",
                                       //"click":() {
                                       //  $(this).dialog("close");
                                       //  return true;
                                       //},
                                       "class": "popupBtn"
                                     }
                                   ]
                                 });
  $('#popupNotification').dialog('option', 'title', title);
}

//HELP FUNCTIONS BEGIN
getParameterByName(name) {
  name = name.replace("[\[]", "\\[").replace("[\]]", "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
  return results == null ? "" : decodeURIComponent(results[1].replace("+/g", " "));
}


createCookie(name, value, days) {
  if (days) {
    var date = new DateTime.now();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    var expires = "; expires=" + date.toGMTString();
  } else {
    var expires = "";
  }
  document.cookie = name + "=" + value + expires + "; path=/";
}

readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (int i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
}

eraseCookie(name) => createCookie(name, "", -1);

var numberOfSymbolsToShowForLongFileNames = 40;

GenerateSelectionNameForUploadTable(selectionFiles) {
  var fileNames = '';
  for (int j = 0; j < selectionFiles.length; j++)
    if (selectionFiles[j] != null && selectionFiles[j].name != null) {
      if (fileNames == '') {
        fileNames += selectionFiles[j].name;
      } else {
        fileNames += ", " + selectionFiles[j].name;
      }
    }

  if (fileNames.length > numberOfSymbolsToShowForLongFileNames)
    fileNames = fileNames.substring(0, numberOfSymbolsToShowForLongFileNames) + '..........';

  return fileNames;
}

replacer(key, value) => (key == "url") ? null : value;

RemoveSymbols(str) => str.toLowerCase().replace("\W/g", '');

//HELP FUNCTIONS END

ServiceFailed(result) {
  showWarning('Service call failed', 'url: <span style="color:red">' + result.url + '</span><br/>' +
      JSON.encode(result, replacer));
  var $loading = $('#loadingDiv').hide();
}

// WCF methods call end

checkCloseEvent() {
  var whetherTheWindowToBeClosed = checkWindowCloseEvent();
  if (whetherTheWindowToBeClosed) {
    window.close();
  }
  setTimeout(checkCloseEvent, 100);
}

//checkCloseEvent(); // execute function

checkWindowCloseEvent() {
  var cname = "cookie-close-windows=";
  var ca = document.cookie.split(';');
  for (int i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(cname) == 0) {
      return JSON.parse(c.substring(cname.length, c.length));
    }
  }
  return null;
}