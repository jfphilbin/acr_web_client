﻿<%@ page language="C#" masterpagefile="~/Forms/TestingPackages/TestingPackages.master" autoeventwireup="true" inherits="Forms_TestingPackages_Common_UploadImages" 
    title="Upload Images" enableEventValidation="false" theme="TP-Basic" viewStateEncryptionMode="Always" CodeFile="UploadImages.aspx.cs"   %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="Server">
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/triadUrlService.js"></script> 
    <script type="text/javascript">
        TriadUrl.init(['<%= ConfigurationManager.AppSettings["TriadServicesBaseUrl"] %>']);
    </script>
     
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/jquery/jquery-2.1.1.min.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/jquery-ui/jquery-ui-1.11.0.min.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/jquery.printElement.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/jquery.livequery.min.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/auditTrail.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/atiuploaderapp.js?vers=131"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/JSAspera/asperaplugininstaller.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/JSAspera/application.js"></script>
    <script type="text/javascript" src="<%=uploaderBaseUrl %>/javascript/JSAspera/asperaLib.js"></script>
    <script type="text/javascript" language="javascript">
        function showDialog(Url) {
            if (($('#<%= usrname.ClientID %>').val() == "") || ($('#<%= usrname.ClientID %>').val() == null)) {
                alert("Session to the file manager has timed out. Please logout from the application and login back");
                return false;
            }
            window.showModalDialog(Url, '', 'dialogHeight:630px; dialogWidth:930px; status:0; scroll:1; resizable=1');
            return true;
        }

        function validatePage() {

            //Check atleast one option is selected -- ACRedit Web Client or TRIAD Windows Client
            if ((!document.getElementById('<%= rbWebClient.ClientID %>').checked) && (!document.getElementById('<%= rbWindowsClient.ClientID %>').checked)) {
                document.getElementById('<%= lblErrorMsg.ClientID %>').innerHTML = "Error: Please make sure to select atleast one of the above option and then proceed...";
                document.getElementById('<%= lblErrorMsg.ClientID %>').style.display = "";
                return false;
            }

            return true;
        }

    </script>
    <asp:UpdatePanel ID="updatePanel1" runat="server" name="updated-panel">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="rbWebClient" />
            <asp:AsyncPostBackTrigger ControlID="rbWindowsClient" />
        </Triggers>
        <ContentTemplate>
            <br />
            <table id="tblMessageForATIUploader" runat="server" visible="false"  width="100%">
                <tr>
                    <td>
                        Please click the Instructions button to view the steps for uploading your image submission. After completing the upload for each exam, check the Ready for Submission box to attest that all required images for that exam have been uploaded. Click the Image Upload Summary button to see a summary of the files that were uploaded for all exams. <label class='emphasis'>Please note that no additional images will be accepted once the testing package is submitted.</label>
                    </td>
                </tr>
            </table>
            <br />
            <table width="100%">
                <tr>
                    <td style="font-style: italic; font-weight: bold">
                        Sending images electronically is safe and secure. Electronic submissions are protected
                        from unauthorized access and ACR has taken all measures to comply with federal privacy
                        legislation.
                    </td>
                </tr>
            </table>
            <br />
            <table width="100%">
                <tr>
                    <td>
                        <asp:RadioButton runat="server" ID="rbWebClient" AutoPostBack="true" GroupName="userSelection"
                            Font-Italic="true" Font-Names="Arial" Text="ACRedit Web Client" OnCheckedChanged="rbWebClient_CheckedChanged" />
                        <br />
                        <br />
                    </td>
                </tr>
            </table>
             <%--*************Table of ACRedit Upload Web Client*************** --%>
            <table id="tblWebClient" name="table-web-client" border="1" cellpadding="0" cellspacing="0"
                bordercolor="Black" style="border-style: none; font-family: Arial" runat="server"
                visible="false" width="100%">
                <tr>
                    <td class="uploader-td" style="position: relative">
                        <%--  <iframe runat="server" ID="ifUploaderControl" width="100%" height="300">
                        </iframe>--%>
                        <div style="position: relative">
                        <--! this is where get parameter is finding them -->
                            <div id="divTestingPackageSummary" name="testingPackageSummary" runat="server" data-primaryparent-id=""
                                data-secondaryparent-id="" data-user="" data-domain="" data-view-type="" data-is-debug-mode="" data-audit-trail-is-on=""
                                data-exam-id="" data-uploader-base-url="">   
                               <%-- <table id="divUploadMode" class="divUploadMode"><tr><td id="tdUploadModeIcon"></td><td id="tdUploadModeMessage" style="padding-top:7px;"></td></tr></table>--%>                                
                                <div id="divListOfExamsInTestingPackage" style="display: none;">
                                </div>
                            </div>
                            <div style="display: none;" class="divNotificationContainer">
                                <div id="popupNotification" title="Warning" class="divPopupNotification">
                                </div>
                            </div>
                            <div style="display: none;" class="divNotificationContainer">
                                <div id="popupHelp" title="Instructions" class="divPopupNotification">
                                  <br />
                                  <ul>
                                    <li>1.  Click the View/Upload button for any exam to begin.</li>
                                    <li>2.  Click the File Upload or Folder Upload button to select the files/folders that you wish to upload for that exam.</li>
                                    <li>3.  Once uploaded, the files will be displayed with a View button next to them. Click the View button to review the images that were uploaded.</li>
                                    <li>4.  Once you have confirmed that your submission for that exam is complete, click the Ready for Submission box for that exam. Checking the Ready for Submission box is an attestation that all required images for that exam have been uploaded.</li>
                                    <li>5.  Repeat steps 1-4 for the remaining exams.</li>
                                    <li>6.  Click the Image Upload Summary button to see a summary of the files that were uploaded for all exams.</li>
                                  </ul>
                                  <div class='instructionsTip'>TIP: If you need to edit the selected files before submitting your testing package, un-check the ready for submission box.</div>
                                  <div class='instructionsWarning'>Please note that no additional images will be accepted once the testing package is submitted.</div>
                                </div>
                            </div>  
                        </div>
                        <div id="loadingDiv">
                            <img src='<%=uploaderBaseUrl %>/Images/loader.gif' width='45px' repeat alt='Loading...' />
                        </div>
                    </td>
                </tr>
            </table>
            <table>
                <tr>
                    <td>
                        <br />
                        Choose this option to select files directly from your PACS. Please note that this option requires installation of the TRIAD software and may require the assistance of your IT department.<br />
                        <asp:RadioButton runat="server" ID="rbWindowsClient" AutoPostBack="true" GroupName="userSelection"
                            Font-Italic="true" Text="TRIAD Windows Client" OnCheckedChanged="rbWindowsClient_CheckedChanged" />
                    </td>
                </tr>
            </table>
            <br />
            <br />
            <br />
            <%--*************Table of TRIAD Windows Client*************** --%>
            <table id="tblWindowsClient" border="1" cellpadding="0" cellspacing="0" bordercolor="Black"
                style="border-style: none; font-family: Arial" runat="server" visible="false"
                width="100%">
                <tr>
                    <td align="center" bgcolor="#6C879E">
                        <h3 style="color: #FFFFFF; font-weight: bold;">
                            TRIAD Windows Client</h3>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table border="0">
                            <tr>
                                <td style="font-style: italic; font-weight: bold;">
                                    Instructions:
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; . Please click <a href="<%=System.Configuration.ConfigurationManager.AppSettings["TriadWindowsClientLink"] %>"
                                        target="_blank">TRIAD Windows Client </a>to download and install TRIAD windows
                                    Client.<br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Once the installation is completed, Click All
                                    Programs->American College of Radiology->Triad Windows Client to launch TRIAD Windows
                                    Client.<br />
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OR<br />
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; . If you have already installed TRIAD Windows Client,
                                    Click All Programs->American College of Radiology->Triad Windows Client to launch
                                    TRIAD Windows Client.<br />
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; . Please note that you must also download and install
                                    ClearCanvas in order to preview your images prior to submission. Please click <a
                                        href="<%=System.Configuration.ConfigurationManager.AppSettings["ClearCanvasDownloadLink"] %>"
                                        target="_blank">ClearCanvas </a>to download and install the free ClearCanvas
                                    viewer.<br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; You must download the version of ClearCanvas
                                    that is available through this link. Other versions of ClearCanvas are not compatible
                                    with the TRIAD Windows Client.
                                    <% if (IsTpDraftAppeal) %><% { %>
                                    <br />
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; . Please note: If you do not have additional images
                                    to upload for any examination for appeal review, please select the ACRedit Web Client
                                    above and select the checkbox at the bottom of the page.
                                    <% } %>
                                    <br />
                                    <br />
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Note:</b> You can also access
                                    ACRedit submit pages from TRIAD Windows Client.<br />
                                    <br />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
               
            </table>
            <asp:HiddenField ID="usrname" runat="server" Value="" />
            <asp:HiddenField ID="IsTpappeal" runat="server" Value="" />
           
            <table width="88%">
                <caption>
                    <br />
                    <tr>
                        <td>
                            <asp:CheckBox ID="chk_Additional_Image" runat="server" AutoPostBack="true" CssClass="txtpadding"
                                OnCheckedChanged="chk_Additional_Image_CheckedChanged" Text="Please note that you have not uploaded additional images for one or more examinations listed above. If this is correct, please check this box to attest that you have completed uploading of any additional images necessary for appeal review. Once the testing package is submitted, no additional images will be accepted."
                                Visible="false" />
                        </td>
                    </tr>
                </caption>
            </table>
            <br />      
            <div style="text-align: left">
                <asp:Button ID="btn_Triad_Original_Upload_Summary" Text="Original Image Summary"
                    runat="server" OnClick="btnSummary_Click" />
                <asp:Button ID="btn_Triad_Upload_Summary" Text="Image Upload Summary" runat="server"
                    OnClick="btnSummary_Click" />
            </div>                
            <asp:Label ID="lblErrorMsg" runat="server" ForeColor="Red"></asp:Label>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>