﻿<%@ page language="C#" title="Image Summary" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
 <title>Summary</title>
 <link type="text/css" rel="stylesheet" href="../css/review_style.css?version=24" />
 <link type="text/css" rel="stylesheet" href="../javascript/jquery-ui/themes/custom-theme2/jquery-ui.css" />



</head>
<body>    
 <script type="text/javascript" src="../javascript/triadUrlService.js"></script> 
 <script type="text/javascript">
     TriadUrl.init(['<%= ConfigurationManager.AppSettings["TriadServicesBaseUrl"] %>']);
 </script>
 <script type="text/javascript" src="../javascript/jquery/jquery-2.1.1.min.js"></script>
 <script type="text/javascript" src="../javascript/jquery-ui/jquery-ui-1.11.0.min.js"></script>
 <script type="text/javascript" src="./javascript/jquery.printElement.js"></script>
 <script type="text/javascript" src="../javascript/jquery.livequery.min.js"></script>
 <script type="text/javascript" src="../javascript/auditTrail.js"></script>
 <script type="text/javascript" src="../javascript/atiuploaderapp.js?vers=131"></script>

    <table width="1024px" align="left">
        <tr>
            <td>

               <div style="width: 100%;">
		   <div id="divTestingPackageSummary" name="testingPackageSummary" runat="server" data-primaryparent-id=""
                                data-secondaryparent-id="" data-user="" data-domain="" data-view-type="" data-is-debug-mode="" data-audit-trail-is-on=""
                                data-exam-id="" data-uploader-base-url="">
                                <div id="divListOfExamsInTestingPackage" style="display: none;">
                                </div>
                    </div>
                    <div style="display: none;" class="divNotificationContainer">
                        <div id="popupNotification" title="Warning" class="divPopupNotification"></div>
                    </div>
                </div>
    
                <div id="loadingDiv">
                    <img src='/Images/loader.gif' width='45px' repeat alt='Loading...' />
                </div>
            </td>
        </tr>
    </table>
</body>
</html>