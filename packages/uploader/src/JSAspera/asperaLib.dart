//APPLICATION VARIABLES BEGIN

var wcfAtiServiceUrl =  TriadUrl.get() + 'TriadInterimWebService.svc';


var domain;
var primaryparentID;
var secondaryparentID;
var paramExamID;
var currentExamId;

var uploadFolderPath;  
var in_queue_status = 'In Queue';
var completed_status = 'Completed';
var failed_to_upload_status = 'Failed To Upload';
var fileControls = { "files": [] };
var fileNameList = [];
var hasSaved = false;
var fileListForRetry = null;

fileControls.handleTransferEvents(event, transfersJsonObj) {
    switch (event) {
        case 'transfer':
            for (var i = 0; i < transfersJsonObj.result_count; i++) {
                var tranfer = transfersJsonObj.transfers[i];

                ShowAsperaStatus(in_queue_status, Math.floor(tranfer.percentage * 100), tranfer.title);

                var info = tranfer.current_file;
                if (tranfer.status === "failed") {
                    info = tranfer.title + ": " + tranfer.error_desc;
                    ShowAsperaStatus(failed_to_upload_status, "1", tranfer.title);
                    //Aspera transfer failed, reverting to wcf
                    isAsperaOn = false;
                } else if (tranfer.status === "completed" && !hasSaved) {
                    info = tranfer.title;
                    ProcessAsperaUpload(fileNameList, null, uploadFolderPath);
                    hasSaved = true;
                }
            }

            break;
    }
};

fileControls.uploadFiles = function (fileList) {
    if (fileList == null || fileList == 'undefined')
        fileList = fileListForRetry;
    else 
        fileListForRetry = fileList;
    setupHandleTransferEvents();
    var examname = $(this).parent().find("#uploaderDiv" + currentExamId).attr("examName");
    asperaUpload(fileList.dataTransfer.files, examname);
};

//Page events begin
$(document).ready(function () {

    primaryparentID = getParameterByName('primaryparentID');
    if (primaryparentID == null || primaryparentID == '')
        primaryparentID = '91885';

    secondaryparentID = getParameterByName('secondaryparentID');
    if (secondaryparentID == null || secondaryparentID == '')
        secondaryparentID = '02';

    paramExamID = getParameterByName('examID');
    if (paramExamID == null || paramExamID == '')
        paramExamID = 'examID';

});
//Page events end

function setPrimarySecondaryIds(primaryParentID, secondaryParentID, paramexamID) {
    primaryparentID = primaryParentID;
    secondaryparentID = secondaryParentID;
    paramExamID = paramexamID;
    uploadFolderPath = "/" + primaryparentID + "/" + secondaryparentID + "/" + paramExamID;
}

var remoteHost;
var remoteUser;
var remotePassword;
var TargetRateKbps;
var remoteTargetRateKbps;
var destinationRoot;

function connect(asperaHost, asperaUser, asperaPassword, asperaTargetRateKbps, asperaDestinationRoot) {
    remoteHost = asperaHost;
    remoteUser = asperaUser;
    remotePassword = asperaPassword;
    remoteTargetRateKbps = asperaTargetRateKbps;
    destinationRoot = asperaDestinationRoot;
}

function onSuccess(data) {
    alert(data);
}

function onError(data) {
    alert(data);
}

function onProgressChange(data) {
    document.getElementById("divAtiInfo").innerHTML = data;
}

function setupHandleTransferEvents() {
    this.asperaWeb.initSession("SimpleUpload");
    this.asperaWeb.addEventListener('transfer', fileControls.handleTransferEvents);
}

function CreateUploadFolder() {
    var input = {
        Domain: "ATI",
        PrimaryParentId: primaryparentID,
        SecondaryParentId: secondaryparentID,
//        TertiaryParentId: paramExamID,
        RelativeFilePath: ""
    };

    var jsonData = JSON.stringify(input);
    var interimSvc = wcfAtiServiceUrl;
    $.ajax({
        url: interimSvc + '/HttpCreateUploadFolder',
        type: 'POST',
        data: jsonData,
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (result) {
            uploadFolderPath = result.FolderPath;           
            if (result.ErrorString != null) {
                alert("Error String -" + result.ErrorString + "<br>");
            }
        },
        error: function (xhr, status, error) {
            alert('Error! - ' + xhr.status + ' ' + error);
        }
    });
}

function ProcessAsperaUpload(fileList, examname, relativePath) {
    var folderPath = uploadFolderPath;    
    var input = {
        Domain: "ATI",
        UserDetail: userName,
        PrimaryParentId: primaryparentID,
        SecondaryParentId: secondaryparentID,
        TertiaryParentId: paramExamID,
        ExpTotalNoOfFiles: fileList.length,
        Files: fileList,
        RelativeFilePath: relativePath,
        Examname: examname
        
    };

    var jsonData = JSON.stringify(input);
    var interimSvc = wcfAtiServiceUrl;
    $.ajax({
        url: interimSvc + '/HttpProcessAsperaUpload',
        type: 'POST',
        data: jsonData,
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (result) {
            var operationStatus = result.OperationStatus;
            if (result.ErrorString) {
                ShowAsperaStatus(failed_to_upload_status, "1", result.ErrorString);
            }
            else {
                ShowAsperaStatus(completed_status, "1", result.ErrorString);
            }
        },
        error: function (xhr, status, error) {
            alert('Error! - ' + xhr.status + ' ' + error);
        }
    });
}

function asperaUpload(pathArray, examname) {      
    remoteHost = atiAsperaHost;
    remoteUser = atiAsperaUsername;
    remotePassword = atiAsperaPassword;
    remoteTargetRateKbps = 100000;
    destinationRoot = "/";   
    transferSpec = {
        "paths": [],
        "remote_host": remoteHost,
        "remote_user": remoteUser,
        "remote_password": remotePassword,
        "direction": "send",
        "target_rate_kbps": remoteTargetRateKbps,
        "resume": "sparse_checksum",
        "destination_root": uploadFolderPath,
        "fasp_port": 33001,
        "create_dir": true
    };
    connectSettings = {
        "allow_dialogs": "no"
    };
	
    // Reset
    fileNameList = [];
    hasSaved = false;

    for (var i = 0, length = pathArray.length; i < length; i += 1) {
        transferSpec.paths.push({ "source": pathArray[i].name });
        fileNameList.push(pathArray[i].name.replace(/^.*[\\\/]/, ''));
    }

    if (transferSpec.paths.length === 0) {
        return;
    }
    AsperaAddInputFilesToQueue(pathArray);
    asperaWeb.startTransfer(transferSpec, connectSettings, callbacks = {
        error: function (obj) {
            window.alert("Failed to start aspera: " + JSON.stringify(obj, null, 4));
            isAsperaon = false;
        },
        success: function () {
        }
    });

}
