var connectInstaller = null;
var connectApplication = null;
var asperaWeb = null;
var minConnect = "3.6.1";

//document.cookie = "isFirstTimeLogin=true";
// pick up the protocol and use that to download the latest connect files
// however if we are running off the local file system use http
var currentProto;
if (window.location.protocol.indexOf('file') != -1) {
	currentProto = "http:";
} else {
	currentProto = window.location.protocol;
}

var installerPath = currentProto + "//d3gcli72yxqn2z.cloudfront.net/connect/v4/";
var installersLoaded = 0;

// before isAsperaConnectInstalled make sure all three installers have been loaded
var checkInstallersLoaded = function () {
    installersLoaded++;
    if (installersLoaded == 2) {
        initAsperaConnect();
        isAsperaServerConnected();
    }
}

var initAsperaConnect = function () {
    /* This SDK location should be an absolute path, it is a bit tricky since the usage examples
     * and the install examples are both two levels down the SDK, that's why everything works
     */
    this.asperaWeb = new AW4.Connect({
        sdkLocation: installerPath,
        dragDropEnabled: false, //Enable if you want drag and drop, you will need minVersion of 3.6.1
        minVersion: minConnect
    });

    this.connectInstaller = new AW4.ConnectInstaller(installerPath);


    var statusEventListener = function (eventType, data) {
        if (eventType === AW4.Connect.EVENT.STATUS && data == AW4.Connect.STATUS.INITIALIZING) {
            connectInstaller.showLaunching();
        } else if (eventType === AW4.Connect.EVENT.STATUS && data == AW4.Connect.STATUS.FAILED) {
            connectInstaller.showDownload();
        } else if (eventType === AW4.Connect.EVENT.STATUS && data == AW4.Connect.STATUS.OUTDATED) {
            connectInstaller.showUpdate();
        } else if (eventType === AW4.Connect.EVENT.STATUS && data == AW4.Connect.STATUS.RUNNING) {
            connectInstaller.connected();
        }
     };

    asperaWeb.addEventListener(AW4.Connect.EVENT.STATUS, statusEventListener);
    asperaWeb.initSession();
};

var isAsperaServerConnected = function () {
    var authSpec = {
        "remote_host": atiAsperaHost,
        "remote_user": atiAsperaUsername,
        "remote_password": atiAsperaPassword,
        "fasp_port": 33001,
        "ssh_port": 22
    };

    this.asperaWeb.authenticate(authSpec,
        callbacks = {
            error: function (obj) {
                alert(JSON.stringify(obj));
                disableApp('TRIAD optimal file transfer mode is not on.');
            },
            success: function (obj) {
                showConnection('TRIAD optimal file transfer mode is on.');
            }
        }
    );
}

var isAsperaConnectInstalled = function () {    
    var isFirstTime = getCookie("isFirstTimeLogin");
    if (connectInstaller === null && isFirstTime != "false") {
        connectInstaller = new AW4.ConnectInstaller(installerPath);
        setCookie("isFirstTimeLogin", "false");
        return false;
    }
    return true;
};

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
    }
    return "";
}

function setCookie(cname, cvalue) {    
    document.cookie = cname + "=" + cvalue;
}

function setupConnectApplication() {
	if (connectApplication === null) {
	connectApplication = new AW4.Connect({id:'aspera_web_transfers'});
	} 
}

function showConnection(message) {
    $("#tdUploadModeIcon").html('<p><img class="imgStatisIconUploadMode" src="Images/excellent.png">');
    $("#tdUploadModeMessage").html(message);
}
// Helper function
function disableApp(message) {
    // document.body.innerHTML = '<h1 style="text-align:center;">' + document.title + '</h1><p>' + message + '</p><p><a href="#" onclick="javascript:location.reload();return false;">Restart Connect Installer</a></p>';
    $("#tdUploadModeIcon").html('<img class="imgStatisIconUploadMode" src="Images/poor.png">');
    $("#tdUploadModeMessage").html(message + '&nbsp;&nbsp;&nbsp;<a href="#" onclick="javascript:location.reload();return false;">Restart Connect Installer</a>');
}
