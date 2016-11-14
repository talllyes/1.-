//AngularJS
var app = angular.module('MyMap', ['ngMap', 'ngSanitize']);
app.controller('MapController', function ($scope, NgMap, $http) {
    //相關初始宣告給值
    var mapBase = this;
    mapBase.image = "img/map.png";               //初始圖片
    mapBase.address = "高雄市新興區七賢一路531號";  //初始定位位置    
    mapBase.zoom = 18;                              //初始定位大小
    //相關變數   
    mapBase.move = { position: "", number: "" };    //移動點位位置與編號
    mapBase.selectVer = 0;                        //目前選擇的版本
    mapBase.searchMarker = [{
        "Zone": "",
        "RoadName": "",
        "ENumber": "",
        "Position": ""
    }];
    mapBase.selectMarker = {                        //選擇的點位基本資料
        IntersectionID: "",
        Zone: "",
        RoadName: "",
        Position: "",
        ENumber: "",
        EmployeeID: "",
        ModifiedDate: ""
    }
    mapBase.firstSelectMarker = {                    //修改前的點位基本資料
        IntersectionID: "",
        Zone: "",
        RoadName: "",
        Position: "",
        ENumber: "",
        EmployeeID: "",
        ModifiedDate: ""
    }
    mapBase.mapBaseMakers = "";                     //一開始ajax取出的原始點位json檔
    mapBase.mapMakers = "";                         //地圖上套用顯示點位的json檔
    mapBase.nowMaker = "";                          //現在選取marker的ID
    mapBase.mapMaker = "";                          //選取點位的路口資料
    mapBase.selectItem = "";
    mapBase.imgChange = "";
    mapBase.newMM = true;
    mapBase.nowSelectVer = [{}];                  //目前版本的路口資料(套用到目前面版顯示的資訊)
    mapBase.Job = "";                               //派工
    mapBase.Notice = "";                            //通報
    mapBase.newMakerShow = false;                   //是否在新增路口
    mapBase.selectChangeVer = "";
    mapBase.setLoc = "";
    mapBase.showEdit = {                            //是否在編輯
        roadBase: false
    };
    mapBase.nowVer = "";

    mapBase.url = {                                 //樣版網址
        roadBaseData: "template/roadBaseData.html",
        notice: "template/notice.html",
        job: "template/job.html",
        mapControl: "template/mapControl2.html",
        dialogBox: "template/dialogBox.html",
        topNavBar: "template/topNavBar.html",
        IntersectionBase: "template/IntersectionDetail/IntersectionBase.html",
        IntersectionDetailBase: "template/IntersectionDetail/IntersectionDetailBase.html",
        WeekType: "template/IntersectionDetail/WeekType.html",
        TimeIntervalType: "template/IntersectionDetail/TimeIntervalType.html",
        TimePlan: "template/IntersectionDetail/TimePlan.html",
        TimePhase: "template/IntersectionDetail/TimePhase.html"
    };
    mapBase.searchShow = false;
    mapBase.searchs = "";
    mapBase.ami = true;
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

    //取得地圖
    NgMap.getMap().then(function (map) {
        mapBase.map = map;
    });

    //取得路口點位
    mapBase.getMakers = function () {
        $http({
            method: 'GET',
            url: 'json/GetIntersection.ashx'
        }).success(function (data, status, headers, config) {
            postToastr("取得路口點位完成");
            mapBase.mapBaseMakers = data;
            mapBase.mapMakers = mapBase.mapBaseMakers;
            mapBase.searchMarker = data;
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
    //取得選取點位詳細資料
    mapBase.getMakerData = function (event, id, number, selectMarker, my) {
        mapBase.clearVar();
        if (my != null) {
            if (mapBase.selectItem.searchMarker != "" && mapBase.selectItem.searchMarker != null) {
                mapBase.selectItem.searchMarker.Img = "img/map.png";
                mapBase.selectItem = my;
            }
            if (mapBase.selectItem.mapMaker != "" && mapBase.selectItem.mapMaker != null) {
                mapBase.selectItem.mapMaker.Img = "img/map.png";
                mapBase.selectItem = my;
            }
            if (mapBase.selectItem != "" && mapBase.selectItem != null) {

            }
            else {
                mapBase.selectItem = my;
            }
            my.mapMaker.Img = "img/maps.png";
        }
        if (selectMarker == null) {
            mapBase.selectIndex = number;
            mapBase.selectMarker = mapBase.mapBaseMakers[number];
        } else {
            mapBase.selectMarker = mapBase.mapBaseMakers[mapBase.selectIndex];
        }
        $http({
            method: 'GET',
            url: "json/GetMakerData.ashx",
            params: {
                id: id
            }
        }).success(function (data, status, headers, config) {
            mapBase.mapMaker = data;
            if (data == "") {
                mapBase.nowSelectVer = "";
            } else {
                mapBase.nowSelectVer = [{}];
                mapBase.nowVer = mapBase.mapMaker[0].ver;
                mapBase.nowSelectVer[0] = mapBase.mapMaker[0];
                if (mapBase.nowSelectVer[0].TwoVer) {
                    mapBase.loadTwoVer(mapBase.nowSelectVer[0].TwoVerNum);
                }
            }
            $('#RoadContentBox').modal('show');
        }).error(function (data, status, headers, config) {
            postToastr("取得路口基本資料失敗，請聯絡系統管理者！", "error");
        });
        mapBase.getMakerJob(id);
        mapBase.getMakerNotice(id);
        $('#oneselect').trigger('click');
    }

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
        }).error(function (data, status, headers, config) {
            postToastr("取得通報資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //以下路口新增三個判斷函式
    //點擊設置路口點位
    mapBase.setMaker = function (my) {
        mapBase.newMakerShow = true;
        var abc = mapBase.map.getCenter() + "";
        abc = abc.replace("(", "");
        abc = abc.replace(")", "");
        mapBase.mapMakers = [{
            IntersectionID: my.IntersectionID,
            Zone: my.Zone,
            RoadName: my.RoadName,
            ENumber: my.ENumber,
            Position: abc,
            Img: "img/map2.png"
        }];
        $("#bbbbb").stop().animate;
        $("#bbbbb").animate({ top: '0px' }, 200, 'swing');
    }

    //確定新增點位
    mapBase.setMakerOK = function (event) {
        $("#bbbbb").stop().animate;
        $("#bbbbb").animate({ top: '100px' }, 600, 'swing');
        mapBase.newMakerShow = false;
        mapBase.newPosition = mapBase.map.markers[0].getPosition() + "";
        mapBase.newPosition = mapBase.newPosition.replace("(", "").replace(")", "");
        var IntersectionID = mapBase.mapMakers[0].IntersectionID;
        var Zone = mapBase.mapMakers[0].Zone;
        var RoadName = mapBase.mapMakers[0].RoadName;
        var ENumber = mapBase.mapMakers[0].ENumber;
        mapBase.mapMakers[0].Position = mapBase.newPosition;
        $http({
            method: 'post',
            url: "json/PostUpdateBase.ashx?type=updateLoc",
            data: mapBase.mapMakers[0]
        }).success(function (data, status, headers, config) {
            mapBase.mapBaseMakers.push({
                Position: mapBase.newPosition,
                IntersectionID: IntersectionID,
                Zone: Zone,
                RoadName: RoadName,
                ENumber: ENumber,
                Img: "img/map.png"
            });
            mapBase.getMakers2();
            postToastr("設置路口點位成功");
        }).error(function (data, status, headers, config) {
            postToastr("設置路口點位失敗，請聯絡系統管理者！", "error");
        });
        mapBase.mapMakers = mapBase.mapBaseMakers;
    }

    //取消新增點位
    mapBase.setMakerNO = function (event) {
        $("#bbbbb").stop().animate;
        $("#bbbbb").animate({ top: '100px' }, 600, 'swing');
        mapBase.newMakerShow = false;
        mapBase.mapMakers = mapBase.mapBaseMakers;
    }


    //以下修改基本資料三個判斷函式
    //點擊修改基本資料
    mapBase.UpdateBase = function (event) {
        mapBase.showEdit.roadBase = true
        $('#baseInfo1').collapse('show');
        mapBase.firstSelectMarker.RoadName = mapBase.selectMarker.RoadName;
        mapBase.firstSelectMarker.Zone = mapBase.selectMarker.Zone;
        mapBase.firstSelectMarker.ENumber = mapBase.selectMarker.ENumber;
        if (mapBase.selectMarker.RoadName != "" && mapBase.selectMarker.RoadName != null) {
            var a = mapBase.selectMarker.RoadName + "";
            a = a.replace(/\<br \/>/g, "\n");
            mapBase.selectMarker.RoadName = a;
        }
    }


    //確定修改基本資料
    mapBase.UpdateBaseOK = function (event) {
        mapBase.showEdit.roadBase = false;
        $('#baseInfo1').collapse('hide');
        var a = mapBase.selectMarker.RoadName + "";
        a = a.replace(/\n/g, "<br />");
        mapBase.selectMarker.RoadName = a;
        $http({
            method: 'post',
            url: "json/PostUpdateBase.ashx?type=updateIntersectionBase",
            data: mapBase.selectMarker
        }).success(function (data, status, headers, config) {
            postToastr("修改基本資料成功");
        }).error(function (data, status, headers, config) {
            postToastr("修改基本資料失敗，請聯絡系統管理者！", "error");
        });
    }

    //取消修改基本資料
    mapBase.UpdateBaseNO = function (event) {
        $('#baseInfo1').collapse('hide');
        mapBase.showEdit.roadBase = false;
        mapBase.selectMarker.RoadName = mapBase.firstSelectMarker.RoadName;
        mapBase.selectMarker.Zone = mapBase.firstSelectMarker.Zone;
        mapBase.selectMarker.ENumber = mapBase.firstSelectMarker.ENumber;
    }


    //恢復初始值
    mapBase.clearVar = function (event) {
        mapBase.showEdit.roadBase = false;
        mapBase.mapMaker = ""
        mapBase.Job = "";
        mapBase.Notice = "";
        mapBase.selectMarker = "";
    }




    //以下移動路口點位四個判斷函式
    //點位移動開始時，先紀錄移動點位位置與編號
    mapBase.markerMoveStart = function (event, number, my) {
        if (my != null) {
            if (mapBase.selectItem.searchMarker != "" && mapBase.selectItem.searchMarker != null) {
                mapBase.selectItem.searchMarker.Img = "img/map.png";
                mapBase.selectItem = my;
            }
            if (mapBase.selectItem.mapMaker != "" && mapBase.selectItem.mapMaker != null) {
                mapBase.selectItem.mapMaker.Img = "img/map.png";
                mapBase.selectItem = my;
            }
            if (mapBase.selectItem != "" && mapBase.selectItem != null) {

            }
            else {
                mapBase.selectItem = my;
            }
            if (mapBase.newMakerShow) {

                my.mapMaker.Img = "img/map2.png";
            } else {
                my.mapMaker.Img = "img/maps.png";
            }
        }
        mapBase.move.position = mapBase.map.markers[number].getPosition();
        mapBase.move.number = number;
    }

    //點位移動停止時，跳出確認視窗
    mapBase.markerMoveEnd = function () {
        if (!mapBase.newMakerShow) {
            $('#moveCheckBox').modal('show')
        }
    }

    //確定點位移動
    mapBase.moveCheckOK = function () {
        mapBase.selectMarker = mapBase.mapBaseMakers[mapBase.move.number];
        var abc = mapBase.map.markers[mapBase.move.number].getPosition() + "";
        abc = abc.replace("(", "");
        abc = abc.replace(")", "");
        mapBase.selectMarker.Position = abc;
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
    }

    //取消點位移動，將點位返回原位置
    mapBase.moveCheckNo = function () {
        mapBase.map.markers[mapBase.move.number].setPosition(mapBase.move.position);
    }

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

    mapBase.placeChanged = function () {
        mapBase.place = this.getPlace();
        mapBase.map.setZoom(17);
        mapBase.map.setCenter(mapBase.place.geometry.location);
    }

    mapBase.keySearch = function (position) {
        if ($("#autocomplete").val().length > 0) {
            if (mapBase.ami) {
                $("#aaaaa").stop().animate;
                $("#aaaaa").animate({ left: '5px' }, 600, 'swing');
                mapBase.ami = false;
            }
        } else {
            if (!mapBase.ami) {
                $("#aaaaa").stop().animate;
                $("#aaaaa").animate({ left: '-220px' }, 600, 'swing');
                mapBase.ami = true;
            }
        }
    }
    mapBase.keySearchClose = function (position) {
        $("#aaaaa").animate({ left: '-220px' }, 600, 'swing');
    }

    mapBase.searchToPosition = function (my) {
        if (mapBase.selectItem.searchMarker != "" && mapBase.selectItem.searchMarker != null) {
            mapBase.selectItem.searchMarker.Img = "img/map.png";
            mapBase.selectItem = my;
        }
        if (mapBase.selectItem.mapMaker != "" && mapBase.selectItem.mapMaker != null) {
            mapBase.selectItem.mapMaker.Img = "img/map.png";
            mapBase.selectItem = my;
        }
        if (mapBase.selectItem != "" && mapBase.selectItem != null) {

        }
        else {
            mapBase.selectItem = my;
        }
        mapBase.address = my.searchMarker.Position;
        my.searchMarker.Img = "img/maps.png";
        mapBase.map.setZoom(18);
    }

    mapBase.zoomChange = function () {
        if (mapBase.map != null && mapBase.map != "") {
            if (mapBase.map.getZoom() < 17) {
                mapBase.mapMakers = [{ "Img": "img/space.png" }];
                mapBase.newMM = false;
            } else {
                mapBase.mapMakers = mapBase.mapBaseMakers;
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
                data: $scope.mapBase.nowSelectVer[0].IntersectionID
            }).success(function (data, status, headers, config) {
                postToastr("隱藏路口成功");
                $("#RoadContentBox").modal('hide');
                mapBase.getMakers();
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

    mapBase.getMakers();    //載入點位
    mapBase.getMakers2();
});

//HtmlJS
function openNew() {
    window.open('cc.html', '_blank');
}
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


app.filter('cleanBr', function () {
    return function (str) {
        if (!!str) {
            return str.replace(/\<br \/>/g, "\n　　　");
        }
    };
});
app.filter('toSpace', function () {
    return function (str) {
        if (!!str) {
            return str.replace(/\<br \/>/g, "<br />　　　");
        }
    };
});
app.filter('searchMapKey', function () {
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