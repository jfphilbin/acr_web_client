library review_validator;

import "dart:convert";

enum FileType {dicom, nonDicom, supportDocs}

class Info {
  FileType fileType;
  bool isExamReviewInErrorState = false;

  bool get nonDicomType => fileType != FileType.dicom;
}

class ReviewValidator {
  //TODO? var storage = sessionStorage;
  var storage;
  String dicomType = "Dicom";
  String nonDicomType = "NonDicom";
  String supportDocsType = "SupportDocs";
  String isExamReviewInErrorState = "IsExamReviewInErrorState";
  List<String> modalitiesWithValidationOfSupportingDocs = ["CTAP", "NMAP", "PETAP", "US", "UAP"];
  String key = null;
  bool supportDocValidation = false;

  var primaryParentId;
  var secondaryParentId;
  var examId;
  var examName;
  var userName;
  var areThereDicomFiles;
  var areThereNonDicomFiles;
  var areThereSupportFiles;


  ReviewValidator(
      primaryParentId, secondaryParentId, examId, examName, userName, areThereDicomFiles, areThereNonDicomFiles, areThereSupportFiles) {
    supportDocsMustBeReviewed(examName.trim());
    key = getKey(primaryParentId, secondaryParentId, examId, userName);
    var reviewedFilesInfo = storage.getItem(key);
    if (reviewedFilesInfo == null) {
      var info = {};
      info[dicomType] = !areThereDicomFiles;
      info[nonDicomType] = !areThereNonDicomFiles;
      info[supportDocsType] = !areThereSupportFiles;
      info[isExamReviewInErrorState] = false;
      storage.setItem(key, JSON.encode(info));
    }
  }

  getReviewedFilesInfo(type) {
    if (type == supportDocsType && !supportDocValidation) return true;
    var reviewedFilesInfo = storage.getItem(key);
    if (reviewedFilesInfo == null) return false;
    return JSON.decode(reviewedFilesInfo)[type];
  }

  getKey(primaryParentId, secondaryParentId, examId, userName) {
    return userName.trim() + ":" + primaryParentId.trim() + "/" + secondaryParentId.trim() + "/" + examId.trim();
  }

  supportDocsMustBeReviewed(examName) {
    supportDocValidation = modalitiesWithValidationOfSupportingDocs.indexOf(examName) > -1;
  }

  saveReviewedFilesInfo(typeOfFiles, value) {
    var reviewedFilesInfo = storage.getItem(key);
    var info = JSON.decode(reviewedFilesInfo);
    info[typeOfFiles] = value;
    storage.setItem(key, JSON.encode(info));
  }

  setExamReviewErrorState(value) {
    var reviewedFilesInfo = storage.getItem(key);
    var info = JSON.decode(reviewedFilesInfo);
    info[isExamReviewInErrorState] = value;
    storage.setItem(key, JSON.encode(info));
  }

  checkValidatorState() {
    if (key == null) {
      console.error("'reviewValidator' must be initialized  before usage");
      return;
    }
    if (key.indexOf("null") >= 0 || key.indexOf("undefined") >= 0) {
      console.error("Some initializing parameters in 'reviewValidator' were incorrect. Key: " + key);
      return;
    }
  }

  markDicomFilesAsReviewed() {
    checkValidatorState();
    saveReviewedFilesInfo(dicomType, true);
  }

  markNonDicomFilesAsReviewed() {
    checkValidatorState();
    saveReviewedFilesInfo(nonDicomType, true);
  }

  markSupportFilesAsReviewed() {
    checkValidatorState();
    saveReviewedFilesInfo(supportDocsType, true);
  }

  areAllRequiredFilesReviewed() {
    checkValidatorState();
    return getReviewedFilesInfo(dicomType) && getReviewedFilesInfo(nonDicomType) && getReviewedFilesInfo(supportDocsType);
  }

  areDicomFilesReviewed() {
    checkValidatorState();
    return getReviewedFilesInfo(dicomType);
  }

  areNonDicomFilesReviewed() {
    checkValidatorState();
    return getReviewedFilesInfo(nonDicomType);
  }

  areSupportFilesReviewed() {
    checkValidatorState();
    return getReviewedFilesInfo(supportDocsType);
  }
/* TODO
        isExamReviewInErrorState() {
            checkValidatorState();
            var reviewedFilesInfo = storage.getItem(key);
           //? return JSON.decode(reviewedFilesInfo)[isExamReviewInErrorState];
        }

        setExamReviewErrorState(value){
            checkValidatorState();
            //??setExamReviewErrorState(value);
        }
    */
}
