<%@ Page Language="C#" AutoEventWireup="true" CodeFile="setLoc.aspx.cs" Inherits="setLoc" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>放點位用網頁(放完後刪除)</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Base -->
    <!--<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>-->
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
    <script type="text/javascript" src="js/angular.min.js"></script>
    <script type="text/javascript" src="js/angular-sanitize.min.js"></script>
    <script type="text/javascript" src="js/ng-map.js"></script>
    <script type="text/javascript" src="js/jquery.form.js"></script>

    <!-- GoogleMap -->
    <script src="https://maps.google.com/maps/api/js?libraries=placeses,visualization,drawing,geometry,places&language=zh-TW"></script>

    <!-- ICNO -->
    <link rel="stylesheet" href="css/awesome/css/font-awesome.css">

    <!-- Bootstrap -->
    <link rel="stylesheet" href="Bootstrap/css/bootstrap.css">
    <script type="text/javascript" src="Bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="Bootstrap/js/bootstrap3-typeahead.js"></script>

    <!-- datetimepicker -->
    <link rel="stylesheet" href="css/bootstrap-datetimepicker.css">
    <script type="text/javascript" src="js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="js/bootstrap-datetimepicker.zh-TW.js"></script>

    <!-- Kai -->
    <link rel="stylesheet" href="css/KaiCss.css" />
    <link rel="stylesheet" href="css/toastr.css" />
    <script type="text/javascript" src="js/toastr.js"></script>
    <script type="text/javascript" src="excel/Map3.js"></script>
    <script type="text/javascript" src="excel/roadBaseData3.js"></script>
    <script type="text/javascript" src="js/AngController/noticeData.js"></script>
    <script type="text/javascript" src="js/AngController/jobData.js"></script>

    <style type="text/css">
        body {
            height: 100%;
            margin: 0;
            padding: 0;
            overflow-y: hidden;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" style="height: 100%;">
        <div ng-controller="MapController as mapBase" class="sidenavdemoBasicUsage" style="height: 100%;" ng-app="MyMap">

            <!-- 載入讀取遮罩 -->
            <div ng-include="mapBase.url.loadDiv"></div>

            <!-- 載入上方bar -->
            <div ng-include="mapBase.url.topNavBar"></div>

            <!-- 地圖元件 -->
            <ng-map zoom="{{mapBase.zoom}}"
                center="{{mapBase.address}}"
                map-type-control="false"
                map-type-control-options="{style:'HORIZONTAL_BAR', position:'TOP_RIGHT'}"
                    on-idle="mapBase.centerChanged()"
                on-zoom_changed="mapBase.zoomChange()" style="height: 100%;">
                <marker ng-repeat="mapMaker in mapBase.mapMakers" 
                        icon="{{mapMaker.Img}}" 
                        position="{{mapMaker.Position}}"                 
                        on-click="mapBase.getMarkerVer('{{mapMaker.IntersectionID}}',$index,this)" 
                        draggable="true" title="查詢資料" on-dragend="mapBase.markerMove('dragEnd')" 
                        on-dragstart="mapBase.markerMove('dragStart',this,'marker{{mapMaker.IntersectionID}}')"
                     id="marker{{mapMaker.IntersectionID}}">  
                </marker>

                <!-- 載入地圖控制項 -->
                <div ng-include="mapBase.url.mapControl"></div>
            </ng-map>

            <!-- 載入對話框 -->
            <div ng-include="mapBase.url.dialogBox"></div>
        </div>
    </form>
</body>
</html>

