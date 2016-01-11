toggle(showHideDiv, switchTextDiv, displayText) {
    var ele = document.getElementById(showHideDiv);
    var text = document.getElementById(switchTextDiv);
    if (ele.style.display == "block") {
        ele.style.display = "none";
        text.innerHTML = "Show " + displayText;
    }
    else {
        ele.style.display = "block";
        text.innerHTML = "Hide " + displayText;
    }
}

uploadClick() {
    connect("triad4-ati2-test.acr.org", "triadappuser", "#3Adpass", 5000, "/");
    var fileList = [];
    fileList.push("C:\\Source2\\Hydrangeas.jpg"); 
    uploadFiles(fileList, onSuccess, onError, onProgressChange);
}

onSuccess(data) {
    alert(data);
}

onError(data) {
    alert(data);
}

onProgressChange(data) {
    document.getElementById("demo").innerHTML = data;
}
