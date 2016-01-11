library ati_uploader_app;

import "dart:convert";
import "dart:html";
import "dart:math";
import "dart:typed_data";

import "package:uploader/src/types/modality.dart";
import "review_validator.dart";

//TODO: what is the meaning of the JQuery methods and functions?



//SETTINGS BEGIN
//TODO: what is WCF?  And what are these used for?
var wcfAuditTrailUrl = "";  // Audit Trail Server
var wcfAtiServiceUrl = ""; //Web service host Triad for getting Submission Details
var wcfTriadAcreditServiceUrl = "";  //Acridit Server hosted on Triad to internal Acredit Service
var wcfTriadApplicationServiceUrl = "";  //application service
///???
String uploaderBaseUrl;  // Acredit Web Site

//TODO collect Triad Url stuff in one libary

//TODO: remove
//var jquery211 = jQuery.noConflict();

int TriadUploadChunckSize = 2097152; // 2MB
//SETTINGS END

//CONSTANTS BEGIN
//file selection statuses for UI

class FileSelectionStatus {
  static final int    code;
  static final String name;
  static final String description;

  const FileSelectionStatus(this.code, this.name, this.description);

  static const add = const FileSelectionStatus(0, "add", "Adding To Queue");
  static const in = const FileSelectionStatus(1, "in", "In Queue");
  static const reUpload = const FileSelectionStatus(2, "reUpload", "Re-Upload");
  static const completed = const FileSelectionStatus(3, "completed", "Completed");
  static const cancelled = const FileSelectionStatus(4, "cancelled", "Cancelled");
  static const failed = const FileSelectionStatus(5, "failed", "Failed to Upload");

}
const String adding_to_queue_status = 'Adding To Queue';
const String in_queue_status = 'In Queue';
const String failed_to_upload_status = 'Failed To Upload';
const String canceled_status = 'Canceled';
const String re_upload_status = 'Re-upload';
const String completed_status = 'Completed';

//TODO: why global
int deletedSelectionsCount = 0;

//view types
enum ViewType {upload, static, review}
//TODO: flush if enum is sufficient
//const String upload_view_type = 'upload';
//const String static_view_type = 'static';
//const String review_view_type = 'review';
//TODO: what is this used for?  What are all the ViewTypes?
ViewType viewType;

//TODO: why isn't this in css?
const String activeUploadButtonColor = 'rgb(255, 165, 0)';

//TODO: ???
const String returnFalse = "return false;";
//CONSTANTS END

// '$domain/$userName
// e.g. 'ATI/administrator'
//APPLICATION VARIABLES BEGIN
//TODO Document the meaning of these and maybe make them an object
//Business Domain



// Client web Get /triad/TriadAcriditService.svc/GetExamSummaryWithModalityAnd ExamType/<tpid>/<appeak-flag>
String domain;  // ATI,
String primaryparentID;  //Tpid="12345" //Testing Package Id
String secondaryparentID;
String paramExamID;

//TODO Document the meaning of these and maybe make them an object
//TODO: what is the format of a Modality string?
//BMRAP#50625
//String modalityName;
//int modalityNumber;
//String modalityID;
//String unitID;
//String modalityInfoID;

//TODO: ???
String acreditTestPackageID;







String displayedName;
// Switches
bool isdebugmode;
bool auditTrailIsOn;
//TODO: what is an appeal?
bool   isAppeal;


/
List fileSelectionStatusesInCurrentExam = [];
//fileSelectionStatusesInCurrentExam.length = 0;
Map fileSelectionStatusesInAllExams = {};

//TODO: why aren't these local to the uploader
//List numberOfChunksUploaded = [];
//numberOfChunksUploaded.length = 0;

//TODO: what are command GUIDs
List lastUploadsCommandGuids = [];
//lastUploadsCommandGuids.length = 0;

List singleCanceledFileNames = [];
//singleCanceledFileNames.length = 0;



bool whetherTheChildWindowsToBeClosed = true;

//TODO make Aspera an object
var atiAsperaHost;
var atiAsperaUsername;
var atiAsperaPassword;
var atiAsperaSSHPort;
// Aspera switch 
var isAsperaOn = false;
//APPLICATION VARIABLES END

//Page events begin
void main() {
  //main page of app
  //TODO: what is this doing
  if (getParameterByName('ScoringMode') == 'Yes') {
    querySelector('.uploader-td').remove();
  }

  //TODO: what is this doing
	if (getParameterByName('embed') == '0') {
    initControlData();
    return;
  }

  void doNothing() {};

    var colorModeValue = querySelector("[id*='ddlColorMode'] option:selected").val();
    propagateColorModeToTID(colorModeValue);
//TODO: .livequery?
    querySelector('[name = "updated-panel"]').livequery( '[name="table-web-client"]',
                                                (elem) => initControlData(),
                                                doNothing);

    querySelector('table.rs-content-container').livequery( '[name="testingPackageSummary"]',
                                                (elem) => initControlData(),
                                                doNothing);

    querySelector('body').livequery( '#popup_container',
                                                (elem) {
                                                  initControlData();
                                                  querySelector("#popup_container").addClass('popup_container');
                                                  querySelector("#popup_content").addClass('popup_content');
                                                  jquery211.alerts.verticalOffset = - (window.outerHeight / 4);
                                                  var top = (window.outerHeight / 2) -
                                                      (querySelector("#popup_container").outerHeight / 2) +
                                                      jquery211.alerts.verticalOffset;
                                                  var left = (window.outerWidth / 2) -
                                                      (querySelector("#popup_container").outerWidth / 2) +
                                                      jquery211.alerts.horizontalOffset;
                                                  if (top < 0) top = 0;
                                                  if (left < 0) left = 0;

                                                  // IE6 fix
                                                  if (jquery211.browser.msie && parseInt(jquery211.browser.version) <= 6)
                                                    top = top + jquery211(window).scrollTop();
                                                  //TODO: move css to .css
                                                  querySelector("#popup_container").css({top: top + 'px',
                                                                                      left: left + 'px'
                                                                                    });
                                                  querySelector("#popup_overlay").outerHeight(document.height);
                                                },
                                                doNothing);
    //TODO: these lambdas should be local procedures.
  querySelector('body').livequery('.ui-dialog',
                                                (elem) {
                                                  if (querySelector('.ui-dialog .tblErrorStatus').length != 0) {
                                                    querySelector(".ui-dialog").css("width", "50%");
                                                    var left = ((window.outerWidth / 2) -
                                                        (querySelector(".ui-dialog").outerWidth / 2));
                                                    if (left < 0) left = 0;
                                                    querySelector(".ui-dialog").css({left: left + 'px'});
                                                    querySelector(".ui-dialog .ui-dialog-titlebar, .ui-dialog .ui-dialog-buttonpane")
                                                        .remove();
                                                    querySelector("#closePopUpBtn").click(() {
                                                      querySelector(".ui-dialog").remove();
                                                    });
                                                    querySelector(".ui-dialog ").addClass("invalid-files-popup");
                                                  }
                                                },
                                                doNothing);
	
    var firstInitCycle = true;
	querySelector('body').livequery( '[id*="tabImages"]',
                                                (elem) {
                                                  if (firstInitCycle) {
                                                    initControlData();
                                                    firstInitCycle = false;
                                                  }
                                                },
                                                doNothing);
    //TODO: why in sessionStorage
    querySelector("[id*='Upload_Summary']").click(() {
      window.sessionStorage['Is_It_Upload_Summary_Reload_Cycle'] = "true";
    });
        
    querySelector("[id*='rbWebClient']").change(() {
        window.sessionStorage['Is_It_Upload_Summary_Reload_Cycle'] = "true";
        });

    querySelectorAll("[id*='ddlColorMode']").change(() {
      whetherTheChildWindowsToBeClosed = false;
      var newColorModeValue = querySelector("[id*='ddlColorMode'] option:selected").val();
      //TODO: whree defined
      propagateColorModeToTID(newColorModeValue);
    }).forEach((item) {
      var handler = item.prop('onchange');
      item.removeProp('onchange');
      item.change(handler);
    });

    querySelectorAll("[id*='NavigationTemplateContainerID'], [id*='lnkStep'], [id*='btnSave'], [id*='btnCalculate']")
        .onClick(() {
      whetherTheChildWindowsToBeClosed = false;
    }).forEach((item) {
      var handler = item.prop('onclick');
      item.removeProp('onclick');
      item.click(handler);
    });

  //TODO: what is jquery211(this) in this context
    Element e = querySelector("td.ChildCellForRSMenu a").click(() {
      var nextExam = e.attributes["href"].trim();
      var currentExam = window.location.href
          .substring(window.location.href.lastIndexOf('/') + 1).trim();
      if (nextExam == currentExam) {
        whetherTheChildWindowsToBeClosed = false;
      }
    });

    querySelectorAll("[id*='btnNext'], [id*='btnCalculate'], [id*='btnSave']").forEach((item) {
      var currentButton = item;
      var handler = currentButton.prop('onclick');
      currentButton.removeProp('onclick');
      currentButton.click(validateImageReviewSection);
      currentButton.click(handler);
    });

    querySelector(window).on('beforeunload', () {
      if (viewType == ViewType.upload && IsAnyUploadInProgress()) {
        return 'Uploading in progress. if you leave this page, some files will not be uploaded. Are you sure you want to leave?';
      }
      if (viewType == ViewType.review) {
        setChildWindowsCloseEvent(whetherTheChildWindowsToBeClosed);
      }
    });

  //TODO: what does this mean
    jquery211(document).tooltip({
                                  "hide": { "effect": "none", "duration": 1000},
                                  "collision": "flip"
                                });

      addValidationHandlerToUploadImagesNextButton();
    });
}
//Page events end

