app.controller('roadBaseData', function ($scope, NgMap, $http) {

    //相關初始宣告給值
    var roadBase = this;
    roadBase.baseData = false;                       //基本資料區是否在編輯 
    roadBase.weekType = false;                       //星期資料區是否在編輯 
    roadBase.allEditIcno = false;                     //是否顯示編輯按鈕    
    roadBase.tipss = "";                             //切換中提示文字    
    roadBase.insertValue = {};                       //新增暫存區
    roadBase.editBeforeValue = ""                    //編輯前的資料暫存區
    roadBase.selectBaseData = "";                    //編輯前的原始資料
    roadBase.selectTimeIntervalType = "";            //紀錄目前編輯的時段型態
    roadBase.selectValue = "";                       //下拉選單變數存放用
    roadBase.selectTimePhase1 = "";
    roadBase.selectTimePhaseIndex = "";
    roadBase.selectTimePhaseImg = "";
    roadBase.timePlanDetail1 = true;
    roadBase.timePlanDetail2 = true;
    roadBase.timePlanDetail3 = false;
    roadBase.timePlanDetail4 = false;
    roadBase.timePlanDetail5 = false;
    roadBase.timePlanDetail6 = false;

    //時段型態時間選單
    roadBase.selectHour = [
        "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12",
        "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"
    ];

    //時段型態時間選單
    roadBase.selectMinute = [
        "00", "10", "20", "30", "40", "50"
    ];

    //紀錄切換版本
    roadBase.changSelectIndex = function (my) {
        $scope.mapBase.nowVer = my.ver;
        $scope.mapBase.getMarkerData(null, my.IntersectionDetailID);
        roadBase.tipss = "";
        roadBase.toEditReset();
    }

    //切換至第二版本
    roadBase.changeTwoVer = function () {
        if ($scope.mapBase.nowSelectVer[0].TwoVer2 == "1") {
            $scope.mapBase.getTwoMarker(null, $scope.mapBase.nowSelectVer[0].IntersectionDetailID);
            roadBase.tipss = "";
        } else {
            $scope.mapBase.getMarkerData(null, $scope.mapBase.nowSelectVer[0].TwoVer2);
            roadBase.tipss = "切換中";
        }
        roadBase.toEditReset();
    }

    //修改基本資料
    roadBase.updateRoadBase = function (type, id) {
        if (type == "edit") {
            roadBase.baseData = true;
            roadBase.toEditReset("edit", $scope.mapBase.nowSelectVer[0]);
            $scope.mapBase.nowSelectVer[0].Remark = changeBrN("br", $scope.mapBase.nowSelectVer[0].Remark);
            $('#roadBaseInfo1').collapse('show');
        } else if (type == "ok") {
            roadBase.baseData = false;
            roadBase.toEditReset();
            $('#roadBaseInfo1').collapse('hide');
            $scope.mapBase.nowSelectVer[0].Remark = changeBrN("n", $scope.mapBase.nowSelectVer[0].Remark);
            roadBase.selectBaseData = angular.copy($scope.mapBase.mapMarkerData);
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=updateIntersectionDeta",
                data: roadBase.selectBaseData
            }).success(function (data, status, headers, config) {
                postToastr("基本資料修改成功");
            }).error(function (data, status, headers, config) {
                postToastr("修改基本資料失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            roadBase.baseData = false;
            roadBase.toEditReset('resetRoadBase');
            $('#roadBaseInfo1').collapse('hide');
        }
    }

    //修改星期類型
    roadBase.updateWeekType = function (type, id) {
        if (type == "edit") {
            roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getWeekSelect");
            roadBase.weekType = true;
            $("#weekType1").collapse('show');
            roadBase.toEditReset("edit", $scope.mapBase.nowSelectVer[0].WeekType);
        } else if (type == "ok") {
            roadBase.weekType = false;
            $("#weekType1").collapse('hide');
            roadBase.toEditReset();
            roadBase.selectBaseData = angular.copy($scope.mapBase.mapMarkerData.WeekType);
            roadBase.selectBaseData.twoVer2 = $scope.mapBase.mapMarkerData.TwoVer2;
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=updateWeekType",
                data: roadBase.selectBaseData
            }).success(function (data, status, headers, config) {
                postToastr("星期類型修改成功");
            }).error(function (data, status, headers, config) {
                postToastr("修改基本資料失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            roadBase.weekType = false;
            $("#weekType1").collapse('hide');
            roadBase.toEditReset('resetWeekType');
        }
    }

    //新增時段型態
    roadBase.newTimeType = function (type, id) {
        if (type == "edit") {
            var count = $scope.mapBase.nowSelectVer[0].TimeIntervalType.length;
            if (count < 3) {
                $('#newTimeType1').collapse('show');
                roadBase.toEditReset("edit");
            } else {
                alert("時段型態最多三個，請刪除後再新增！")
            }
        } else if (type == "ok") {
            var res = roadBase.toVerify("onlyTwoNumber", roadBase.insertValue.timeType);
            var err = "請輸入數字，並小於三位數！"
            if (roadBase.insertValue.timeType == "" || roadBase.insertValue.timeType == null) {
                res = false;
                err = "請勿空白！";
            }
            var temp = $scope.mapBase.nowSelectVer[0].TimeIntervalType;
            for (var i = 0; i < temp.length; i++) {
                if (temp[i].TimeType == roadBase.insertValue.timeType) {
                    res = false;
                    err = "請勿輸入重覆的時段型態！";
                }
            }
            if (res) {
                $('#newTimeType1').collapse('hide');
                var timeType = roadBase.insertValue.timeType;
                roadBase.toEditReset();
                $http({
                    method: 'post',
                    url: "json/PostUpdateVer.ashx?type=insertTimeIntervalType",
                    data: $scope.mapBase.nowSelectVer[0].IntersectionDetailID + "," + timeType
                }).success(function (data, status, headers, config) {
                    postToastr("時段類型新增成功");
                    roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getTimeIntervalType");
                }).error(function (data, status, headers, config) {
                    postToastr("時段類型新增失敗，請聯絡系統管理者！", "error");
                });
            }
            else {
                alert(err);
            }
        } else if (type == "no") {
            $('#newTimeType1').collapse('hide');
            roadBase.toEditReset();
        }
    }

    //刪除時段型態
    roadBase.deletTimeType = function (type, index, id) {
        if (type == "edit") {
            $('#timeTypeShow' + id).collapse('hide').on('hidden.bs.collapse', function () {
                $('#timeTypeDelete' + id).collapse('show');
                $('#timeTypeShow' + id).off('hidden.bs.collapse');
            });
            roadBase.toEditReset("edit");
        } else if (type == "ok") {
            $('#timeTypeDelete' + id).collapse('hide').on('hidden.bs.collapse', function () {
                $('#timeTypeShow' + id).collapse('show');
                $('#timeTypeDelete' + id).off('hidden.bs.collapse');
            });
            roadBase.toEditReset();
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=deleteTimeType",
                data: id
            }).success(function (data, status, headers, config) {
                postToastr("時段類型刪除成功");
                $scope.mapBase.nowSelectVer[0].TimeIntervalType.splice(index, 1);
            }).error(function (data, status, headers, config) {
                postToastr("時段類型刪除失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            roadBase.toEditReset();
            $('#timeTypeDelete' + id).collapse('hide').on('hidden.bs.collapse', function () {
                $('#timeTypeShow' + id).collapse('show');
                $('#timeTypeDelete' + id).off('hidden.bs.collapse');
            });
        }
    }

    //修改時段型態內容
    roadBase.editTypeTime = function (type, index, id) {
        if (type == "edit") {
            roadBase.toEditReset("edit", $scope.mapBase.nowSelectVer[0].TimeIntervalType);
            roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getSelect");
            roadBase.selectTimeIntervalType = index;
            $('#timeTypeShow' + id).collapse('hide').on('hidden.bs.collapse', function () {
                $('#timeTypeEdit' + id).collapse('show');
                $('#timeTypeShow' + id).off('hidden.bs.collapse');
            });
        }
        else if (type == "minus") {
            var count = $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail.length;
            if (count - 1 >= 0) {
                $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail.splice(count - 1, 1);
            }
        }
        else if (type == "plus") {
            var cont = $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail.length;
            if (cont < 6) {
                $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail.push({});
                var num = $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail.length;
                $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail[num - 1].Hour = "00";
                $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail[num - 1].Minute = "00";
                $scope.mapBase.nowSelectVer[0].TimeIntervalType[roadBase.selectTimeIntervalType].TimeIntervalTypeDetail[num - 1].TimePlanSN = roadBase.selectValue.TimePlan[0];
            } else {
                alert("最多六個，請刪除後再新增！")
            }
        }
        else if (type == "ok") {
            roadBase.toEditReset();
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=editTimeIntervalTypeDetail",
                data: $scope.mapBase.nowSelectVer[0].TimeIntervalType[index]
            }).success(function (data, status, headers, config) {
                postToastr("修改時段類型內容成功");
            }).error(function (data, status, headers, config) {
                postToastr("修改時段類型內容失敗，請聯絡系統管理者！", "error");
            });
            $('#timeTypeEdit' + id).collapse('hide').on('hidden.bs.collapse', function () {
                $('#timeTypeShow' + id).collapse('show');
                $('#timeTypeEdit' + id).off('hidden.bs.collapse');
            });
        }
        else if (type == "no") {
            roadBase.reLoad(id, "getTimeIntervalTypeDetail", index);
            roadBase.toEditReset();
            $('#timeTypeEdit' + id).collapse('hide').on('hidden.bs.collapse', function () {
                $('#timeTypeShow' + id).collapse('show');
                $('#timeTypeEdit' + id).off('hidden.bs.collapse');
            });
        }
    }

    //新增時制計劃內容
    roadBase.newTimePlan = function (type) {
        if (type == "new") {
            var count = $scope.mapBase.nowSelectVer[0].TimePlan.length;
            if (count < 5) {
                $('#insertTimePlan1').collapse('show');
                roadBase.toEditReset("edit");
            } else {
                alert("計劃最多五個，請刪除後再新增！")
            }
        }
        else if (type == "ok") {
            var res = roadBase.toVerify("onlyTwoNumber", roadBase.insertValue.TimePlanSN);
            var res2 = roadBase.toVerify("onlyTwoNumberSpace", roadBase.insertValue.TimeDiff);
            var res3 = roadBase.toVerify("twoNumberOrEnglish", roadBase.insertValue.TimePhaseSN);
            var err = "";
            var res4 = true;
            if (!res) {
                res4 = false;
                err = "計劃編號不可空白或非數字";
            }
            if (!res2) {
                res4 = false;
                err = "時差不可為非數字";
            }
            if (!res3) {
                res4 = false;
                err = "時相編號不可空白或非數字英文";
            }
            var temp = $scope.mapBase.nowSelectVer[0].TimePlan;
            for (var i = 0; i < temp.length; i++) {
                if (temp[i].TimePlanSN == roadBase.insertValue.TimePlanSN) {
                    res4 = false;
                    err = "計劃編號不可重覆";
                }
            }
            if (res4) {
                $('#insertTimePlan1').collapse('hide');
                roadBase.insertValue.id = $scope.mapBase.nowSelectVer[0].IntersectionDetailID;
                $http({
                    method: 'post',
                    url: "json/PostUpdateVer.ashx?type=timePlanInsert",
                    data: roadBase.insertValue
                }).success(function (data, status, headers, config) {
                    postToastr("新增計劃內容成功");
                    roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getTimePlan");
                    roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getTimePhase");
                    roadBase.toEditReset();
                }).error(function (data, status, headers, config) {
                    postToastr("新增計劃內容失敗，請聯絡系統管理者！", "error");
                    roadBase.toEditReset();
                });
            } else {
                alert(err);
            }
        } else if (type == "no") {
            $('#insertTimePlan1').collapse('hide');
            roadBase.toEditReset();
        }
    }

    //修改時制計劃內容
    roadBase.editTypePlan = function (type, index, id) {
        if (type == "edit") {
            if ($scope.mapBase.nowSelectVer[0].TimePlan.length > 0) {
                $('#timePlanShow1').collapse('hide').on('hidden.bs.collapse', function () {
                    $('#timePlanEdit1').collapse('show');
                    $('#timePlanShow1').off('hidden.bs.collapse');
                });
                $('#timePhaseToShow1').collapse('hide');
                $('.TimePhaseShowSN').collapse('hide').on('hidden.bs.collapse', function () {
                    $('.TimePhaseEditSN').collapse('show');
                    $('.TimePhaseShowSN').off('hidden.bs.collapse');
                });
                roadBase.toEditReset("edit", $scope.mapBase.nowSelectVer[0].TimePlan);
            } else {
                alert("請先新增計劃");
            }
        }
        else if (type == "delete") {
            $scope.mapBase.nowSelectVer[0].TimePlan.splice(index, 1);
            for (var i = 0; i < $scope.mapBase.nowSelectVer[0].TimePhase.length; i++) {
                $scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail.splice(index, 1);
            }
        }
        else if (type == "ok") {
            var resu = true;
            var err = "";
            for (var key in $scope.mapBase.nowSelectVer[0].TimePlan) {
                var res = roadBase.toVerify("onlyTwoNumber", $scope.mapBase.nowSelectVer[0].TimePlan[key].TimePlanSN);
                if (!res) {
                    resu = false;
                    err = "計劃編號不可空白或非數字";
                    break;
                }
                res = roadBase.toVerify("twoNumberOrEnglish", $scope.mapBase.nowSelectVer[0].TimePlan[key].TimePhaseSN);
                if (!res) {
                    resu = false;
                    err = "時相編號不可空白或非數字英文";
                    break;
                }
                res = roadBase.toVerify("onlyTwoNumberSpace", $scope.mapBase.nowSelectVer[0].TimePlan[key].TimeDiff);
                if (!res) {
                    resu = false;
                    err = "時差不可為非數字";
                    break;
                }
            }
            if (resu) {
                $('#timePlanEdit1').collapse('hide').on('hidden.bs.collapse', function () {
                    $('#timePlanShow1').collapse('show');
                    $('#timePlanEdit1').off('hidden.bs.collapse');
                });
                $('#timePhaseToShow1').collapse('show');
                $('.TimePhaseEditSN').collapse('hide').on('hidden.bs.collapse', function () {
                    $('.TimePhaseShowSN').collapse('show');
                    $('.TimePhaseEditSN').off('hidden.bs.collapse');
                });
                roadBase.toEditReset();
                $http({
                    method: 'post',
                    url: "json/PostUpdateVer.ashx?type=editTimePlan",
                    data: $scope.mapBase.nowSelectVer[0]
                }).success(function (data, status, headers, config) {
                    postToastr("修改計劃內容成功");
                    roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getTimePlan");
                }).error(function (data, status, headers, config) {
                    postToastr("修改計劃內容失敗，請聯絡系統管理者！", "error");
                });
            } else {
                alert(err);
            }
        }
        else if (type == "no") {
            roadBase.toEditReset();
            $('#timePlanEdit1').collapse('hide').on('hidden.bs.collapse', function () {
                $('#timePlanShow1').collapse('show');
                $('#timePlanEdit1').off('hidden.bs.collapse');
            });
            $('#timePhaseToShow1').collapse('show');
            $('.TimePhaseEditSN').collapse('hide').on('hidden.bs.collapse', function () {
                $('.TimePhaseShowSN').collapse('show');
                $('.TimePhaseEditSN').off('hidden.bs.collapse');
            });
            $scope.mapBase.nowSelectVer[0].TimePlan = angular.copy(roadBase.editBeforeValue);
            roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getTimePhase");
        }
    }

    //新增時相
    roadBase.newTimePhase = function (type, id) {
        if (type == "edit") {
            var count = $scope.mapBase.nowSelectVer[0].TimePhase.length;
            if (count < 6) {
                $("#newTimePhase1").collapse('show');
                roadBase.toEditReset("edit");
            } else {
                alert("時相最多六個，請刪除後再新增！")
            }
        } else if (type == "ok") {
            $("#newTimePhase1").collapse('hide');
            roadBase.toEditReset();
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=insertTimePhase",
                data: $scope.mapBase.nowSelectVer[0].IntersectionDetailID
            }).success(function (data, status, headers, config) {
                postToastr("時段類型新增成功");
                roadBase.reLoad($scope.mapBase.nowSelectVer[0].IntersectionDetailID, "getTimePhase");
            }).error(function (data, status, headers, config) {
                postToastr("時段類型新增失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            $("#newTimePhase1").collapse('hide');
            roadBase.toEditReset();
        }
    }

    //刪除時相
    roadBase.deletTimePhase = function (type, index, id) {
        if (type == "edit") {
            roadBase.toEditReset("edit");
            $("#timePhaseShow" + id).collapse('hide').on('hidden.bs.collapse', function () {
                $("#timePhaseDelete" + id).collapse('show');
                $("#timePhaseShow" + id).off('hidden.bs.collapse');
            });
        } else if (type == "ok") {
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=deleteTimePhase",
                data: id
            }).success(function (data, status, headers, config) {
                postToastr("時相刪除成功");
                $scope.mapBase.nowSelectVer[0].TimePhase.splice(index, 1);
            }).error(function (data, status, headers, config) {
                postToastr("時相刪除失敗，請聯絡系統管理者！", "error");
            });
            roadBase.toEditReset('resetTimePhase');
        } else if (type == "no") {
            roadBase.toEditReset();
            $("#timePhaseDelete" + id).collapse('hide').on('hidden.bs.collapse', function () {
                $("#timePhaseShow" + id).collapse('show');
                $("#timePhaseDelete" + id).off('hidden.bs.collapse');
            });
        }
    }

    //修改時相內容
    roadBase.editTimePhase = function (type, index, id) {
        if (type == "edit") {
            roadBase.selectTimePhase1 = id;
            roadBase.selectTimePhaseIndex = index;
            roadBase.selectTimePhaseImg = $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].ImgSrc;
            $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].TimePhaseRoad = changeBrN("br", $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].TimePhaseRoad);
            $("#timePhaseShow" + roadBase.selectTimePhase1).collapse('hide').on('hidden.bs.collapse', function () {
                $("#timePhaseEdit" + roadBase.selectTimePhase1).collapse('show');
                $("#timePhaseShow" + roadBase.selectTimePhase1).off('hidden.bs.collapse');
            });
            roadBase.toEditReset("edit");
        } else if (type == "ok") {
            roadBase.toEditReset();
            $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].TimePhaseRoad = changeBrN("n", $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].TimePhaseRoad);
            $("#timePhaseEdit" + roadBase.selectTimePhase1).collapse('hide').on('hidden.bs.collapse', function () {
                $("#timePhaseShow" + roadBase.selectTimePhase1).collapse('show');
                $("#timePhaseEdit" + roadBase.selectTimePhase1).off('hidden.bs.collapse');
            });
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=editTimePhase",
                data: $scope.mapBase.nowSelectVer[0].TimePhase[index]
            }).success(function (data, status, headers, config) {
                postToastr("修改時段類型內容成功");
                roadBase.reLoad(id, index, "getTimePhaseDetail");
            }).error(function (data, status, headers, config) {
                postToastr("修改時段類型內容失敗，請聯絡系統管理者！", "error");
            });
        }
        else if (type == "no") {
            roadBase.toEditReset();
            $("#timePhaseEdit" + roadBase.selectTimePhase1).collapse('hide').on('hidden.bs.collapse', function () {
                $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].ImgSrc = roadBase.selectTimePhaseImg;
                roadBase.reLoad(id, index, "getTimePhaseDetail");
                $("#timePhasex" + roadBase.selectTimePhase1).attr("src", roadBase.selectTimePhaseImg);
                $("#timePhaseShow" + roadBase.selectTimePhase1).collapse('show');
                $("#timePhaseEdit" + roadBase.selectTimePhase1).off('hidden.bs.collapse');
            });
        }
    }

    //新增雙版本
    roadBase.newTwoVer = function (type, id) {
        if (type == "edit") {
            $('#newTwoVer1').collapse('toggle');
            roadBase.toEditReset("edit");
        } else if (type == "ok") {
            $("#loadDiv").show();
            roadBase.toEditReset();
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=newTwoVer",
                data: $scope.mapBase.nowSelectVer[0]
            }).success(function (data, status, headers, config) {
                $("#loadDiv").hide();
                postToastr("新增異動版本成功");
                $scope.mapBase.nowSelectVer[0].TwoVer = true;
                $scope.mapBase.nowSelectVer[0].TwoVerNum = data;
                $scope.mapBase.nowSelectVer[0].ClassTwo = "TwoVer";
                $scope.mapBase.nowSelectVer[0].TwoVer2 = data;
            }).error(function (data, status, headers, config) {
                $("#loadDiv").hide();
                postToastr("新增異動版本失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            roadBase.toEditReset();
        }
    }

    //新增異動版本
    roadBase.newVer = function (type, id) {
        if (type == "edit") {
            roadBase.toEditReset("edit");
            $('#newVer1').collapse('toggle');
        } else if (type == "ok") {
            roadBase.toEditReset();
            $('#newVer1').collapse('toggle');
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=newVer",
                data: $scope.mapBase.selectMarker.IntersectionID
            }).success(function (data, status, headers, config) {
                postToastr("新增異動版本成功");
                $scope.mapBase.getMarkerNewVer();
            }).error(function (data, status, headers, config) {
                postToastr("新增異動版本失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            roadBase.toEditReset();
        }
    }

    //刪除此版本
    roadBase.verDelete = function (type, id) {
        if (type == "edit") {
            if ($scope.mapBase.nowSelectVer[0].TwoVer2 == "1") {
                $('#verDelete1').collapse('toggle');
                roadBase.toEditReset("edit");
            } else if ($scope.mapBase.nowVer == 1) {
                alert("第一版不提供刪除功能");
            } else {
                roadBase.toEditReset("edit");
                $('#verDelete1').collapse('toggle');
            }
        } else if (type == "ok") {
            roadBase.toEditReset();
            $('#verDelete1').collapse('toggle');
            $http({
                method: 'post',
                url: "json/PostUpdateVer.ashx?type=verDelete",
                data: $scope.mapBase.nowSelectVer[0]
            }).success(function (data, status, headers, config) {
                postToastr("刪除此版本成功");
                roadBase.tipss = "";
                $scope.mapBase.getMarkerNewVer();
            }).error(function (data, status, headers, config) {
                postToastr("刪除此版本失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "no") {
            roadBase.toEditReset();
            $('#verDelete1').collapse('toggle');
        }
    }

    //自動計算PH
    roadBase.TimePhaseDetailChange = function (type, TimePhaseDetail) {
        if (type == "PH") {
            var PH = parseInt(TimePhaseDetail.PH);
            var Y = parseInt(TimePhaseDetail.Y);
            var R = parseInt(TimePhaseDetail.R);
            if (isNaN(PH)) {
                PH = 0;
            }
            if (isNaN(Y)) {
                Y = 0;
            }
            if (isNaN(R)) {
                R = 0;
            }
            TimePhaseDetail.G = PH - Y - R;
        } else if (type = "G") {
            var G = parseInt(TimePhaseDetail.G);
            var Y = parseInt(TimePhaseDetail.Y);
            var R = parseInt(TimePhaseDetail.R);
            if (isNaN(G)) {
                G = 0;
            }
            if (isNaN(Y)) {
                Y = 0;
            }
            if (isNaN(R)) {
                R = 0;
            }
            TimePhaseDetail.PH = G + Y + R;
        }
    }

    //亂寫一堆~~有空再好好想新的演算法~~
    roadBase.moveTimePlan = function (type) {
        var num = $scope.mapBase.nowSelectVer[0].TimePhase.length;
        if (type == "left") {
            if (num == 0) {

            } else if (num == 1) {

            } else if (num == 2) {

            } else if (num == 3) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail3 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail3 = false;
                }
            } else if (num == 4) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail3 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail2 = false;
                    roadBase.timePlanDetail4 = true;
                } else if (roadBase.timePlanDetail3 && roadBase.timePlanDetail4) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail2 = true;
                    roadBase.timePlanDetail3 = false;
                    roadBase.timePlanDetail4 = false;
                }
            } else if (num == 5) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail3 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail2 = false;
                    roadBase.timePlanDetail4 = true;
                } else if (roadBase.timePlanDetail3 && roadBase.timePlanDetail4) {
                    roadBase.timePlanDetail3 = false;
                    roadBase.timePlanDetail5 = true;
                } else if (roadBase.timePlanDetail4 && roadBase.timePlanDetail5) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail2 = true;
                    roadBase.timePlanDetail4 = false;
                    roadBase.timePlanDetail5 = false;
                }
            } else if (num == 6) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail3 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail2 = false;
                    roadBase.timePlanDetail4 = true;
                } else if (roadBase.timePlanDetail3 && roadBase.timePlanDetail4) {
                    roadBase.timePlanDetail3 = false;
                    roadBase.timePlanDetail5 = true;
                } else if (roadBase.timePlanDetail4 && roadBase.timePlanDetail5) {
                    roadBase.timePlanDetail4 = false;
                    roadBase.timePlanDetail6 = true;
                } else if (roadBase.timePlanDetail5 && roadBase.timePlanDetail6) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail2 = true;
                    roadBase.timePlanDetail5 = false;
                    roadBase.timePlanDetail6 = false;
                }
            }
        } else if (type == "right") {
            if (num == 0) {

            } else if (num == 1) {

            } else if (num == 2) {

            } else if (num == 3) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {

                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail3 = true;

                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail3 = false;
                }
            } else if (num == 4) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail2 = false;
                    roadBase.timePlanDetail3 = true;
                    roadBase.timePlanDetail4 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail3 = false;
                } else if (roadBase.timePlanDetail3 && roadBase.timePlanDetail4) {
                    roadBase.timePlanDetail2 = true;
                    roadBase.timePlanDetail4 = false;
                }
            } else if (num == 5) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail2 = false;
                    roadBase.timePlanDetail4 = true;
                    roadBase.timePlanDetail5 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail3 = false;
                } else if (roadBase.timePlanDetail3 && roadBase.timePlanDetail4) {
                    roadBase.timePlanDetail2 = true;
                    roadBase.timePlanDetail4 = false;
                } else if (roadBase.timePlanDetail4 && roadBase.timePlanDetail5) {
                    roadBase.timePlanDetail3 = true;
                    roadBase.timePlanDetail5 = false;
                }
            } else if (num == 6) {
                if (roadBase.timePlanDetail1 && roadBase.timePlanDetail2) {
                    roadBase.timePlanDetail1 = false;
                    roadBase.timePlanDetail2 = false;
                    roadBase.timePlanDetail5 = true;
                    roadBase.timePlanDetail6 = true;
                } else if (roadBase.timePlanDetail2 && roadBase.timePlanDetail3) {
                    roadBase.timePlanDetail1 = true;
                    roadBase.timePlanDetail3 = false;
                } else if (roadBase.timePlanDetail3 && roadBase.timePlanDetail4) {
                    roadBase.timePlanDetail2 = true;
                    roadBase.timePlanDetail4 = false;
                } else if (roadBase.timePlanDetail4 && roadBase.timePlanDetail5) {
                    roadBase.timePlanDetail3 = true;
                    roadBase.timePlanDetail5 = false;
                } else if (roadBase.timePlanDetail5 && roadBase.timePlanDetail6) {
                    roadBase.timePlanDetail4 = true;
                    roadBase.timePlanDetail6 = false;
                }
            }
        }
    }

    //上傳圖片
    roadBase.uploadImg = function (my) {
        var f = document.getElementById(my.id);
        var fileSize = f.files.item(0).size;
        var fileName = f.files.item(0).name;
        var extIndex = fileName.lastIndexOf('.');
        if (extIndex != -1) {
            fileName = fileName.substr(extIndex + 1, fileName.length);
        }

        if (fileSize < 3000000) {
            var re = /(jpg|gif|png|jpeg|bmp)$/i;  //允許的圖片副檔名 
            if (!re.test(fileName)) {
                alert("只允許上傳圖片檔");
            } else {
                $("#ajaxImg" + roadBase.selectTimePhase1).ajaxSubmit(
                    {
                        beforeSubmit: function () { },
                        success: function (resp, st, xhr, $form) {
                            if (resp != "err") {
                                $scope.mapBase.nowSelectVer[0].TimePhase[roadBase.selectTimePhaseIndex].ImgSrc = "upload/timePhaseImg/" + resp;
                                $("#timePhaseImg" + roadBase.selectTimePhase1).collapse('hide').on('hidden.bs.collapse', function () {
                                    $("#timePhase" + roadBase.selectTimePhase1).attr("src", "upload/timePhaseImg/" + resp);
                                    $("#timePhaseImg" + roadBase.selectTimePhase1).collapse('show');
                                    $("#timePhaseImg" + roadBase.selectTimePhase1).off('hidden.bs.collapse');
                                });
                            }
                        }
                    });
            }
        } else {
            alert("檔案超過3MB，請重新選擇！");
            f.value = "";
        }
    }

    //驗證
    roadBase.toVerify = function (type, value) {
        if (type == "onlyTwoNumberSpace") {
            var pattern = /^[0-9]{1,2}$/;
            if (value == "") {
                return true;
            } else if (value == null) {
                return true;
            }
            return pattern.test(value);
        } else if (type == "notEnglish") {
            var pattern = /[a-zA-Z]/;
            return pattern.test(value);
        } else if (type == "onlyThreeNumber") {
            var pattern = /^[0-9]{1,3}$/;
            if (value == "") {
                return true;
            } else if (value == null) {
                return true;
            }
            return pattern.test(value);
        } else if (type == "onlyTwoNumber") {
            var pattern = /^[0-9]{1,2}$/;
            return pattern.test(value);
        } else if (type == "twoNumberOrEnglish") {
            var pattern = /^[0-9A-Za-z]{1,2}$/;
            return pattern.test(value);
        }
    }

    //重置頁面資料
    roadBase.reLoad = function (id, type, index) {
        $http({
            method: 'post',
            url: "json/GetIntersectionDetail.ashx?type=" + type,
            data: id
        }).success(function (data, status, headers, config) {
            if (type == "getTimeIntervalTypeDetail") {
                $scope.mapBase.nowSelectVer[0].TimeIntervalType[index].TimeIntervalTypeDetail = data;
            } else if (type == "getTimePlan") {
                $scope.mapBase.nowSelectVer[0].TimePlan = data;
            } else if (type == "getTimeIntervalType") {
                $scope.mapBase.nowSelectVer[0].TimeIntervalType = data;
            } else if (type == "getTimePhase") {
                $scope.mapBase.nowSelectVer[0].TimePhase = data;
            } else if (type == "getTimePhaseDetail") {
                $scope.mapBase.nowSelectVer[0].TimePhase[index].TimePhaseRoad = data.TimePhaseRoad;
                $scope.mapBase.nowSelectVer[0].TimePhase[index].ImgSrc = data.ImgSrc;
            } else if (type == "getSelect") {
                roadBase.selectValue = data;
            } else if (type == "getWeekSelect") {
                roadBase.selectValue = data;
                if ($scope.mapBase.nowSelectVer[0].WeekType.Monday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Monday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Monday = roadBase.selectValue.WeekType[0];
                }
                if ($scope.mapBase.nowSelectVer[0].WeekType.Tuesday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Tuesday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Tuesday = roadBase.selectValue.WeekType[0];
                }
                if ($scope.mapBase.nowSelectVer[0].WeekType.Wednesday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Wednesday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Wednesday = roadBase.selectValue.WeekType[0];
                }
                if ($scope.mapBase.nowSelectVer[0].WeekType.Thursday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Thursday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Thursday = roadBase.selectValue.WeekType[0];
                }
                if ($scope.mapBase.nowSelectVer[0].WeekType.Friday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Friday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Friday = roadBase.selectValue.WeekType[0];
                }
                if ($scope.mapBase.nowSelectVer[0].WeekType.Saturday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Saturday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Saturday = roadBase.selectValue.WeekType[0];
                }
                if ($scope.mapBase.nowSelectVer[0].WeekType.Sunday == "" || $scope.mapBase.nowSelectVer[0].WeekType.Sunday == null) {
                    $scope.mapBase.nowSelectVer[0].WeekType.Sunday = roadBase.selectValue.WeekType[0];
                }
            }
        }).error(function (data, status, headers, config) {
            postToastr("同步失敗，請聯絡系統管理者！", "warning");
        });
    }

    //下載Excel
    roadBase.downloadExcel = function (id) {
        document.location.href = "intersectionDetailExcel.ashx?id=" + id;
    }

    //連結至動線規劃
    roadBase.goToPhase = function (id) {
        var res = true;
        var err = "";
        if ($scope.mapBase.nowSelectVer[0].TimePlan.length == 0) {
            res = false;
            err = "請先新增計劃！"
        }
        for (var i = 0; i < $scope.mapBase.nowSelectVer[0].TimePhase.length; i++) {
            for (var k = 0; k < $scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail.length; k++) {
                if ($scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail[k].G == 0) {
                    res = false;
                    err = "請先將計劃" + $scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail[k].TimePlanSN + "第" + (i + 1) + "時相的G改成大於0！"
                    break;
                }
                if ($scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail[k].Y == 0) {
                    res = false;
                    err = "請先將計劃" + $scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail[k].TimePlanSN + "第" + (i + 1) + "時相的Y改成大於0！"
                    break;
                }
                if ($scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail[k].R == 0) {
                    res = false;
                    err = "請先將計劃" + $scope.mapBase.nowSelectVer[0].TimePhase[i].TimePhaseDetail[k].TimePlanSN + "第" + (i + 1) + "時相的R改成大於0！"
                    break;
                }
            }
        }
        if (res) {
            window.open("trafficlightSim/TrafficLight.html?intersectionDetailId=" + id, 'traff');
        } else {
            alert(err);
        }
    }

    //重置相關參數
    roadBase.toEditReset = function (type, value) {
        if (type == "edit") {
            if (value) {
                roadBase.editBeforeValue = angular.copy(value);
            }
            roadBase.allEditIcno = false;
        } else if (type == "resetRoadBase") {
            roadBase.allEditIcno = false;
            $scope.mapBase.nowSelectVer[0].Controller = roadBase.editBeforeValue.Controller;
            $scope.mapBase.nowSelectVer[0].Remark = roadBase.editBeforeValue.Remark;
            $scope.mapBase.nowSelectVer[0].VersionDate = roadBase.editBeforeValue.VersionDate;
            $scope.mapBase.nowSelectVer[0].Src = roadBase.editBeforeValue.Src;
            $scope.mapBase.nowSelectVer[0].GPS = roadBase.editBeforeValue.GPS;
        } else if (type == "resetWeekType") {
            roadBase.allEditIcno = false;
            $scope.mapBase.nowSelectVer[0].WeekType = angular.copy(roadBase.editBeforeValue);
        } else if (type == "resetTimePhase") {
            roadBase.allEditIcno = false;
            roadBase.timePlanDetail1 = true;
            roadBase.timePlanDetail2 = true;
            roadBase.timePlanDetail3 = false;
            roadBase.timePlanDetail4 = false;
            roadBase.timePlanDetail5 = false;
            roadBase.timePlanDetail6 = false;
        } else {
            roadBase.allEditIcno = false;
        }
        roadBase.insertValue = {};
    }

    //當路口基本資料視窗被關閉時
    $('#RoadContentBox').on('hidden.bs.modal', function (e) {
        if ($scope.editRoadBase) {                      //還原上方基本資料修改
            $scope.editRoadBase = false;
            $scope.mapBase.updateBase('no');
        }
        $('#newTwoVer1').collapse('hide');              //隱藏新增雙版本
        roadBase.baseData = false;                      //隱藏修改基本資料
        roadBase.weekType = false;                      //隱藏修改星期
        roadBase.tipss = "";                            //重置切換提示        
        $("#roadBaseDatali").addClass("active");        //重置選擇為時制資料
        $("#noticeli").removeClass("active");           //移除通報紀錄選擇
        $("#jobli").removeClass("active");              //移除派工紀錄選擇
        $('#roadBaseDataPage').collapse('show');        //打開時制資料頁面
        $('#noticePage').collapse('hide');              //隱藏通報紀錄頁面
        $('#jobPage').collapse('hide');                 //隱藏派工紀錄頁面
        $scope.mapBase.nowVer = "";                     //重置現在版本提示
        $('#baseInfo1').collapse('hide');               //隱藏上方基本資料修改
        $('#roadBaseInfo1').collapse('hide');           //隱藏基本資料修改
        $("#weekType1").collapse('hide');               //隱藏星期資料修改
        $('#jobUpdate1').collapse('hide');              //隱藏通報紀錄修改
        $('#jobInster1').collapse('hide');              //隱藏通報紀錄新增
        $('#noticUpdate1').collapse('hide');            //隱藏通報紀錄修改
        $('#noticInster1').collapse('hide');            //隱藏通報紀錄新增
        $('#jobShow1').collapse('show');                //顯示派工紀錄列表
        $('#noticShow1').collapse('show');              //顯示通報紀錄列表
        roadBase.allEditIcno = false;                    //顯示編輯按鈕
        roadBase.toEditReset();
    })
});