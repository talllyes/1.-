<%@ Page Language="C#" AutoEventWireup="true" CodeFile="manage.aspx.cs" Inherits="manage" %>

<html>
<head runat="server">
    <title>交通號誌時制管理系統</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css">
        body {
            background-image: url('img/mapbk.jpg');
            background-attachment: fixed;
            background-size: cover;
        }
    </style>
    <!-- Base -->
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript" src="js/angular.min.js"></script>
    <script type="text/javascript" src="js/angular-sanitize.min.js"></script>

    <!-- ICNO -->
    <link rel="stylesheet" href="/css/awesome/css/font-awesome.css" />

    <!-- Bootstrap -->
    <link rel="stylesheet" href="Bootstrap/css/bootstrap.css" />
    <script type="text/javascript" src="Bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="Bootstrap/js/bootstrap3-typeahead.js"></script>

    <!-- Kai -->
    <link rel="stylesheet" href="css/KaiCss.css" />
    <link rel="stylesheet" href="css/toastr.css" />
    <script type="text/javascript" src="js/toastr.js"></script>
    <script type="text/javascript" src="js/AngController/manage.js"></script>
</head>
<body>
    <div ng-app="MyMap" ng-controller="ManageController as manage">        
        <div ng-include="manage.Url.loadDiv"></div>
        <div ng-include="manage.Url.TopNavBar"></div>
        <div ng-include="manage.Url.Manage"></div>
    </div>
</body>
</html>