initControlData() {
  //TODO recode getAttributeByName and getParameterByName('data-domain');

  viewType = getAttributeByName('data-view-type');
  if (viewType == null || viewType == '') {
    viewType = getParameterByName('view');
    if (viewType == null || viewType == '') {
      viewType = ViewType.upload;
    }
  }

  showInstructionsOnStartup();

  querySelector('#divListOfExamsInTestingPackage').attribute['style'] = 'display:';

  var jquery211loading = querySelector('#loadingDiv');
  jquery211loading.show();

  if (domain == null || domain == '') {
    domain = getParameterByName('domain');
    if (domain == null || domain == '') {
      domain = 'ATI';
    }
  }

  primaryparentID = getAttributeByName('data-primaryparent-id');
  if (primaryparentID == null || primaryparentID == '') {
    primaryparentID = getParameterByName('primaryparent');
    if (primaryparentID == null || primaryparentID == '') {
      primaryparentID = 'AtiPrimaryId';
    }
  }

  secondaryparentID = getAttributeByName('data-secondaryparent-id');
  if (secondaryparentID == null || secondaryparentID == '') {
    secondaryparentID = getParameterByName('secondaryparent');
    if (secondaryparentID == null || secondaryparentID == '') {
      secondaryparentID = 'AtiSecondaryId';
    }
  }

  paramExamID = getAttributeByName('data-exam-id');
  if (paramExamID == null || paramExamID == '') {
    paramExamID = getParameterByName('examID');
    if (paramExamID == null || paramExamID == '') {
      paramExamID = 'examID';
    }
  }

  acreditTestPackageID = getAttributeByName('data-primaryparent-id');
  if (acreditTestPackageID == null || acreditTestPackageID == '') {
    acreditTestPackageID = getParameterByName('primaryparent');
    if (acreditTestPackageID == null || acreditTestPackageID == '') {
      acreditTestPackageID = '1';
    }
  }

  userName = getAttributeByName('data-user');
  if (userName == null || userName == '') {
    userName = getParameterByName('user');
    if (userName == null || userName == '') {
      userName = 'ATI/emptyweb@acr.org';
    }
  }

  isdebugmode = getAttributeByName('data-is-debug-mode');
  if (isdebugmode == null || isdebugmode == '') {
    isdebugmode = getParameterByName('isdebugmode');
    if (isdebugmode == null || isdebugmode == '') {
      isdebugmode = '0';
    }
  }

  var auditTrailIsOnValue = getAttributeByName('data-audit-trail-is-on');
  auditTrailIsOn = auditTrailIsOnValue != 'false';

  isAppeal = getAttributeByName('data_is_appeal');
  if (isAppeal == null || isAppeal == '') {
    isAppeal = getParameterByName('isappeal');
    if (isAppeal == null || isAppeal == '') {
      isAppeal = '0';
    }
  }
  modalityID = getParameterByName('ModId');

  if (location.href.indexOf("Uploader.aspx") != -1) {
    modality.number = getParameterByName('ModNumber');
    if (modality.number == '') modality.number = null;

    modality.name = getParameterByName('ModName');
    if (modality.name == '') modality.name = null;
  } else if (location.href.indexOf("ViewListOfUnits.aspx") != -1) {
    modality.name = jquery211("[id*='ddlModality'] option:selected").text();
    modality.number = jquery211("[id*='txtModalityId']").val().trim();
  } else {
    modality.number = null;
    Modality.name = null;
  }

  modality.unitID = getParameterByName('UnitId');
  if (modality.unitID == '') modality.unitID = null;
  //when UAP

  modality.infoID = getParameterByName('ModInfoId');
  if (modality.infoID == '') modality.infoID = null;

  uploaderBaseUrl = getAttributeByName('data-uploader-base-url');
  if (uploaderBaseUrl == null || uploaderBaseUrl == '') {
    uploaderBaseUrl = '.';
  }

  //TODO: what is the format of a modality string
 //Note: Acredit specific logic
  if (viewType == ViewType.review) {
    var promises = GetDependentExamIdsAndReviewView();
    var appealLetterPromise = appealLetterService.init(modality.id, modality.unitId, modality.infoId);
    jquery211.when(promises[0], promises[1], promises[2],
                       appealLetterPromise).done((areThereDicomFiles, areThereNonDicomFiles, areThereSupportFiles) {
      var name = getAttributeByName("data-modality");
      var modality = name.substring(0, name.indexOf('#'));
      reviewValidator.init(
          primaryparentID,
          secondaryparentID,
          paramExamID,
          modality,
          userName,
          areThereDicomFiles,
          areThereNonDicomFiles,
          areThereSupportFiles);
      RestoreExamState();
      jquery211('#loadingDiv').hide();
    });
  } else
    GetListOfAcreditExams();

  // TODO : ASPINT
  if (isAsperaOn) {
    if (viewType != ViewType.review && viewType != ViewType.static)
      GetAsperaSettings();
  }
}


GetDependentExamIdsAndReviewView() {
  var gettingOfDicomFilesPromise = jquery211.Deferred();
  var gettingOfNonDicomFilesPromise = jquery211.Deferred();
  var gettingOfSupportFilesPromise = jquery211.Deferred();

  //TODO replace [input] everywhere
  var input = {ModalityId: modalityID, SelectedExamId: paramExamID};
  //TODO: Replace with HTTPRequesst
  jquery211.ajax(
      { "url": wcfTriadAcreditServiceUrl + '/GetDependentSelectedExams',
        "type": 'POST',
        "dataType": 'json',
        "contentType": "application/json; charset=utf-8",
        "data": JSON.encode(input),
        "async": false,
        "success": (result) {
          GetReviewView(result.DependentExams, gettingOfDicomFilesPromise, gettingOfNonDicomFilesPromise, gettingOfSupportFilesPromise);
        },
        "beforeSend": (jqXHR, settings) {
          jqXHR.url = settings.url;
        },
        "error": () {
          ServiceFailed();
          gettingOfDicomFilesPromise.reject();
          gettingOfNonDicomFilesPromise.reject();
        }
      });
  return [gettingOfDicomFilesPromise.promise(), gettingOfNonDicomFilesPromise.promise(), gettingOfSupportFilesPromise.promise()];
}

//USER INTERFACE BEGIN
GetReviewView(dependentExams, gettingOfDicomFilesPromise, gettingOfNonDicomFilesPromise, gettingOfSupportFilesPromise) {
  var parendDiv = jquery211('#divListOfExamsInTestingPackage');
  parendDiv.empty();

  String url = '';
  String btnViewPart = '';

  var appealLetterUrlParameter;
  if (modality.unitId != null) appealLetterUrlParameter = "&unitId=" + modlaity.unitId;
  else appealLetterUrlParameter = "&modInfoId=" + modality.infoId;

  // DICOM

  var dicomPromises = [];
  var dicomFiles = [];
  //TODO: replace
  var input = {
    "PackageId": primaryparentID,
    "UnitId": secondaryparentID,
    "ExamId": paramExamID,
    "UserName": userName};

  jquery211.each(dependentExams, (index, value) {
    input.ExamId = value.ExamId;
    var promise = GetFilesInfo(input, wcfTriadAcreditServiceUrl + "/GetDicomFiles", dicomFiles, "DicomStudies");
    dicomPromises.push(promise);
  });

  jquery211.when.apply(jquery211, dicomPromises).then((schemas) {
    url = uploaderBaseUrl + '/review.html?domain=ATI&primaryparentID=' + primaryparentID + '&secondaryparentID=' + secondaryparentID +
        '&examID=' + paramExamID + '&viewType=dicom' + '&user=' + userName + '&modalityId=' + modalityID + appealLetterUrlParameter +
        createAuditTrailUrlParameters(auditTrailIsOn);
    var areThereDicomFiles = dicomFiles.length > 0;
    if (areThereDicomFiles) {
      btnViewPart =
          "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID +
              "' type='button' value='View' class='btn btn-uploadfile' onclick='ReviewFile(\"" + url +
              "\", \"dicom\"); markDicomFilesAsReviewed();'/> </span> ";
      parendDiv.append(
          "<div class='divTestingPackage' style='overflow: hidden; margin-left: 0%; width: inherit; color: black;'><label class='labelTestingPackageToggle dicomReviewRow'  id='lblExamReviewHeader" +
              paramExamID + "'>DICOM Files</label><label id='dicomNotReviewedValidationError' class='validationError'></label>" +
              btnViewPart + "</div>");
    }
    //    else {
    //        btnViewPart = "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID + "' type='button' value='View'  class='btn btn-nouploadfile'  disabled/> </span> ";
    //    }
    gettingOfDicomFilesPromise.resolve(areThereDicomFiles);
  }, (e) {
    //url = uploaderBaseUrl + '/review.html?domain=ATI&primaryparentID=' + primaryparentID + '&secondaryparentID=' + secondaryparentID + '&examID=' + paramExamID + '&viewType=dicom'+'&user='+userName+'&modalityId='+modalityID;
    //btnViewPart = "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID + "' type='button' value='View'  class='btn btn-nouploadfile'  disabled/> </span> ";
    //parendDiv.append("<div class='divTestingPackage' style='overflow: hidden; margin-left: 0%; width: inherit; color: black;'><label class='labelTestingPackageToggle dicomReviewRow'  id='lblExamReviewHeader" + paramExamID + "'>DICOM Files</label><label id='dicomNotReviewedValidationError' class='validationError'></label>" + btnViewPart + "</div>");
    gettingOfDicomFilesPromise.resolve(false);
  });

  // NON DICOM

  var nonDicomPromises = [];
  var nonDicomFiles = [];
  //TODO replace
  var input = { PackageId: primaryparentID, UnitId: secondaryparentID, ExamId: paramExamID};

  dependentExams.forEach((index, value) {
    input.ExamId = value.ExamId;
    var promise = GetFilesInfo(input, wcfTriadAcreditServiceUrl + "/GetNonDicomFiles", nonDicomFiles, "NonDicomFiles");
    nonDicomPromises.push(promise);
  });

  jquery211.when.apply(jquery211, nonDicomPromises).then((schemas) {
    url = uploaderBaseUrl + '/review.html?domain=ATI&primaryparentID=' + primaryparentID + '&secondaryparentID=' + secondaryparentID +
        '&examID=' + paramExamID + '&viewType=nondicom' + '&user=' + userName + '&modalityId=' + modalityID + appealLetterUrlParameter +
        createAuditTrailUrlParameters(auditTrailIsOn);
    var areThereNonDicomFiles = nonDicomFiles.length > 0
    if (areThereNonDicomFiles) {
      btnViewPart =
          "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID +
              "' type='button' value='View' class='btn btn-uploadfile' onclick='ReviewFile(\"" + url +
              "\", \"nondicom\"); markNonDicomFilesAsReviewed();'/> </span> ";
      parendDiv.append(
          "<div class='divTestingPackage' style='overflow: hidden; margin-left: 0%; width: inherit; color: black;'><label class='labelTestingPackageToggle nonDicomReviewRow'  id='lblExamReviewHeader" +
              paramExamID + "'>Non-DICOM Files</label><label id='nonDicomNotReviewedValidationError' class='validationError'></label>" +
              btnViewPart + "</div>");
    }
    //else {
    //    btnViewPart = "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID + "' type='button' value='View'  class='btn btn-nouploadfile'  disabled/> </span> ";
    //}
    gettingOfNonDicomFilesPromise.resolve(areThereNonDicomFiles);
  }, (e) {
    //url = uploaderBaseUrl + '/review.html?domain=ATI&primaryparentID=' + primaryparentID + '&secondaryparentID=' + secondaryparentID + '&examID=' + paramExamID + '&viewType=nondicom&modalityId='+modalityID;
    //btnViewPart = "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID + "' type='button' value='View'  class='btn btn-nouploadfile'  disabled/> </span> ";
    //parendDiv.append("<div class='divTestingPackage' style='overflow: hidden; margin-left: 0%; width: inherit; color: black;'><label class='labelTestingPackageToggle nonDicomReviewRow'  id='lblExamReviewHeader" + paramExamID + "'>Non-DICOM Files</label><label id='nonDicomNotReviewedValidationError' class='validationError'></label>" + btnViewPart + "</div>");
    gettingOfNonDicomFilesPromise.resolve(false);
  });

  // Supporting Docs

  var supportingDocs = [];
  Map input = {
    "PackageId": primaryparentID,
    "UnitId": secondaryparentID,
    "ExamId": paramExamID
  };
  var supportingDocsPromise = GetFilesInfo(input, wcfTriadAcreditServiceUrl + "/GetSupportingDocs", supportingDocs, "SupportingDocs");

  jquery211.when.apply(jquery211, supportingDocsPromise).then((schemas) {
    url = uploaderBaseUrl + '/review.html?domain=ATI&primaryparentID=' + primaryparentID + '&secondaryparentID=' + secondaryparentID +
        '&examID=' + paramExamID + '&viewType=supportdoc&modalityId=' + modalityID + appealLetterUrlParameter;
    bool areThereSupportFiles = supportingDocs.length > 0 || appealLetterService
        .getFilesEntries(modalityID, unitID, modalityInfoID)
        .length > 0;
    if (areThereSupportFiles) {
      btnViewPart =
          "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID +
              "' type='button' value='View' class='btn btn-uploadfile' onclick='ReviewFile(\"" + url +
              "\", \"supportdoc\"); markSupportFilesAsReviewed();'/> </span> ";
      parendDiv.append(
          "<div class='divTestingPackage' style='overflow: hidden; margin-left: 0%; width: inherit; color: black;'><label class='labelTestingPackageToggle'  id='lblExamReviewHeader" +
              paramExamID + "'>Support Files</label><label id='supportNotReviewedValidationError' class='validationError'></label>" +
              btnViewPart + "</div>");
      parendDiv.prepend(
          '<div id="staticHeaderImageReview" class="divStaticViewHeader" style="background-color:white; color:black;">IMAGE REVIEW <label id="imageReviewValidationError" class="validationError"></label></div>');
    }
    //else {
    //    btnViewPart = "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID + "' type='button' value='View'  class='btn btn-nouploadfile'  disabled/> </span> ";
    //}

    gettingOfSupportFilesPromise.resolve(areThereSupportFiles);
  }, (e) {
    //url = uploaderBaseUrl + '/review.html?domain=ATI&primaryparentID=' + primaryparentID + '&secondaryparentID=' + secondaryparentID + '&examID=' + paramExamID + '&viewType=supportdoc&modalityId='+modalityID;
    //btnViewPart = "<span id='divViewButtons" + paramExamID + "' class='divViewButtons'>  <input id='btnDicomViewForReview" + paramExamID + "' type='button' value='View'  class='btn btn-nouploadfile'  disabled/> </span> ";
    //parendDiv.append("<div class='divTestingPackage' style='overflow: hidden; margin-left: 0%; width: inherit; color: black;'><label class='labelTestingPackageToggle'  id='lblExamReviewHeader" + paramExamID + "'>Support Files</label><label id='supportNotReviewedValidationError' class='validationError'></label>" + btnViewPart + "</div>");
    //parendDiv.prepend('<div id="staticHeaderImageReview" class="divStaticViewHeader" style="background-color:white; color:black;">IMAGE REVIEW <label id="imageReviewValidationError" class="validationError"></label></div>');
    gettingOfSupportFilesPromise.resolve(false);
  });
}

