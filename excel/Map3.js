//AngularJS
var app = angular.module('MyMap', ['ngMap', 'ngSanitize']);
app.controller('MapController', function ($scope, NgMap, $http) {
    //相關初始宣告給值
    var mapBase = this;
    mapBase.address = "高雄市新興區七賢一路531號";  //初始定位位置    
    mapBase.zoom = 17;                              //初始定位大小

    //相關變數   
    mapBase.move = { position: "", number: "" };    //移動點位位置與編號
    mapBase.selectVer = 0;                          //目前選擇的版本    
    mapBase.selectMarker = ""                       //選擇的點位基本資料
    mapBase.firstSelectMarker = ""                  //暫存修改前的點位基本資料
    mapBase.mapBaseMakers = "";                     //一開始ajax取出的原始點位json檔
    mapBase.mapMakers = "";                         //地圖上套用顯示點位的json
    mapBase.nowMaker = "";                          //現在選取marker的ID
    mapBase.mapMarkerData = "";                     //選取點位路口資料
    mapBase.mapMarkerVer = "";                      //選取點位全部版本ID
    mapBase.selectMarkerColor = "";                 //紀錄之前選marker要改回顏色
    mapBase.newMM = true;                           //是否隱藏新增點位按鈕
    mapBase.nowSelectVer = [{}];                    //目前版本的路口資料(套用到目前面版顯示的資訊)
    mapBase.Job = "";                               //派工json
    mapBase.Notice = "";                            //通報json
    mapBase.newMakerShow = false;                   //是否在新增路口中
    mapBase.leftami = true;                         //左視窗是否動畫中
    mapBase.searchs = "";                           //上方搜尋textBox變數
    mapBase.selectChangeVer = "";                   //雙版本存放位置???
    mapBase.editRoadBase = false                    //是否在編輯基本資料        
    mapBase.nowVer = "";                            //目前選擇的版本       
    mapBase.url = {                                 //樣版網址
        roadBaseData: "template/roadBaseData.html",
        notice: "excel/notice.html",
        job: "excel/job.html",
        mapControl: "excel/mapControl2.html",
        dialogBox: "excel/dialogBox.html",
        topNavBar: "excel/topNavBar.html",
        IntersectionBase: "excel/IntersectionBase2.html",
        IntersectionDetailBase: "template/IntersectionDetail/IntersectionDetailBase.html",
        WeekType: "template/IntersectionDetail/WeekType.html",
        TimeIntervalType: "template/IntersectionDetail/TimeIntervalType.html",
        TimePlan: "template/IntersectionDetail/TimePlan.html",
        TimePhase: "template/IntersectionDetail/TimePhase.html",
        loadDiv: "template/loadDiv.html"
    };

    //以下function

    //使用google定位元件
    var geocoder = new google.maps.Geocoder();
    mapBase.searchMap = function () {
        geocoder.geocode({ 'address': mapBase.searchs }, function (results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
                mapBase.map.setCenter(results[0].geometry.location);
                mapBase.map.setZoom(17);
            } else {
                alert('找不到相關位置，請重新鍵入地址: ' + status);
            }
        });
    }
    mapinit = false;
    //取得地圖
    NgMap.getMap().then(function (map) {
        mapBase.map = map;
        mapinit = true;
        mapBase.centerChanged();
    });

    //取得路口點位
    mapBase.getMarkers = function () {
        $http({
            method: 'GET',
            url: 'json/GetIntersection.ashx'
        }).success(function (data, status, headers, config) {
            postToastr("取得路口點位完成");
            mapBase.mapBaseMakers = data;
            mapBase.centerChanged();
        }).error(function (data, status, headers, config) {
            postToastr("取得路口點位失敗，請聯絡系統管理者！", "error");
        });
    }

    //取得路口點位2
    mapBase.getMakers2 = function () {
        $http({
            method: 'GET',
            url: 'json/GetIntersection.ashx?type=setLoc'
        }).success(function (data, status, headers, config) {
            mapBase.setLoc = data;
        }).error(function (data, status, headers, config) {
            postToastr("取得路口點位失敗，請聯絡系統管理者！", "error");
        });
    }
    mapBase.getMakers2();
    //取得選取點位全部版本ID
    mapBase.getMarkerVer = function (event, id, index, my) {
        document.getElementById("loadDiv").style.display = "";
        mapBase.initMarkerColor(my);
        mapBase.selectMarker = my.mapMaker;
        $http({
            method: 'GET',
            url: "json/GetMakerData.ashx?type=getVer&id=" + id
        }).success(function (data, status, headers, config) {
            mapBase.mapMarkerVer = data;
            mapBase.getMarkerData(event, mapBase.mapMarkerVer[0].IntersectionDetailID);
            mapBase.initMakerData("3");
        }).error(function (data, status, headers, config) {
            postToastr("取得路口點位版本失敗，請聯絡系統管理者！", "error");
        });
        mapBase.getMakerNotice(id);
    }

    //取得新的版本列表
    mapBase.getMarkerNewVer = function (event) {
        document.getElementById("loadDiv").style.display = "";
        $http({
            method: 'GET',
            url: "json/GetMakerData.ashx?type=getVer&id=" + mapBase.selectMarker.IntersectionID
        }).success(function (data, status, headers, config) {
            mapBase.mapMarkerVer = data;
            mapBase.getMarkerData(event, mapBase.mapMarkerVer[0].IntersectionDetailID);
            mapBase.initMakerData("3");
        }).error(function (data, status, headers, config) {
            postToastr("取得路口點位版本失敗，請聯絡系統管理者！", "error");
        });
    }

    //取得選取點位詳細資料
    mapBase.getMarkerData = function (event, id) {
        document.getElementById("loadDiv").style.display = "";
        mapBase.initMakerData("1");
        $http({
            method: 'GET',
            url: "json/GetMakerData.ashx?type=getMarker&id=" + id
        }).success(function (data, status, headers, config) {
            mapBase.mapMarkerData = data;
            mapBase.initMakerData("2");
        }).error(function (data, status, headers, config) {
            postToastr("取得路口基本資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //二版本轉一版本位詳細資料
    mapBase.getTwoMarker = function (event, id) {
        document.getElementById("loadDiv").style.display = "";
        mapBase.initMakerData("1");
        $http({
            method: 'GET',
            url: "json/GetMakerData.ashx?type=getTwoMarker&id=" + id
        }).success(function (data, status, headers, config) {
            mapBase.mapMarkerData = data;
            mapBase.initMakerData("2");
        }).error(function (data, status, headers, config) {
            postToastr("取得路口基本資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //初始化點位內容資料
    mapBase.initMakerData = function (type) {
        if (type == "1") {
            mapBase.editRoadBase = false;
            mapBase.mapMarkerData = ""
        } else if (type == "2") {
            mapBase.nowSelectVer = [{}];
            mapBase.nowSelectVer[0] = mapBase.mapMarkerData;
            document.getElementById("loadDiv").style.display = "none";
            $('#RoadContentBox').modal('show');
        } else if (type == "3") {
            mapBase.nowVer = mapBase.mapMarkerVer[0].ver;
            mapBase.Job = "";
            mapBase.Notice = "";
        }
    }

    //初始化所有marker顏色後改變新選擇的marker顏色
    mapBase.initMarkerColor = function (my) {
        if (mapBase.selectMarkerColor != null && mapBase.selectMarkerColor != "") {
            mapBase.selectMarkerColor.Img = "img/map.png";
            mapBase.selectMarkerColor = my.mapMaker;
            mapBase.selectMarkerColor.Img = "img/maps.png";
        } else {
            mapBase.selectMarkerColor = my.mapMaker;
            mapBase.selectMarkerColor.Img = "img/maps.png";
        }
    }
    var setID = "";
    //新增路口點位
    mapBase.insertMaker = function (type, my) {
        if (type == "edit") {
            mapBase.newMakerShow = true;
            setID = my.IntersectionID;
            var position = mapBase.map.getCenter() + "";
            position = position.replace("(", "");
            position = position.replace(")", "");
            mapBase.mapMakers = [{
                IntersectionID: my.IntersectionID,
                Zone: my.Zone,
                RoadName: my.RoadName,
                ENumber: my.ENumber,
                Position: position,
                Img: "img/map2.png"
            }];
            $("#insertMarkerCheck").stop().animate;
            $("#insertMarkerCheck").animate({ top: '50px' }, 200, 'swing');
        }
        else if (type == "ok") {
            $("#insertMarkerCheck").stop().animate;
            $("#insertMarkerCheck").animate({ top: '150px' }, 600, 'swing');
            mapBase.newMakerShow = false;
            var newPosition = mapBase.map.markers['marker' + setID].getPosition() + "";
            newPosition = newPosition.replace("(", "").replace(")", "");
            var IntersectionID = mapBase.mapMakers[0].IntersectionID;
            var Zone = mapBase.mapMakers[0].Zone;
            var RoadName = mapBase.mapMakers[0].RoadName;
            var ENumber = mapBase.mapMakers[0].ENumber;
            mapBase.mapMakers[0].Position = newPosition;
            $http({
                method: 'post',
                url: "json/PostUpdateBase.ashx?type=updateLoc",
                data: mapBase.mapMakers[0]
            }).success(function (data, status, headers, config) {
                mapBase.mapBaseMakers.push({
                    Position: newPosition,
                    IntersectionID: IntersectionID,
                    Zone: Zone,
                    RoadName: RoadName,
                    ENumber: ENumber,
                    Img: "img/map.png"
                });
                mapBase.centerChanged();
                mapBase.getMakers2();
                postToastr("新增路口點位成功");
            }).error(function (data, status, headers, config) {
                postToastr("新增路口點位失敗，請聯絡系統管理者！", "error");
            });
            mapBase.centerChanged();
        } else if (type == "no") {
            $("#insertMarkerCheck").stop().animate;
            $("#insertMarkerCheck").animate({ top: '150px' }, 600, 'swing');
            mapBase.newMakerShow = false;
            mapBase.centerChanged();
        }
    }

    //修改基本資料
    mapBase.updateBase = function (type) {
        if (type == "edit") {
            mapBase.editRoadBase = true
            $('#baseInfo1').collapse('show');
            mapBase.firstSelectMarker = angular.copy(mapBase.selectMarker);
            mapBase.selectMarker.RoadName = changeBrN('br', mapBase.selectMarker.RoadName);
        } else if (type == "ok") {
            mapBase.editRoadBase = false;
            $('#baseInfo1').collapse('hide');
            mapBase.selectMarker.RoadName = changeBrN('n', mapBase.selectMarker.RoadName);
            $http({
                method: 'post',
                url: "json/PostUpdateBase.ashx?type=updateIntersectionBase",
                data: mapBase.selectMarker
            }).success(function (data, status, headers, config) {
                postToastr("修改基本資料成功");
            }).error(function (data, status, headers, config) {
                postToastr("修改基本資料失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            $('#baseInfo1').collapse('hide');
            mapBase.editRoadBase = false;
            mapBase.selectMarker = angular.copy(mapBase.firstSelectMarker);
        }
    }

    //移動路口點位
    mapBase.markerMove = function (event, type, my,item) {
        if (type == "dragStart") {
            mapBase.initMarkerColor(my);
            mapBase.move.position = mapBase.map.markers[item].getPosition();
            mapBase.move.number = item;
            mapBase.move.my = my;
        } else if (type == "dragEnd") {
            if (!mapBase.newMakerShow) {
                $('#moveCheckBox').modal('show')
            }
        } else if (type == "ok") {
            mapBase.selectMarker = mapBase.move.my.mapMaker;
            console.log(mapBase.selectMarker);
            var position = mapBase.map.markers[mapBase.move.number].getPosition() + "";
            position = position.replace("(", "");
            position = position.replace(")", "");
            mapBase.selectMarker.Position = position;
            $http({
                method: 'post',
                url: "json/PostUpdateBase.ashx?type=updateIntersectionBase",
                data: mapBase.selectMarker
            }).success(function (data, status, headers, config) {
                postToastr("更新路口位置成功");
            }).error(function (data, status, headers, config) {
                postToastr("修改點位位置失敗，請聯絡系統管理者！", "error");
                mapBase.map.markers[mapBase.move.number].setPosition(mapBase.move.position);
            });
        } else if (type == "no") {
            mapBase.map.markers[mapBase.move.number].setPosition(mapBase.move.position);
        }
    }

    //讀取是否有雙版本
    mapBase.loadTwoVer = function (id) {
        $http({
            method: 'GET',
            url: "json/GetMakerData.ashx?type=getTwoVer&id=" + id,
            data: id
        }).success(function (data, status, headers, config) {
            mapBase.selectChangeVer = data;
        }).error(function (data, status, headers, config) {
            postToastr("讀取資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //取得派工資料
    mapBase.getMakerJob = function (id) {
        $http({
            method: 'post',
            url: "json/GetPostJob.ashx?type=getJob",
            data: id
        }).success(function (data, status, headers, config) {
            mapBase.Job = data;
        }).error(function (data, status, headers, config) {
            postToastr("取得派工資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //取得通報資料
    mapBase.getMakerNotice = function (id) {
        $http({
            method: 'post',
            url: "json/GetPostNotice.ashx?type=getNotice",
            data: id
        }).success(function (data, status, headers, config) {
            mapBase.Notice = data;
            nowSelect = 0;
            var num = mapBase.Notice.length / 5 | 0
            $("#leftbtn").removeClass("disabled");
            $("#rightbtn").removeClass("disabled");
            if (nowSelect == 0) {
                $("#leftbtn").addClass("disabled");
            }
            if (nowSelect == num) {
                $("#rightbtn").addClass("disabled");
            }
        }).error(function (data, status, headers, config) {
            postToastr("取得通報資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //打開時初始化
    mapBase.openPage = function (type) {
        if (type == "roadBaseData") {
            $("#roadBaseDatali").addClass("active");
            $("#noticeli").removeClass("active");
            $("#jobli").removeClass("active");
            $('#roadBaseDataPage').collapse('show');
            $('#noticePage').collapse('hide');
            $('#jobPage').collapse('hide');
        } else if (type == "notice") {
            $("#noticeli").addClass("active");
            $("#roadBaseDatali").removeClass("active");
            $("#jobli").removeClass("active");
            $('#noticePage').collapse('show');
            $('#roadBaseDataPage').collapse('hide');
            $('#jobPage').collapse('hide');
        } else if (type == "job") {
            $("#jobli").addClass("active");
            $("#roadBaseDatali").removeClass("active");
            $("#noticeli").removeClass("active");
            $('#jobPage').collapse('show');
            $('#roadBaseDataPage').collapse('hide');
            $('#noticePage').collapse('hide');
        }
    }

    //確定搜尋
    mapBase.placeChanged = function () {
        mapBase.place = this.getPlace();
        mapBase.map.setZoom(17);
        mapBase.map.setCenter(mapBase.place.geometry.location);
    }

    //搜尋時左視窗
    mapBase.keySearch = function (position) {
        if ($("#autocomplete").val().length > 0) {
            if (mapBase.leftami) {
                $("#leftSearch").stop().animate;
                $("#leftSearch").animate({ left: '5px' }, 600, 'swing');
                mapBase.leftami = false;
            }
        } else {
            if (!mapBase.leftami) {
                $("#leftSearch").stop().animate;
                $("#leftSearch").animate({ left: '-220px' }, 600, 'swing');
                mapBase.leftami = true;
            }
        }
    }

    //關閉搜尋時左視窗
    mapBase.keySearchClose = function () {
        $("#leftSearch").animate({ left: '-220px' }, 600, 'swing');
    }

    //點擊左搜尋視窗列表
    mapBase.searchToPosition = function (my) {
        mapBase.initMarkerColor(my);
        mapBase.address = my.mapMaker.Position;
        mapBase.map.setZoom(18);
    }
    mapBase.centerChanged = function (event) {
        var out = [];
        if (mapinit && !mapBase.newMakerShow) {
            angular.forEach(mapBase.mapBaseMakers, function (value, key) {
                var flag = false;
                var lat = parseFloat(value.Position.split(',')[0]);
                var lng = parseFloat(value.Position.split(',')[1]);
                var centerLat = parseFloat(mapBase.map.getCenter().lat());
                var centerLng = parseFloat(mapBase.map.getCenter().lng());
                if (mapBase.map.getZoom() > 17) {
                    var range = 0.007;
                    if (lat < (centerLat + range) && lat > (centerLat - range) && lng < (centerLng + range) && lng > (centerLng - range)) {
                        flag = true;
                    }
                }
                else if (mapBase.map.getZoom() == 17) {
                    var range = 0.007 * 2;
                    if (lat < (centerLat + range) && lat > (centerLat - range) && lng < (centerLng + range) && lng > (centerLng - range)) {
                        flag = true;
                    }
                } else if (mapBase.map.getZoom() == 16) {
                    var range = 0.013 * 2;
                    if (lat < (centerLat + range) && lat > (centerLat - range) && lng < (centerLng + range) && lng > (centerLng - range)) {
                        flag = true;
                    }
                //} else if (mapBase.map.getZoom() == 15) {
                //    var range = 0.03 * 2;
                //    if (lat < (centerLat + range) && lat > (centerLat - range) && lng < (centerLng + range) && lng > (centerLng - range)) {
                //        flag = true;
                //    }
                //} else if (mapBase.map.getZoom() == 14) {
                //    var range = 0.06 * 2;
                //    if (lat < (centerLat + range) && lat > (centerLat - range) && lng < (centerLng + range) && lng > (centerLng - range)) {
                //        flag = true;
                //    }
                //} else if (mapBase.map.getZoom() == 13) {
                //    var range = 0.11 * 2;
                //    if (lat < (centerLat + range) && lat > (centerLat - range) && lng < (centerLng + range) && lng > (centerLng - range)) {
                //        flag = true;
                //    }
                }
                if (flag) {
                    out.push(value);
                }
            });
            mapBase.mapMakers = out;
        }
    }
    //縮放地圖事件
    mapBase.zoomChange = function () {
        if (mapBase.map != null && mapBase.map != "") {
            if (mapBase.map.getZoom() < 13) {
                mapBase.mapMakers = [{ "Img": "img/space.png" }];
            }
            if (mapBase.map.getZoom() < 15) {
                mapBase.newMM = false;
            } else {
                mapBase.newMM = true;
            }
        }
    }

    //隱藏此路口
    mapBase.roadDelete = function (type, id) {
        if (type == "edit") {
            $('#roadDelete1').collapse('toggle');
        } else if (type == "ok") {
            $('#roadDelete1').collapse('toggle');
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=roadDelete",
                data: mapBase.selectMarker.IntersectionID
            }).success(function (data, status, headers, config) {
                postToastr("隱藏路口成功");
                $("#RoadContentBox").modal('hide');
                mapBase.getMarkers();
            }).error(function (data, status, headers, config) {
                postToastr("隱藏路口失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            $('#roadDelete1').collapse('toggle');
        }
    }

    //以下Bootstrap相關設定
    //移動確認視窗設定
    $('#moveCheckBox').modal({
        backdrop: "static",
        show: false,
        keyboard: false
    })


    //以下最後執行

    mapBase.getMarkers();    //載入點位

});

//HtmlJS
//吐司訊息
function postToastr(msg, short) {
    if (!short) {
        short = "success";
    }
    if (!msg) {
        msg = "更新成功";
    }
    var title = "";
    toastr.options = {
        "closeButton": false,
        "debug": false,
        "newestOnTop": false,
        "progressBar": true,
        "positionClass": "toast-top-center",
        "preventDuplicates": false,
        "onclick": null,
        "showDuration": "300",
        "hideDuration": "1000",
        "timeOut": "3000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "swing",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    }
    var $toast = toastr[short](msg);
}

//br跟\n轉換用
function changeBrN(type, str) {
    if (type == "br") {
        if (str != "" && str != null) {
            str = str.replace(/\<br \/>/g, "\n");
            return str;
        } else {
            return "";
        }
    } else if (type == "n") {
        if (str != "" && str != null) {
            str = str.replace(/\n/g, "<br />");
            return str;
        } else {
            return "";
        }
    } else {
        return str;
    }
}

//Br轉\n
app.filter('cleanBr', function () {
    return function (str) {
        if (!!str) {
            return str.replace(/\<br \/>/g, "\n　　　");
        }
    };
});
//\n轉Br
app.filter('toSpace', function () {
    return function (str) {
        if (!!str) {
            return str.replace(/\<br \/>/g, "<br />　　　");
        }
    };
});

//地圖搜尋關鍵字過濾器
app.filter('searchMapKey', function () {
    return function (input, key) {
        if (key.length > 0) {
            if (key == "all") {
                return input;
            } else {
                var pattern = new RegExp("[`~!@#$^&*()=|{}':;',\\[\\].<>/?~！@#￥……&*（）——|{}【】『；：」「'。，、？]")
                var stringF = "";
                for (var i = 0; i < key.length; i++) {
                    stringF = stringF + key.substr(i, 1).replace(pattern, '');
                }
                var stringS = stringF.split(' ');
                key = stringF;
                if (key.length > 0) {
                    var out = [];
                    angular.forEach(input, function (alls) {
                        var toHave = true;
                        var stringSer = alls.Zone + alls.RoadName + "";
                        for (var i = 0; i < stringS.length; i++) {
                            if (!!stringSer) {
                                if (stringSer.search(stringS[i]) != -1) {

                                } else {
                                    toHave = false;
                                }
                            }
                        }
                        if (toHave) {
                            out.push(alls);
                        }
                    })
                    return out;
                }
            }
        }
    };
});
app.filter('searchMapKey2', function () {
    return function (input, key) {
        if (key.length > 0) {
            if (key == "all") {
                return input;
            } else {
                var pattern = new RegExp("[`~!@#$^&*()=|{}':;',\\[\\].<>/?~！@#￥……&*（）——|{}【】『；：」「'。，、？]")
                var rs = "";
                for (var i = 0; i < key.length; i++) {
                    rs = rs + key.substr(i, 1).replace(pattern, '');
                }
                var uu = rs.split(' ');
                key = rs;
                if (key.length > 0) {
                    var out = [];

                    angular.forEach(input, function (alls) {
                        var toHave = true;
                        var ss = alls.Zone + alls.RoadName + "";
                        for (var i = 0; i < uu.length; i++) {
                            if (!!ss) {
                                if (ss.search(uu[i]) != -1) {

                                } else {
                                    toHave = false;
                                }
                            }
                        }
                        if (toHave) {
                            out.push(alls);
                        }
                    })
                    return out;
                }
            }
        } else {
            return input;
        }
    };
});