ReviewFile(url, name) {
  setChildWindowsCloseEvent(false);

  var childWindow = window.open(
      url, name, 'left=0,top=0,width=1024,height=768,titlebar=0,toolbar=0,location=no,resizable=1,fullscreen=0,scrollbars=1');
  childWindow.focus();
}

GetFilesInfo(input, url, filesInfoCollection, resultPropertyName) {
  var deferral = new jquery211.Deferred();
  //TODO replace with HTTPRequest
  jquery211.ajax({
                 "url": url,
                 "type": 'POST',
  "dataType": 'json',
  "contentType": "application/json; charset=utf-8",
  "data": JSON.encode(input),
  "async": false,
  "success": (result) {
  filesInfoCollection.push.apply(filesInfoCollection, result[resultPropertyName]);
  deferral.resolve();
  },
  "beforeSend": (jqXHR, settings) {
  jqXHR.url = settings.url;
  },
  error(){
  ServiceFailed();
  deferral.resolve();
  }
                 });
  return deferral.promise();
}

//Note: generates upload page
GenerateUploadUIForFilesSelections(examId) {
  var parendDiv = querySelector("div[id^='divFilesForUpload" + examId + "']");
  parendDiv.empty();
  var wasHeaderAdded = false;
  var tblWithSelectionsForUpload;
  var rowNumber = 0;
  for (int i = 0; i < fileSelectionsInCurrentExam.length; i++) {
    if (fileSelectionsInCurrentExam[i] != null && fileSelectionsInCurrentExam[i].length > 0) {
      if (!wasHeaderAdded) {
        var slidingDiv = querySelector('<div/>').attributes["id"] = "divFiles" + examId;
            slidingDiv.appendTo(parendDiv);
        tblWithSelectionsForUpload = querySelector('<table/>').attributes['id'] = 'tblUploadFiles$examId';
        tblWithSelectionsForUpload.attributes['cellpadding'] = '0';
        tblWithSelectionsForUpload.attributes['cellspacing'] = '0';
        tblWithSelectionsForUpload.addClass('uploadImagesMainTable').appendTo(slidingDiv);
        var tr1 = querySelector('<tr/>').addClass('uploadImagesDicomFilesHeader').appendTo(tblWithSelectionsForUpload);
        var td1 = querySelector('<td/>').css["width"] = '40%';
        td1.text("File Name").appendTo(tr1);
        var td2 = querySelector('<td/>').css("width", '15%').text("No. of Files").appendTo(tr1);
        var td3 = querySelector('<td/>').css("width", '30%').text("Upload Status").appendTo(tr1);
        var td4 = querySelector('<td/>').css("width", '15%').appendTo(tr1);
        wasHeaderAdded = true;
      }

      var fileNames = '';
      var tooltip = '';
      var numberOfFiles = 0;
      if (fileSelectionsInCurrentExam[i].length > 0) {
        var tempFilesArray = fileSelectionsInCurrentExam[i];

        for (j = 0; j < tempFilesArray.length; j++)
          if (tempFilesArray[j] != null && tempFilesArray[j].name != null) {
            numberOfFiles++;
            if (fileNames == '') {
              if (isAsperaOn) {
                fileNames += tempFilesArray[j].replace(/^.*[\\\/]/, '');
              } else {
                fileNames += "'" + tempFilesArray[j].name + "'";
              }
            } else {
              if (isAsperaOn) {
                fileNames += ", " + tempFilesArray[j].replace(/^.*[\\\/]/, '');
              } else {
                fileNames += ", '" + tempFilesArray[j].name + "'";
              }
            }

            if (tempFilesArray.length <= 1) {
              if (isAsperaOn) {
                tooltip += tempFilesArray[j].replace(/^.*[\\\/]/, '');
              } else {
                if (tempFilesArray[j].name.length > numberOfSymbolsToShowForLongFileNames) tooltip = tempFilesArray[j].name;
              }
            }
          }

        if (fileNames != '') {
          var tr1 = querySelector('<tr/>').appendTo(tblWithSelectionsForUpload);
          rowNumber++;
          tr1.addClass('uploadImagesFileRowAlternative');

          displayedName = (isAsperaOn)
                          ? GenerateSelectionNameForAsperaUploadTable(tempFilesArray)
                          : GenerateSelectionNameForUploadTable(tempFilesArray);

          var td1 = jquery211('<td/>').attr('alt', tooltip).attr('title', tooltip).text(displayedName).appendTo(tr1);

          var td2 = jquery211('<td/>').text(numberOfFiles).appendTo(tr1);
          var displayedStatus = fileSelectionStatusesInCurrentExam[i].DisplayedText;
          var rowStatus = fileSelectionStatusesInCurrentExam[i].Status;
          var showRetryButton = "style='display:none'";
          if (rowStatus == failed_to_upload_status || rowStatus == canceled_status)
            showRetryButton = "";
          if (rowStatus == failed_to_upload_status)
            rowStatus = '<span style="color:Red; margin-right:5px;">Failed To Upload</span>';

          var btnUploadFiles = jquery211("<a id='btnUploadFiles" + rowNumber + "' " + showRetryButton +
                                             " class='uploadFailedFilesBtn'  type='button' title='Retry' onclick='retryUpload(" +
                                             rowNumber + ", jquery211(this))'></a>");
          var td3 = jquery211('<td/>').attr('rowNumber', rowNumber).attr("style", "text-align:center; vertical-align:middle").append(
              displayedStatus).append(btnUploadFiles).appendTo(tr1);

          var cancelRemoveButton = jquery211("<a id='cancelOrRemoveButton" + rowNumber +
                                                 "' class='removeOrCancelUpload' title='Remove Selection' onclick=\"cancelOrRemoveUpload([" +
                                                 fileNames + "]," + rowNumber + "," + examId + ") \" ></a>");
          if (rowStatus == completed_status) cancelRemoveButton.removeClass('removeOrCancelUpload');
          var td4 = jquery211('<td/>').append(cancelRemoveButton).appendTo(tr1);
        }
      }
    }
  }
}


void LaunchClaronViewer(String studyurl) {
  const msg = 'temp window to test Claron integration';
  const args = 'left=(screen.width/2)-400,top=(screen.height/2) - 180,width=800,height=360,toolbar=1,location =1,resizable=1,fullscreen=0';
  var newwindow = window.open(studyurl, msg, args);
  newwindow.focus();
}

void ViewNonDicomFile(String studyurl) {
  const msg = 'Non-Dicom file';
  const cmd = 'left=(screen.width/2)-400, top=(screen.height/2) - 180,'
      'width=800,height=360,toolbar=1, location=1,resizable=1,fullscreen=0';
  var newwindow = window.open(studyurl, msg, cmd);
  newwindow.focus();
}

void HideExamTab(String examId) {
  //TODO: what does next line mean?
  //jquery211("li[examid=" + examId + " ]", jquery211('#divUploadImages')).attr("style", "display:none");
  var context = querySelector('#divUploadImages').attributes["style"] = "display:none";
  context.querySelector("li[examid=" + examId + " ]");
}

void HideAllDeleteButtons(String examId) {
  //TODO: fix - the examName is not used
  //var examName = querySelector("#lblExamReviewHeader" + examId).text;
  var slidingDivId = "slidingDiv" + examId;
  var slidingDiv = jquery211('#' + slidingDivId);

  var context = querySelector(slidingDiv).attributes["style"] = "display:none";
  context.querySelector("a[onclick^='DeleteDicomFileFromServer']");
  context = querySelector(slidingDiv).attributes["style"] = "display:none";
  context.querySelector("a[onclick^='DeleteNonDicomFileFromServer']");
}

void ShowAllDeleteButtons(String examId) {
  //TODO: fix - the examName is not used
  //var examName = querySelector("#lblExamReviewHeader" + examId).text;

  //TODO: var -> type
  var slidingDivId = "slidingDiv" + examId;
  var slidingDiv = querySelector('#' + slidingDivId);

  var context = querySelector(slidingDiv).attributes["style"] = "display:";
  context.querySelector("a[onclick^='DeleteDicomFileFromServer']");
  context = querySelector(slidingDiv).attributes["style"] = "display:";
  context.querySelector("a[onclick^='DeleteNonDicomFileFromServer']");
}

void ShowExamTab(examId) {
  var context = querySelector('#divUploadImages').attributes["style"] = "display:''";
  context.querySelector("li[examid=" + examId + " ]");
}

void HideReadyForSubmissionCheckboxes() {
  querySelector('div[id^="divReadyForSubmission"]').attributes["style"] = "color:gray";
  querySelector('div[id^="divReadyForSubmission"] :input').attributes["disabled"] = "true";
}

ShowReadyForSubmissionCheckboxes() {
  querySelector('div[id^="divReadyForSubmission"]').attributes["style"] = "color:black";
  jquery211('div[id^="divReadyForSubmission"] :input').attributes.remove("disabled");
}

UpdateAttestationUI() {
  if (IsAllReadyForSubmissionCheckboxesChecked()) {
    querySelector("#divAttestestation").attributes["style"] = "color:black";
    querySelector("#cbxAttestestation").attributes.remove("disabled");
  } else {
    querySelector("#divAttestestation").attributes["style"] = "color:gray";
    querySelector("#cbxAttestestation").attributes["disabled"] = "true";
    var tabWasActivated = false;
    querySelectorAll('input[id^="cbxReadyForSubmission"]').forEach((item) {
      if (!tabWasActivated) {
        if (!item.checked) tabWasActivated = true;
      }
    });
  }
}

DisableReadyForSubmissionCheckBox(examId) {
    jquery211("#cbxReadyForSubmission" + examId + "").prop("disabled", "true");
}

DisableAndUncheckReadyForSubmissionCheckBox(examId) {
  if (jquery211("#cbxReadyForSubmission" + examId + "").prop("checked"))
    jquery211("#cbxReadyForSubmission" + examId + "").removeAttr("checked");
  jquery211("#cbxReadyForSubmission" + examId + "").prop("disabled", "true");
}

EnableReadyForSubmissionCheckBox(examId) {
  jquery211("#cbxReadyForSubmission" + examId + "").removeAttr("disabled");
}

IsAllReadyForSubmissionCheckboxesChecked() {
  var isAnyUnchecked = false;
  jquery211('input[id^="cbxReadyForSubmission"]').each((index) {
    if (!jquery211(this).prop('checked')) {
      isAnyUnchecked = true;
      return false;
    }
  });
  return (!isAnyUnchecked) ? true : false;
}

ReloadExam(examId) {
  var aPackage = jquery211('#mainLink' + examId);
  if (aPackage.attr("loaded") == 1) {
    aPackage.attr("loaded", "");
  }
  GetExamDetails(jquery211("#mainLink" + examId), jquery211("#slidingDiv" + examId));
}

HideExamMessage(examid) {
  jquery211("#tblStatus" + examid).attr("style", "display:none");
}

HideUploadResultTable(examId) {
  jquery211("#tblUploadFiles" + examId).remove();
  fileSelectionsInAllExams[examId] = null;
}

DisplayErrorInExam(examid, message) {
  showNotification('Upload error', '<span class="tblErrorStatus">' + message + '</span>');
}

DisplayErrorLogInExam(examid, message) {
  querySelector("#tblStatus" + examid).attributes["style"] = "display:";
  querySelector("#tblStatus" + examid).attributes["class"] = "tblLogStatus";
  querySelector("#tdStatusMessage" + examid).text = message;
}

CloseReviewersAndUploaders() {
  querySelectorAll('div[id^="slidingDiv"]').forEach((Element item) {
    var examid = item.attributes["examid"];
    var slidingDiv = item;
    if (slidingDiv[':visible']) slidingDiv.slideUp();
  });
}

OpenAllReviewers() {
  querySelectorAll('div[id^="slidingDiv"]').forEach((Element item) {
    item.css("display", "block");
    var examid = item.attributes["examid"];
    var slidingDiv = item;
    slidingDiv.slideDown();

    var aPackage = querySelector('#mainLink' + examid);
    aPackage.show();
  });
}

SetupUIForUploadButtons(activeExamId) {
    var btnUploaderActive = jquery211('#btnUploader' + activeExamId);
    if (btnUploaderActive.css('background-color') != activeUploadButtonColor) {
        //1. enable upload button for currect exam
        btnUploaderActive.css('background-color', activeUploadButtonColor);
        btnUploaderActive.css('border-color', '');
        btnUploaderActive.removeAttr('disabled');
        btnUploaderActive.css('cursor', 'pointer');

        //2. disable upload button for rest of exams
        jquery211('div[id^="uploaderDiv"]').each(
        (index) {
            var examid = jquery211(this).attr("examid");
            if (examid != activeExamId) {
                var slidingDiv = jquery211(this);
                var btnUploader = jquery211('#btnUploader' + examid);
                if (slidingDiv.is(':visible'))
                    slidingDiv.slideUp();
                btnUploader.css('background-color', 'lightgrey');
                btnUploader.css('border-color', 'lightgrey');
                btnUploader.css('cursor', 'not-allowed');
                btnUploader.attr('disabled', 'disabled');
            }
        });
    } else {
        jquery211('div[id^="uploaderDiv"]').each(
          (index) {
              var examid = jquery211(this).attr("examid");
              var slidingDiv = jquery211(this);
              var btnUploader = jquery211('#btnUploader' + examid);
              btnUploader.css('background-color', '');
              btnUploader.css('background-color', '');
              btnUploader.css('cursor', 'pointer');
              if (!jquery211("#cbxReadyForSubmission"+examid).is(":checked")) {btnUploader.removeAttr('disabled');}
          });

    }

GetActiveUploaderContainer() {
  var activeUploader = null;
  querySelectorAll('div[id^="uploaderDiv"]').forEach((item) {
    if (item[':visible']) activeUploader = querySelector(item);
  });
  return activeUploader;
}
DisableUploadMode() {
  querySelectorAll('a[id^="mainLink"]').forEach((item) {
    if (item["onclick"] != null && item["onclick"].indexOf(returnFalse) == 0)
      item["onclick"].substring(returnFalse.length);
  });
  EnableUploadForExams();
}

propagateColorModeToTID(colorModeValue){
   createCookie("TIDColorMode", colorModeValue, 365);
}
//USER INTERFACE END


//HELP FUNCTIONS BEGIN

getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

getAttributeByName(name) {
    return jquery211("[name='testingPackageSummary']").attr(name);
}

createCookie(name, value, days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        var expires = "; expires=" + date.toGMTString();
    }
    else var expires = "";
    document.cookie = name + "=" + value + expires + "; path=/";
}

readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

eraseCookie(name) {
    createCookie(name, "", -1);
}


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

replacer(key, value) {
  if (key == "url") return null;
  else return value;
}

RemoveSymbols(String s) => s.toLowerCase().replace(/\W/g, '');

//TODO use Path package
GetLastFolder(String path) {
  var split = path.split("\\");
  return RemoveSymbols(split[split.length - 1]);
}


//TODO fix
/*
var guid = (() {
    s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
                   .toString(16)
                   .substring(1);
    }
    return () {
        return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
               s4() + '-' + s4() + s4() + s4();
    };
})();
*/

//TODO: fix
isInputDirSupported() {
  var tmpInput = document.createElement('input');
  if ('webkitdirectory' in tmpInput
  || 'mozdirectory' in tmpInput
  || 'odirectory' in tmpInput
  || 'msdirectory' in tmpInput
  || 'directory' in tmpInput) return true;

  return false;
}

SortByExamName(a, b) {
  var aName = a.ExamName.toLowerCase();
  var bName = b.ExamName.toLowerCase();
  return ((aName < bName) ? -1 : ((aName > bName) ? 1 : 0));
}

//TODO: replace with dart lib routine
_arrayBufferToBase64(Uint8List buffer) {
  var binary = '';
  var bytes = new Uint8List.fromList(buffer);
  var len = bytes.byteLength;
  for (var i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i].);
  }
  return window.btoa(binary);
}

printDiv(divName) {
  OpenAllReviewers();
  querySelector('#' + divName).printElement();
}

validateImageReviewSection() {
  var reasonNotReviewedCode = querySelector("[id*='DdlexReasonNotReviewed'] option:selected").val();

  switch (reasonNotReviewedCode) {
    case "3":
      querySelector("[id*=areAllRequiredFilesReviewedValue]").attributes["value"] = true;
      return;
    default:
      querySelector("[id*=areAllRequiredFilesReviewedValue]").attributes["value"] = reviewValidator.areAllRequiredFilesReviewed();
      reviewValidator.setExamReviewErrorState(true);
  }
}

RestoreExamState() {
  if (reviewValidator.isExamReviewInErrorState() && !reviewValidator.areAllRequiredFilesReviewed()) {
    jquery211("[id*='SummaryValidator_lbValid']").prepend("Errors in Section IMAGE REVIEW. </br>");
    jquery211("#imageReviewValidationError").text("Please view all files");
    if (!reviewValidator.areDicomFilesReviewed()) {
      jquery211("#dicomNotReviewedValidationError").text("(not reviewed)");
    }
    if (!reviewValidator.areNonDicomFilesReviewed()) {
      jquery211("#nonDicomNotReviewedValidationError").text("(not reviewed)");
    }
    if (!reviewValidator.areSupportFilesReviewed()) {
      jquery211("#supportNotReviewedValidationError").text("(not reviewed)");
    }
  }
  querySelector("input[id*='btnNext']").attributes["areallrequiredfilesreviewed"] = true;
}

markDicomFilesAsReviewed() {
    reviewValidator.markDicomFilesAsReviewed();
    querySelector("#dicomNotReviewedValidationError").empty();
}

markNonDicomFilesAsReviewed() {
    reviewValidator.markNonDicomFilesAsReviewed();
    querySelector("#nonDicomNotReviewedValidationError").empty();
}

markSupportFilesAsReviewed() {
  reviewValidator.markSupportFilesAsReviewed();
  querySelector("#supportNotReviewedValidationError").empty();
}

addValidationHandlerToUploadImagesNextButton() {
  var button = querySelector("#ctl00_ctl21");
  var handler = button.prop("onclick");
  button.removeAttr("onclick");
  //TODO: where is event for validateUpload...
  button.click(validateUploadImagesSection(null));
  button.click(handler);
}

validateUploadImagesSection(e) {
  var checkboxesCount = querySelector("#divListOfExamsInTestingPackage")
      .querySelector("input[id^='cbxReadyForSubmission']")
      .length;
  var checkedCheckboxesCount = querySelector("#divListOfExamsInTestingPackage")
      .querySelector("input[id^='cbxReadyForSubmission']:checked")
      .length;
  if (checkboxesCount != checkedCheckboxesCount) {
    querySelector("#validationMessageBlock").empty().append(
        "Please select all \"Ready for Submission\" check boxes before moving to the next step.");
    e.stopImmediatePropagation();
  }
}

//HELP FUNCTIONS END

//UPLOAD BEGIN
//NOTE: uploads one or more files




//UPLOAD END


//FILE SELECTION OPERATIONS BEGIN
DeleteSelectionOfFilesForUploadByIndex(int rowNumber) {
    var currentNumberOfUpload = getNumberOfFileSelectionInUpload();
    fileSelectionsInCurrentExam.splice(rowNumber - 1, 1);
    fileSelectionStatusesInCurrentExam.splice(rowNumber - 1, 1)[0];
    if (fileSelectionStatusesInCurrentExam.length == 0) {
        deletedSelectionsCount = 0;
        return;
    }   
    
    if (IsAnyUploadInProgress() && currentNumberOfUpload > rowNumber - 1) {        
        deletedSelectionsCount++;
    }
};

CancelOneFileUpload(cancelFileName, rowNumber) {
	if (typeof rowNumber != "undefined"){
		fileSelectionStatusesInCurrentExam[rowNumber - 1].Status = canceled_status;
    	fileSelectionStatusesInCurrentExam[rowNumber - 1].DisplayedText = canceled_status;
	}  
    

    cancelFileName = cancelFileName.trim();
    if (cancelFileName.indexOf(",") > -1) {
        var arr = cancelFileName.split(',');  
        singleCanceledFileNames.splice(0, singleCanceledFileNames.length);
        for (i = 0; i < arr.length; i++) {
            singleCanceledFileNames[i] = arr[i].trim();
            CancelOneFileUpload(arr[i].trim());
        }
    }

    var activeUploaderDiv = GetActiveUploaderContainer();
    var divLogsTab = jquery211("div[id^='divLogsTab']", jquery211(activeUploaderDiv));
    divLogsTab.text('');

    if (isdebugmode == '1')
        divLogsTab.append('<br/><b>Canceling logs:</b><br/>');

    jquery211("tr", jquery211(activeUploaderDiv)).each(() {


        if (jquery211(this).find('td:nth-child(3)').text() == cancelFileName) {
            jquery211('td:nth-child(3)', this).empty();
            var td3 = jquery211('<td/>').attr('rowNumber', rowNumber).append("<a id='btnUploadFiles' class='uploadFailedFilesBtn' type='button' title='Retry' onclick=\"   jquery211(this).css(\'display\', \'none\');  lastUploadsCommandGuids = []; lastUploadsCommandGuids.length = 0; singleCanceledFileNames = []; singleCanceledFileNames.length = 0;  RetryUploadToServer('" + jquery211('td:nth-child(3)', this).attr("rowNumber") + "'); \" ><img src='"+uploaderBaseUrl+"/images/RetryUpload.png' id='imgRetryUpload'/></a>").appendTo(tr1);
        }

    });

    for (k = 0; k < lastUploadsCommandGuids.length; k++) {
        if (typeof lastUploadsCommandGuids[k] != "undefined") {

            var split = lastUploadsCommandGuids[k].split("|");
            var guid = split[0];
            var fileName = split[1];           
            if (fileName == cancelFileName)
                CancelSingleCommandByGuid(guid, divLogsTab);

        }
    }
}

//FILE SELECTION OPERATIONS END

/// Windows C Foundation
// WCF methods call begin
CancelSingleCommandByGuid(commandGuid, divLogsTab) {
    var cancelInput = { Domain: 'ATI', TransactionGuid: commandGuid } ;

    if (isdebugmode == '1')
        divLogsTab.append('Canceling upload file/chunk command with guid  # ' + commandGuid + ' on server.<br/>');

    jquery211.ajax({

        url: wcfAtiServiceUrl + '/HttpCancelUpload',
        type: 'POST',
        dataType: 'json',
        contentType: "application/json",
        data: JSON.encode(cancelInput),
        success (data) {
            
        }
    });
}

GetUploadValidationMessage(examId, modality, examName, examType, messageContainer) {
    
    var input = { Modality: modality, ExamName: examName, ExamType: examType }

    jquery211.ajax({
        url: wcfAtiServiceUrl + '/HttpGetUploadValidationMessage',
        type: 'POST',
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        data: JSON.encode(input),
        async: false,
        success (data) {
            if (isdebugmode == '1')
                alert("INPUT:\r\n" + modality + ' ' + examType + "\r\n\r\n  OUTPUT:\r\n" + JSON.encode(data));
            if (data != null && data != '') {
                messageContainer.html('<br/><b style="color:red;"> ' + data + '</b><br/>');
            }
        },
        beforeSend (jqXHR, settings) {
            jqXHR.url = settings.url;
        },
        error(jqXHR, exception){
            if (jqXHR.status == 0) {
                showNotification('Connection Error', 'Please verify your network connection and reload the page.');
            } else {
                showNotification('Error', 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
            } 
        }
    });
}

SetCheckBoxData(examId, isChecked) {
    //if modality is MRAP or CTAP dicom files must be submitted. Else uncheck ready for submission check box 
    var resultPromise = jquery211.Deferred();
    var modality = jquery211('#uploaderDiv' + examId).attr("modality").toUpperCase();
    
    if (modality == "MRAP" || modality == "CTAP") {
      if (querySelector('#dicomFiles' + examId + examId).length == 0) {
        showNotification("Error in submission", "Please note: The exam must be submitted in DICOM format." +
            " Additional file types may be included in addition to the DICOM images if necessary.");

        jquery211("#cbxReadyForSubmission" + examId + "").removeAttr("checked");
        ShowAllDeleteButtons(examId);
        EnableAllUploadButtons(examId);
        resultPromise.reject();
        return resultPromise.promise();
      }
    }

    var slidingDivId = "slidingDiv" + examId;
    var slidingDiv = querySelector('#' + slidingDivId);

    var examName = slidingDiv.attribute['examName'];
    
    jquery211.ajax({
        url: wcfTriadAcreditServiceUrl + '/SetCheckBoxData/'+examId+'/'+isChecked+'/'+primaryparentID,
        type: 'GET',
        dataType: "text",
        cache: false,
        async: false,
        success (responseData) {
        	var xmlDoc = jquery211.parseXML(responseData);
        	var responseValue = jquery211(xmlDoc).text();

        	if (responseValue == false) {
                showNotification("Error in submission", "Could not set the exam "+ examName +" ready for submission");
                resultPromise.reject();
            }
            resultPromise.resolve(responseValue);
        },
        beforeSend (jqXHR, settings) {
            jqXHR.url = settings.url;
        },        
        error(jqXHR, exception){
            if (jqXHR.status == 0) {
                showNotification('Connection Error', 'Please verify your network connection and reload the page.');
            } else {
                showNotification('Error', 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
            } 
            resultPromise.reject();
        }
    });
    return resultPromise.promise();
}

//TODO: deleteFile(control)
DeleteDicomFileFromServer(control) {

    var level = '';
    if (control.attr('seriesinstanceuid').length <= 0) {
        level = 'Study';
    }
    else {
        level = 'Series';
    }

    if (confirm('This action will delete the ' + level  + ' from your testing package.Please confirm.')) {

        var folders = control.attr('path').split("\\");
        var deleteFileInput = { input: { DomainName: domain, StudyInstanceUID: control.attr('studyinstanceuid'), SeriesInstanceUID: control.attr('seriesinstanceuid'), PrimaryParentId: folders[0], SecondaryParentId: folders[1], TertaryParentId: folders[2], Level: '0' } }

        jquery211.ajax({
            url: wcfAtiServiceUrl + '/HttpDeleteDicomSubmissions',
            type: 'POST',
            dataType: 'json',
            contentType: "application/json",
            data: JSON.encode(deleteFileInput),
            success (data) {

                if (isdebugmode == '1')
                    alert("INPUT:\r\n" + JSON.encode(deleteFileInput) + "\r\n\r\n  OUTPUT:\r\n" + JSON.encode(data));


                if (data.DeleteDicomSubmissionsResult.ErrorString != null && data.DeleteDicomSubmissionsResult.ErrorString != '')
                    alert("Server Error: " + data.DeleteDicomSubmissionsResult.ErrorString + "\r\n Input for HttpDeleteDicomSubmissions was: " + JSON.encode(deleteFileInput));
                else {
                    var examId = jquery211(control).closest("[id^='slidingDiv']").attr("examId");
                    ReloadExam(examId);
                }
            },
            beforeSend (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error(jqXHR, exception){
                if (jqXHR.status == 0) {
                    showNotification('Connection Error', 'Please verify your network connection and reload the page.');
                } else {
                    showNotification('Error', 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
                } 
            }
        });
    }
}


//TODO: rename deleteFile(control)
//TODO: type of control?
DeleteNonDicomFileFromServer(control) {
    if (confirm('This action will delete the file from your testing package.Please confirm.')) {
        var folders = control.attributes['path'].split("\\");
        var deleteFileInput = { input: { DomainName: domain, FileID: control.attr('fileId'), PrimaryParentId: folders[0], SecondaryParentId: folders[1], TertaryParentId: folders[2] } }
        jquery211.ajax({
            url: wcfAtiServiceUrl + '/HttpDeleteNonDicomSubmission',
            type: 'POST',
            dataType: 'json',
            contentType: "application/json",
            data: JSON.encode(deleteFileInput),
            success (data) {

                if (isdebugmode == '1')
                    alert("INPUT:\r\n" + JSON.encode(deleteFileInput) + "\r\n\r\n  OUTPUT:\r\n" + JSON.encode(data));

                if (data.DeleteNonDicomSubmissionResult.ErrorString != null && data.DeleteNonDicomSubmissionResult.ErrorString != '')
                    alert("Server Error: " + data.DeleteNonDicomSubmissionResult.ErrorString + "\r\n Input for HttpDeleteNonDicomSubmission was: " + JSON.encode(deleteFileInput));
                else {
                    var examId = jquery211(control).closest("[id^='slidingDiv']").attr("examId");
                    ReloadExam(examId);
                }
            },
            beforeSend (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error(jqXHR, exception){
                if (jqXHR.status == 0) {
                    showNotification('Connection Error', 'Please verify your network connection and reload the page.');
                } else {
                    showNotification('Error', 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
                } 
            }
        });
    }
}

DownloadFileFromServer(control) {
    window.open(wcfAtiServiceUrl + '/HttpDownloadFileFromUrl/' + domain + '/false/' + control.attr('path'));
}

// Excel report - testing package summary report
DownloadTestingPackageExcel() {
    var examsIdList = '';
    var examNames = '';
    jquery211('div[id^="slidingDiv"]').each(
       (index) {
           var examid = jquery211(this).attr("examid");
           if (examsIdList == '')
               examsIdList += examid;
           else
               examsIdList += '-' + examid;

           var examName = jquery211("#lblExamReviewHeader" + examid).text();
           if (examNames == '')
               examNames += examName;
           else
               examNames += '-' + examName;
       });

    examNames = examNames.replace(/\//g, " ");
    examNames = encodeURIComponent(examNames);

    window.open(wcfAtiServiceUrl + '/HttpDownloadExcelPackageSummary/' + domain + '/' + modalityName + '/'+modalityNumber + '/' + primaryparentID + '/' + secondaryparentID + '/' + examsIdList + '/' + examNames + '/' + userName);
}


GetListOfAcreditExams() {
    var parendDiv = jquery211('#divListOfExamsInTestingPackage');
    parendDiv.empty();

    if (viewType == ViewType.upload)
        parendDiv.append('<div id="instructionsPanel" style="width:100%; text-align:right;" ><div id="validationMessageBlock" class="validationError"></div> <input type="button" class="btn btn-uploadfile" value="Instructions" onclick="showInstructions();">  <input type="button" class="btn btn-uploadfile" value="Supported File Types" onclick="showSupportedFileTypes()"></div>');
    else if (viewType == ViewType.static)
        parendDiv.append('<div class="divStaticViewHeader">Image Upload Summary</div>');

	var appealflag = 'false';
	if (isAppeal == '1')
		appealflag = 'true';
    jquery211.ajax({
        url: wcfTriadAcreditServiceUrl + '/GetExamsSummaryWithModalityAndExamType/' + acreditTestPackageID + '/' + appealflag,
        type: 'POST',
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success (data) {
            var listOfExams = data.HttpGetExamsSummaryWithModalityAndExamTypeResult.TestingpackageExamsSummarydata;

            for (i = 0; i < listOfExams.length; i++) {
            	var examId = listOfExams[i].ExamId;
                var examName = listOfExams[i].ExamName;
                var modalityAccreditationNumber = listOfExams[i].ModalityAccreditationNumber;
                var modalityAndExamType = "modality='" + listOfExams[i].ModalityName + "' modalityAccreditationNumber='" + modalityAccreditationNumber + "' examType='" + listOfExams[i].ExamType + "'";
                var newPath = primaryparentID + '\\' + secondaryparentID + '\\' + examId;
                var alreadyExist = false;
                jquery211('a', parendDiv).each(() {
                    if ((jquery211(this).attr("path")) == newPath) {
                        alreadyExist = true;
                    }
                });

                if (!alreadyExist) {
                    var slidingDivId = "slidingDiv" + examId;
                    var uploaderDivId = "uploaderDiv" + examId;
                    var examId = listOfExams[i].ExamId;
                    var readyForSubmission = listOfExams[i].UploadCheckboxStatus;

                    var uploadPart = '';
                    if (viewType == ViewType.upload) {
                        uploadPart = " <span id='divViewButtons" + examId + "' class='divViewButtons'>   <input id='btnUploader" + examId + "' type='button' value='View / Upload' class='btn btn-uploadfile'/><div class='divReadyForSubmission' id='divReadyForSubmission" + examId + "'>Ready For Submission<input type='checkbox' id='cbxReadyForSubmission" + examId + "' examId='" + examId + "' onchange='CheckboxOnChangeHandler(this, " + examId + ")' /></div> </span> ";
                    }
                        

                    parendDiv.append("<div class='divTestingPackage' style='overflow:hidden;margin-left:0%;width:inherit;'>\
                        <a id='mainLink" + examId + "' class='main-link' examid='" + examId + "' path='" + newPath +
                        "' ><label class='labelTestingPackageToggle'  id='lblExamReviewHeader" + examId + "'>" + examName +
                        "</label></a>" + uploadPart + "</div>");

                    var filesCountLabelsBlock = "<div id='filesCountLabelsBlock"+examId+"' class='filesCountLabels'><label id='dicomFilesCount' class='filesCountLabel'></label><label id='nonDicomFilesCount' class='filesCountLabel'></label></div>";
                    
                    if (viewType == ViewType.upload)
                    	jquery211(filesCountLabelsBlock).insertAfter("#divViewButtons"+examId);
                    else if (viewType == ViewType.static){
                    	jquery211(filesCountLabelsBlock).insertAfter("#mainLink"+examId);
                    	jquery211('#filesCountLabelsBlock'+examId).addClass('filesCountLabelsStaticView');
                    	jquery211("<input id='btnView" + examId + "' type='button' value='View' class='btn btn-uploadfile viewButtonForStatic'/>").insertAfter("#mainLink"+examId).click({examId: examId}, toogleFilesTree);


                    }

                    jquery211("#cbxReadyForSubmission"+examId,parendDiv).prop("checked", readyForSubmission);

                    // Server View - start
                    parendDiv.append("<div id='" + slidingDivId + "'  examid='" + examId + "'  examName='" + examName + "' " + modalityAndExamType + "></div>");
                    var slidingDiv = jquery211('#' + slidingDivId);
                    var aPackage = jquery211('#mainLink' + examId);

                    aPackage.click({examId: examId}, toogleFilesTree);

                    slidingDiv.hide();
                    aPackage.show();

                    GetExamDetails(aPackage, slidingDiv);
                    var numberOfFilesForUpload = 0;
                    var dicomFilesRowsCount = jquery211("tr[id^='trDicomImages']", slidingDiv).length;
                    var nondicomFilesRowsCount = jquery211("tr[id^='trNonDicomImages']", slidingDiv).length;
                    numberOfFilesForUpload = dicomFilesRowsCount + nondicomFilesRowsCount;
                    //Modified on 6-11-2015 to fix TRIAD-2574
                    if (numberOfFilesForUpload == 0) {
                        DisableAndUncheckReadyForSubmissionCheckBox(examId);
                    }
                    // Server View - end

                    if (viewType == ViewType.upload) {
                        //Uploader View - start
                        var webdirectoryPart = '';

                        if (isInputDirSupported())
                        	if (isAsperaOn) {
                                webdirectoryPart = "<div class='fileUpload2 btn btn-uploadfile' title=\"Please select Folder Upload to upload files from folder.\"><span id='imgSelectFolder" + examId + "' onclick='jquery211(\"#btnSelectFiles"+examId +"Folders\").trigger(\"click\");'>Folder Upload</span>\
                        		<input id='btnSelectFiles" + examId + "Folders' examid='" + examId + "' type='file' onclick='event.preventDefault(); setPrimarySecondaryIds(" + primaryparentID + ", " + secondaryparentID + ", " + examId + "); asperaWeb.showSelectFolderDialog({success:fileControls.uploadFiles}); ' class='upload2' multiple webkitdirectory='' directory='' style='visibility: hidden'/> </div>";
                            }
                            else
                            {
                                webdirectoryPart = "<div class='fileUpload2 btn btn-uploadfile' title=\"Please select Folder Upload to upload files from folder.\"><span id='imgSelectFolder" + examId + "' onclick='jquery211(\"#btnSelectFiles"+examId +"Folders\").trigger(\"click\");'>Folder Upload</span>\
                        		<input id='btnSelectFiles" + examId + "Folders' examid='" + examId + "' type='file' class='upload2' multiple webkitdirectory='' directory='' style='visibility: hidden'/> </div>";
                            }                            
                        else
                           webdirectoryPart = "<div class='fileUpload2 btn btn-uploadfile btn-disabled' title=\"Folder Upload option is only available with Chrome 11 & above.\" style='cursor: not-allowed' > <a><span id='imgSelectFolder" + examId + "'>Folder Upload</span></a></div>";


                        var viewcontentImageClass = '';

                        if (numberOfFilesForUpload == 0)
                            viewcontentImageClass = "view-content-grey-icon4";
                        else
                            viewcontentImageClass = "view-content-icon4";

                         if (isAsperaOn) {
                           var uploaderDiv = jquery211("<div id='" + uploaderDivId + "'  examid='" + examId + "'  examName='" + examName + "' " + modalityAndExamType + " style='padding-left:10px'>\
                            \
                            \
                            <table id='tblStatus" + examId + "' class='tblErrorStatus' style='display:none' ><tr><td style='width:30px;'><span  id='imgStatus" + examId + "' class='icon fa fa-times-circle'></span></td>\
                            <td style='padding-bottom:5px;'  id='tdStatusMessage" + examId + "' >Error</td><td class='tdClose'>\
                            <a onclick='jquery211(\"#tblStatus" + examId + "\").attr(\"style\", \"display:none\");  '>\
                            <span id='imgClose" + examId + "' class='fa  fa-times' alt='Close' title='Close'></span></a></td></tr></table>\
                            \
                            \
	                        <div class='fileUpload2 btn btn-uploadfile'  title=\"Please select File Upload to upload files.\"><span onclick='jquery211(\"#btnSelectFiles"+ examId +"\").trigger(\"click\");'>File Upload</span>\
                            <input id='btnSelectFiles" + examId + "' examid='" + examId + "' type='file' onclick='event.preventDefault();setPrimarySecondaryIds(" + primaryparentID + ", " + secondaryparentID + ", " + examId + "); asperaWeb.showSelectFileDialog({success:fileControls.uploadFiles});' class='upload2' multiple style='visibility: hidden'/> </div>" + webdirectoryPart + "\
	                         \
                              <div id='divFilesForUpload" + examId + "' style='padding-bottom:10px;'></div>\
                              <div id='divLogsTab" + i + "'></div>\
                            \
                            </div>");
                            slidingDiv.prepend(uploaderDiv);
                        }
                        else {
                            var uploaderDiv = jquery211("<div id='" + uploaderDivId + "'  examid='" + examId + "'  examName='" + examName + "' " + modalityAndExamType + " style='padding-left:10px'>\
	                        \
	                        \
	                        <table id='tblStatus" + examId + "' class='tblErrorStatus error-message' style='display:none' ><tr><td style='width:30px;' class='error-message'><span  id='imgStatus" + examId + "' class='icon fa fa-times-circle'></span></td>\
                            <td style='padding-bottom:5px;'  id='tdStatusMessage" + examId + "' class='error-message'>Error</td><td class='tdClose error-message'>\
                            <a onclick='jquery211(\"#tblStatus" + examId + "\").attr(\"style\", \"display:none\");  '>\
                            <span id='imgClose" + examId + "' class='fa  fa-times' alt='Close' title='Close'></span></a></td></tr></table>\
	                        \
	                        \
	                        <div class='fileUpload2 btn btn-uploadfile'  title=\"Please select File Upload to upload files.\"><span onclick='jquery211(\"#btnSelectFiles"+ examId +"\").trigger(\"click\");'>File Upload</span>\
	                        <input id='btnSelectFiles" + examId + "' examid='" + examId + "' type='file' class='upload2' multiple style='visibility: hidden'/> </div>" + webdirectoryPart + "\
	                        \
	                          <div id='divFilesForUpload" + examId + "' style='padding-bottom:10px;'></div>\
	                          <div id='divLogsTab" + i + "'></div>\
	                        \
	                        </div>");

	                        slidingDiv.prepend(uploaderDiv);
                        }                       

                        var btnUploader = jquery211('#btnUploader' + examId);
                        btnUploader.click({examId: examId}, toogleFilesTree);

                        //Uploader View - end
                    }

                     if (readyForSubmission){
                        HideExamTab(examId); 
                        HideAllDeleteButtons( examId);
                        DisableAllUploadButtons(examId);
                    }
                }
            }

            if (viewType == ViewType.upload)
            {
            	if (!isAsperaOn) {
	                jquery211("input[id^='btnSelectFiles']").change((event) {
	                    var examid = jquery211(this).attr("examid");
	                    var attrOnclick = jquery211(this).attr('onclick');
						// For some browsers, `attr` is undefined; for others,
						// `attr` is false.  Check for both.
						if (typeof attrOnclick !== typeof undefined && attrOnclick !== false) {
						    return;
						}
	                    setTimeout(() { AddInputFilesToQueue(event, examid) }, 1000);
                	});
                }

                //Aspera plugin
                if (isAsperaOn) {

                    jquery211.getScript(installerPath + "asperaweb-4.js", (data, textStatus, jqxhr) { checkInstallersLoaded(); });
                    jquery211.getScript(installerPath + "connectinstaller-4.js", (data, textStatus, jqxhr) { checkInstallersLoaded(); });
                }
                //parendDiv.append("<br/><div class='divAttestestation' id='divAttestestation' style='color:gray'>I attest that I have uploaded all the files required for above exams. <input type='checkbox' disabled='true' id='cbxAttestestation' onchange='if (this.checked) HideReadyForSubmissionCheckboxes(); else ShowReadyForSubmissionCheckboxes();' /></div><br/><br/>");

                
            }
            else if (viewType == ViewType.static)
                parendDiv.append('<div class="divStaticViewHeader" style="margin-top:5px; text-align:right;">   <input type="button" class="btn btn-staticView" value="Print" onclick="printDiv(\'divListOfExamsInTestingPackage\')">  <input type="button" class="btn btn-staticView" value="Export" onclick="DownloadTestingPackageExcel();">   </div>');

            var jquery211loading = jquery211('#loadingDiv').hide();

        },
        beforeSend (jqXHR, settings) {
            jqXHR.url = settings.url;
        },
        error(jqXHR, exception){
            if (jqXHR.status == 0) {
                showNotification('Connection Error', 'Please verify your network connection and reload the page.');
            } else {
                showNotification('Error', 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
            } 
        }
    });

};

CheckboxOnChangeHandler(checkbox, examId){
	if (checkbox.checked && jquery211("#mainLink" + examId).attr("loaded") != 1)   {
		GetExamDetails(jquery211("#mainLink" + examId), jquery211("#slidingDiv" + examId));  
	} 

	if (checkbox.checked){
		jquery211.when(SetCheckBoxData(examId, true)).then(function(response){
			HideExamTab( examId ); 
			HideAllDeleteButtons(examId); 
			DisableAllUploadButtons(examId); 
			EnableUploadForExams(); 
			UpdateAttestationUI();
		}).fail((){
			jquery211("#cbxReadyForSubmission" + examId + "").removeAttr("checked");
		});
	}
	else{
		jquery211.when(SetCheckBoxData(examId, false)).then(function(response){
		 	ShowExamTab(examId); 
			ShowAllDeleteButtons(examId);
			EnableAllUploadButtons(examId);
			UpdateAttestationUI();
		}).fail(function(){
			jquery211("#cbxReadyForSubmission" + examId + "").prop("checked", true);
		});
	}	
}

GetExamDetails(control, parendDiv) {
    var relPath = "";
    if (control.attr("loaded") == 1)
        return;
    relPath = control.attr('path');
    var examid = 0;
    if (control != null){
        examid = control.attr("examid");
        DisableReadyForSubmissionCheckBox(examid);
    }

    var folders = relPath.split("\\");
    var input = { input: { DomainName: domain, primaryParentId: folders[0], secondaryParentId: folders[1], tertaryParentId: folders[2],  UserName: userName } }

    jquery211.ajax({
        url: wcfAtiServiceUrl + '/HttpGetSubmissionDetails',
        type: 'POST',
        dataType: 'json',
        contentType: "application/json",
        data: JSON.encode(input),
        async: false,
        success (data) {

    var uploaderDiv = jquery211("#uploaderDiv"+ examid, parendDiv).clone();
            parendDiv.empty();
            parendDiv.prepend(uploaderDiv);

            parentDiv.querySelector("input[id^='btnSelectFiles"+examid+"']").change((event) {
                    var examId = jquery211(this).attr("examid");
                    setTimeout(() { AddInputFilesToQueue(event, examId) }, 1000);
                });

            var deleteImageHtml = '';
            var jquery211loading = jquery211('#loadingDiv').hide();

            if (isdebugmode == '1') alert(JSON.encode(data));

            if (data.GetSubmissionDetailsResult.ErrorString != null && data.GetSubmissionDetailsResult.ErrorString != '')
                alert("Server Error: " + data.GetSubmissionDetailsResult.ErrorString);

            var level = 1;
            
            var numberOfDicomFiles = 0;
            jquery211('Series', data.GetSubmissionDetailsResult.XMLInfo).each(function(){
            	numberOfDicomFiles = numberOfDicomFiles + + jquery211(this).attr("numberoffiles");
            });

            jquery211("label#dicomFilesCount", jquery211("#mainLink"+examid).parent()).empty().append("<div style='display:inline-block;width:120px;text-align:left;'>DICOM Files: "+ numberOfDicomFiles + "</div>");

            var numberOfNonDicomFiles = 0;
            jquery211('NonDicom File', data.GetSubmissionDetailsResult.XMLInfo).each(function(){
            	numberOfNonDicomFiles++;
            });

            jquery211("label#nonDicomFilesCount", jquery211("#mainLink"+examid).parent()).empty().append("<div style='display:inline-block;width:140px;text-align:left;'>Non-DICOM Files: "+ numberOfNonDicomFiles + "</div>");



            if (jquery211('Study', data.GetSubmissionDetailsResult.XMLInfo).length > 0) {

                
                var tbl3 = jquery211('<table/>').attr('cellpadding', '0').attr('cellspacing', '0').css("margin-left", '2%').css("width", '100%').appendTo(parendDiv);

                var wasHeaderAddedDicom = false;
                var wasHeaderAddedNonDicom = false;
                var tblDicom;
                var tblNonDicom;
                var k = 0;

                jquery211('Study', data.GetSubmissionDetailsResult.XMLInfo).each(() {
                    
                    if (examid != 0){
                        EnableReadyForSubmissionCheckBox(examid);
                    }
                    k++;
                    var split = jquery211(this).attr("Name").split(".");
                    var extension = "";
                    if (split.length > 1)
                        extension = split[split.length - 1].toLowerCase();

                    var studyName = jquery211(this).attr("name");
 					var studyInstanceUid = jquery211(this).attr("instanceuid");                    
                    var studyid = jquery211(this).attr("id");
                    var studydate = jquery211(this).attr("date");
                    var studytime = jquery211(this).attr("time");
                    var studydescription = jquery211(this).attr("description");
                    var studyaccessionnumber = jquery211(this).attr("accessionnumber");
                    var rsstudyName = RemoveSymbols(studyInstanceUid) + studydate;

                    {

                        if (!wasHeaderAddedDicom) {

                            if (viewType == ViewType.upload)
                                deleteImageHtml = "<th width='75px' style='text-align:center;'>Delete</th>";

                            parendDiv.append("<table class='dicomImageFileTable' align='left' cellpadding='0' cellspacing='0'  id='dicomFiles" + GetLastFolder(control.attr('path')) + examid + "'>" +
                               	"<tr><th width='120px'><a class='collapse' id='aDicomFileTblToggle" + GetLastFolder(control.attr('path')) + examid + rsstudyName + "'></a>" +
                                "<label class='dicomColumnHeader'>DICOM Files</label></th><th>Study Description</th><th width='150px'>Patient Name</th><th width='100px'>Study Date</th><th width='100px' style='text-align:center;'>View Images</th>" + deleteImageHtml + "</tr>" +
                                "</table>");

                            var aPackageMain = jquery211('#aDicomFileTblToggle' + GetLastFolder(control.attr('path')) + examid + rsstudyName);

                            aPackageMain.click(() {
                                if (aPackageMain.hasClass('collapse'))
                                { aPackageMain.addClass('expand'); aPackageMain.removeClass('collapse'); jquery211("[id*=trDicomImages" + GetLastFolder(control.attr('path')) + examid + "]").css('display', 'none'); }
                                else
                                { aPackageMain.addClass('collapse'); aPackageMain.removeClass('expand'); jquery211("[id*=trDicomImages" + GetLastFolder(control.attr('path')) + examid + "]").css('display', ''); }
                            });

                            tblDicom = jquery211('#dicomFiles' + GetLastFolder(control.attr('path')) + examid);
                            wasHeaderAddedDicom = true;
                        }


                        var tbl4tr1 = jquery211('<tr/>').appendTo(tblDicom);
                        tbl4tr1.attr("id", "trDicomImages" + GetLastFolder(control.attr('path')) + examid + rsstudyName).addClass('dcmStudyRow');

                        var tdFile1 = jquery211('<td/>').css("background", "white").css("width", "120px").appendTo(tbl4tr1);
                        var tdFile2 = jquery211('<td/>').appendTo(tbl4tr1);
                        tdFile2.append("<a class='collapse' id='aSeriesImages" + GetLastFolder(control.attr('path')) + examid + rsstudyName + "'></a>&nbsp;" +
                               jquery211(this).attr("description"));

                        var aPackage = jquery211('#aSeriesImages' + GetLastFolder(control.attr('path')) + examid + rsstudyName);

                        aPackage.click(() {
                            if (aPackage.hasClass('collapse'))
                            { aPackage.addClass('expand'); aPackage.removeClass('collapse'); jquery211("[id*=tblDicomSeries" + GetLastFolder(control.attr('path')) + examid + rsstudyName + "]").css('display', 'none'); }
                            else
                            { aPackage.addClass('collapse'); aPackage.removeClass('expand'); jquery211("[id*=tblDicomSeries" + GetLastFolder(control.attr('path')) + examid + rsstudyName + "]").css('display', ''); }
                        });

                        var tdFile3 = jquery211('<td/>').text(jquery211(this).attr("name")).css("width", "150px").appendTo(tbl4tr1);
                        var tdFile4 = jquery211('<td/>').text(jquery211(this).attr("date")).css("width", "100px").appendTo(tbl4tr1);
                        var tdFile5 = jquery211('<td/>').css("width", "100px").css("text-align", "center").appendTo(tbl4tr1);
                      
                        tdFile5.append("<input type='button' class='btn btn-viewfile' value='View' onclick='LaunchClaronViewer(\"" + jquery211(this).attr("studyurl") + "\");' >");

                        var seriesinstanceuid = '';
                        if (jquery211('Series', jquery211(this)).length > 0)
                            seriesinstanceuid = jquery211('Series', jquery211(this)).first().attr("instanceuid");

                        var studyinstanceuid = jquery211(this).attr("instanceuid");
                        if (viewType == ViewType.upload) {
                            var tdFile6 = jquery211('<td/>').css("width", "75px").css("text-align", "center").css("padding-right", "10px").appendTo(tbl4tr1);
                            tdFile6.append(" <a studyinstanceuid='" + jquery211(this).attr("instanceuid") + "' seriesinstanceuid=''  onclick='DeleteDicomFileFromServer(jquery211(this));' path='" + relPath + "'><img class='imgToggle' src='"+uploaderBaseUrl+"/images/delete.png'></a>");
                        }

                        var tbl4tr1 = jquery211('<tr/>').appendTo(tblDicom);
                        tbl4tr1.attr("id", "trDicomImages" + GetLastFolder(control.attr('path')) + examid + rsstudyName).addClass('dcmSeriesRow');

                        var td1 = jquery211('<td/>').css("background", "white").attr("colspan", "6").appendTo(tbl4tr1);


                        if (jquery211('Series', jquery211(this)).length > 0) {

                            if (viewType == ViewType.upload)
                                deleteImageHtml = "<th width='75px' style='text-align:center;'>Delete</th>";
                            else
                                deleteImageHtml = "";

                            td1.append("<table width='100%' class='seriesTable' cellpadding='0' cellspacing='0' id='tblDicomSeries" + GetLastFolder(control.attr('path')) + examid + rsstudyName + "'>" +
                                                               "<tr><th class='th-empty' style='width:120px;background:white;'></th><th style='width:10px;background:white;'></th><th>Series Description</th><th width='150px'>Modality</th><th width='100px'>Series Date</th><th width='100px' style='text-align:center;'>No of Files</th>" + deleteImageHtml + "</tr>" +
                                                               "</table>");
                            var tblSeries = jquery211('#tblDicomSeries' + GetLastFolder(control.attr('path')) + examid + rsstudyName);

                            jquery211('Series', jquery211(this)).each(() {

                                var tbl4tr1 = jquery211('<tr/>').appendTo(tblSeries);
                                tbl4tr1.attr("id", "trSeriesImages" + GetLastFolder(control.attr('path')) + examid);

                                var tdFile1 = jquery211('<td/>').css("background", "white").css("width", "120px").appendTo(tbl4tr1);
                                var tdFile2 = jquery211('<td/>').css("width", "10px").appendTo(tbl4tr1);
                                var tdFile3 = jquery211('<td/>').text(jquery211(this).attr("description")).appendTo(tbl4tr1);
                                var tdFile4 = jquery211('<td/>').text(jquery211(this).attr("name")).css("width", "150px").appendTo(tbl4tr1);
                                var tdFile5 = jquery211('<td/>').text(jquery211(this).attr("date")).css("width", "100px").appendTo(tbl4tr1);
                                var tdFile6 = jquery211('<td/>').text(jquery211(this).attr("numberoffiles")).css("width", "100px").css("text-align", "center").appendTo(tbl4tr1);                                

      
                                if (viewType == ViewType.upload) {
                                    var tdFile7 = jquery211('<td/>').css("width", "75px").css("text-align", "center").css("padding-right", "10px").appendTo(tbl4tr1);
                                    tdFile7.append(" <a studyinstanceuid='" + studyinstanceuid + "' seriesinstanceuid='" + jquery211(this).attr("instanceuid") + "'  onclick='DeleteDicomFileFromServer(jquery211(this));' path='" + relPath + "'><img class='imgToggle' src='"+uploaderBaseUrl+"/images/delete.png'></a>");
                                }
                            });
                        }

                    }

                })
            }


            if (jquery211('NonDicom', data.GetSubmissionDetailsResult.XMLInfo).length > 0) {

                var k = 0;
                jquery211('File', data.GetSubmissionDetailsResult.XMLInfo).each(() {
                    if (examid != 0){
                        EnableReadyForSubmissionCheckBox(examid);
                    }
                    k++;
                    {
                        if (!wasHeaderAddedNonDicom) {
                            if (viewType == ViewType.upload)
                                deleteImageHtml = "<th width='75px' style='text-align:center;'>Delete</th>";

                            parendDiv.append("<table class='dicomImageFileTable' cellpadding='0' cellspacing='0'  id='nonDicomFiles" + GetLastFolder(control.attr('path')) + examid + "'>" +
                                "<tr><th width='120px'><a class='collapse' id='aNonDicomImages" + GetLastFolder(control.attr('path')) + examid + "'></a>" +
                                "<label class='nonDicomColumnHeader'>Non-DICOM Files</label></th><th>File Name</th><th width='150px'>File Type</th><th width='100px'>File Size</th><th width='100px' style='text-align:center;'>View Files</th>" + deleteImageHtml + "</tr>" +
                                "</table>");

                            var aPackage = jquery211('#aNonDicomImages' + GetLastFolder(control.attr('path')) + examid);
                           
                            aPackage.click(() {
                                if (aPackage.hasClass('collapse'))
                                { aPackage.addClass('expand'); aPackage.removeClass('collapse'); jquery211("[id*=trNonDicomImages" + GetLastFolder(control.attr('path')) + examid + "]").css('display', 'none'); }
                                else
                                { aPackage.addClass('collapse'); aPackage.removeClass('expand'); jquery211("[id*=trNonDicomImages" + GetLastFolder(control.attr('path')) + examid + "]").css('display', ''); }
                            });

                            tblNonDicom = jquery211('#nonDicomFiles' + GetLastFolder(control.attr('path')) + examid);
                            wasHeaderAddedNonDicom = true;
                        }

                        var tbl4tr1 = jquery211('<tr/>').appendTo(tblNonDicom);

                        tbl4tr1.attr("id", "trNonDicomImages" + GetLastFolder(control.attr('path')) + examid).addClass('nonDicomRow');

                        var tbl4tdFile1 = jquery211('<td/>').css("background", "white").css("width", "120px").appendTo(tbl4tr1);
                        var tdFile1 = jquery211('<td/>').text(jquery211(this).attr("Name").split(".")[0]).appendTo(tbl4tr1);
                        var tdFile2 = jquery211('<td/>').text(GetFileType2(jquery211(this).attr("Name"))).css("width", "150px").appendTo(tbl4tr1);


                        var tdFile3 = jquery211('<td/>').css("width", "100px").text(jquery211(this).attr("Size")).appendTo(tbl4tr1);
                        var tdFile4 = jquery211('<td/>').css("width", "100px").css("text-align", "center").appendTo(tbl4tr1);
                        
                        tdFile4.append(" <input type='button' id='" + GetFileName(jquery211(this).attr("Name")) + examid + "'   value='View' class='btn btn-viewfile' path='"+ relPath + "\\" + jquery211(this).attr("Name") + "'/>");
                        var btnViewImages = jquery211('#' + GetFileName(jquery211(this).attr("Name")) + examid + '');
                        btnViewImages.attr("onclick", "DownloadFileFromServer(jquery211(this));");
                        btnViewImages.attr("download", jquery211(this).attr("Name"));

                        if (viewType == ViewType.upload) {
                            var tdFile5 = jquery211('<td/>').css("width", "75px").css("text-align", "center").css("padding-right", "10px").appendTo(tbl4tr1);
                            tdFile5.append(" <a  onclick='DeleteNonDicomFileFromServer(jquery211(this));' fileId='" + jquery211(this).attr("id") + "' path='" + relPath + "\\" + jquery211(this).attr("Name") + "'><img class='imgToggle' src='"+uploaderBaseUrl+"/images/delete.png'></a>");
                        }
                    }

                })
            }
        
            if (jquery211("#cbxReadyForSubmission" + examid + "").prop("checked"))
                HideAllDeleteButtons(examid);
            else
                ShowAllDeleteButtons(examid);
        },
        beforeSend (jqXHR, settings) {
            jqXHR.url = settings.url;
        },
        error(jqXHR, exception){
            if (jqXHR.status == 0) {
                DisplayErrorLogInExam(examId, 'Connection Error. Please verify your network connection and reload the page.');
            } else {
                DisplayErrorLogInExam(examId, 'The server returned error ' + jqXHR.responseText + '. Please try agin later.');
            }  
        }
    });

    if (control != null)
        control.attr("loaded", 1);
}

// WCF methods call end


ServiceFailed(result) {
  showNotification('Service call failed', 'url: <span style="color:red">' + result.url + '</span><br/>' + JSON.encode(result));
  var jquery211loading = jquery211('#loadingDiv').hide();
}

IsItUploadSummaryReloadCycle() {
  var isItUploadSummaryReloadCycle = window.sessionStorage['Is_It_Upload_Summary_Reload_Cycle'];
  if (isItUploadSummaryReloadCycle == null) return false;
  window.sessionStorage.remove('Is_It_Upload_Summary_Reload_Cycle');
  return true;
}


//TODO: where is readCookie defined
showInstructionsOnStartup() {
  //createCookie('HideAtiInstructions', '0', '365');
  if (readCookie('HideAtiInstructions') == 1 ||
      viewType == ViewType.static ||
      viewType == ViewType.review ||
      IsItUploadSummaryReloadCycle()) {
    // No display of instructions
  } else {
    querySelector("#popupHelp").dialog({
                                   resizable: false,
                                   width: 450,
                                   modal: true,
    dialogClass: "main-dialog-class",
    buttons: [{
    text: "Do not show this again",
    click: () {
    createCookie('HideAtiInstructions', '1', '365');
    jquery211(this).dialog("close");
    return true;
    },
    class: "popupBtn"
    },
                                   {
                                   text: "Close",
                                   click: () {
                                   jquery211(this).dialog("close");
                                   return true;
                                   },
                                   class: "popupBtn"
                                   }]
                                   });
  }
}



showInstructions() {
  jquery211("#popupHelp").dialog({
                                 resizable: false,
                                 width: 450,
                                 modal: true,
  dialogClass: "main-dialog-class",
  buttons: [
                                 {
                                 text: "Close",
                                 click () {
                                 jquery211(this).dialog("close"); return true;
                                 },
                                 class: "popupBtn"
                                 }]
                                 });
}

//TODO: Why not in .html file?
//CTAP = CT Accreditation Program
const String supportedTypes = """
  <table class='supportedFilesTable' cellspacing='0' cellpadding='0'>
    <tr><th width='100px'>Modality Name</th><th width='250px'>Image File Format</th><th width='250px'>Movie File Format</th></tr>
    <tr><td>BMRAP Clinical</td><td>DICOM</td><td></td></tr>
    <tr><td>CTAP Clinical</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td>MOV, MPG4, AVI, MPG, MPEG, MP4, WMV</td></tr>
    <tr><td>MRAP Clinical</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td>MOV, MPG4, AVI, MPG, MPEG, MP4, WMV</td></tr>
    <tr><td>NMAP Clinical</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td></td></tr>
    <tr><td>PETAP Clinical</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td></td></tr>
    <tr><td>UAP Clinical</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td></td></tr>
    <tr><td>MAP Clinical</td><td>DICOM</td><td></td></tr>
    <tr><td>CTAP Phantom</td><td>DICOM</td><td></td></tr>
    <tr><td>MRAP Phantom</td><td>DICOM</td><td></td></tr>
    <tr><td>NMAP Phantom</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td></td></tr>
    <tr><td>PETAP Phantom</td><td>DICOM, JPEG, JPG, PNG, GIF, TIFF, BMP</td><td></td></tr>
    <tr><td>MAP Phantom</td><td>DICOM</td><td></td></tr>
  </table>""";

showSupportedFileTypes() {
  showNotification('Supported File Types', supportedTypes);
}

showNotification(title, message) {
  querySelector("#popupNotification").html(message);

  querySelector("#popupNotification").dialog(
  {resizable: false,
  width:450,
  modal: true,
  dialogClass: "main-dialog-class",

  buttons: [ {
  text: "Ok",
  click:
  () { jquery211(this).dialog("close");
       return true;
     },
  class: "popupBtn"
  }
  ]
  });

  querySelector('#popupNotification').dialog('option', 'title', title);
}

setChildWindowsCloseEvent(value) {
  document.cookie = "cookie-close-windows=" + value + "; path=/";
}


updateUiForUploader(examId) {
  var oldActiveExamId = 0;
  var activeUploaderDiv = GetActiveUploaderContainer();
  if (activeUploaderDiv != null) oldActiveExamId = activeUploaderDiv.attr('examid');
  PrepareForUpload(oldActiveExamId, examId);
  //  SetupUIForUploadButtons(examId);
}

toogleFilesTree(event) {
  if (IsAnyUploadInProgress()) {
    event.preventDefault();
    return;
  }
  var examId = event.data.examId;
  var aPackage = jquery211('#mainLink' + examId);
  var slidingDiv = jquery211('#slidingDiv' + examId);
  GetExamDetails(aPackage, slidingDiv);
  var numberOfFilesForUpload = 0;
  var dicomFilesRowsCount = jquery211("tr[id^='trDicomImages']", slidingDiv).length;
  var nondicomFilesRowsCount = jquery211("tr[id^='trNonDicomImages']", slidingDiv).length;
  numberOfFilesForUpload = dicomFilesRowsCount + nondicomFilesRowsCount;
  updateUiForUploader(examId);

  if (numberOfFilesForUpload == 0) {
    DisableAndUncheckReadyForSubmissionCheckBox(examId);
  } else {
    EnableReadyForSubmissionCheckBox(examId);
  }

  // if (slidingDiv.is(':visible')) {
  if (slidingDiv.is (':visible')
)
{
CloseReviewersAndUploaders();
slidingDiv.slideUp();
HideExamMessage(examId);
HideUploadResultTable(examId);
}
else
{
CloseReviewersAndUploaders();
slidingDiv.slideDown();
}
if
(
jquery211
(
'
#cbxReadyForSubmission
'
+
examId
)
.
prop
(
'
checked'))
{
HideAllDeleteButtons(examId);
}
else
{
ShowAllDeleteButtons(examId );
}

getNumberOfFileSelectionInUpload() {
  for (int i = 0, len = fileSelectionStatusesInCurrentExam.length; i < len; i++) {
    if (fileSelectionStatusesInCurrentExam[i].Status == in_queue_status &&
        (fileSelectionStatusesInCurrentExam[i].WithRetry == null ||
            !fileSelectionStatusesInCurrentExam[i].WithRetry)) return i;
  }
  return -1;
}

formatBytes(bytes, decimals) {
  if (bytes == 0) return '0 Byte';
  var k = 1000;
  var dm = decimals + 1 || 3;
  var sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  var i = Math.floor(Math.log(bytes) / Math.log(k));
  return (bytes / Math.pow(k, i)).toPrecision(dm) + ' ' + sizes[i];
}

//TODO replace with Path function
getExtension(fileName, withDot) {
  int indexOfDot = fileName.lastIndexOf('.');
  String ext = "none";
  int posShift = 0;
  if (!withDot) posShift = 1;
  if (indexOfDot >= 0) ext = fileName.substr(indexOfDot + posShift);
  return ext;
}

arrayOfObjectsIndexOf(myArray, searchTerm, property) {
  for (int i = 0, len = myArray.length; i < len; i++) {
    if (myArray[i][property] == searchTerm) return i;
  }
  return -1;
}

__doPostBack(eventTarget, eventArgument) {
  if (!theForm.onsubmit || (theForm.onsubmit() != false)) {
    theForm.__EVENTTARGET.value = eventTarget;
    theForm.__EVENTARGUMENT.value = eventArgument;
    theForm.submit();
  }
}



//ASPERA FUNCTIONS END


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
      addQueryParam('modalityNumber', modalityNumber) + addQueryParam('auditTrailIsOn', auditTrailIsOn);
  return result;
}
