var nowSelect = 0;
app.controller('noticeData', function ($scope, NgMap, $http) {
    var notice = this;
    notice.insertValue = {                       //新增暫存區
        "id": "",
        "Who": "",
        "NoticeDate": "",
        "NoticeContent": "",
        "Result": "",
        "Remark": ""
    };
    notice.updateValue = {                       //新增暫存區
        "NoticeID": "",
        "Who": "",
        "NoticeDate": "",
        "NoticeContent": "",
        "Result": "",
        "Remark": ""
    };



    notice.newData = function (type) {
        if (type == "edit") {
            notice.reSet();
            $('#noticInster1').collapse('toggle');
            var d = new Date();
            var mon = (d.getMonth() + 1) + "";
            if (mon.length == 1) {
                mon = "0" + mon;
            }
            var dd = (d.getDate()) + "";
            if (dd.length == 1) {
                dd = "0" + dd;
            }
            notice.insertValue.NoticeDate = (d.getFullYear() - 1911) + "-" + mon + "-" + dd + " " + d.getHours() + ":" + d.getMinutes();
        } else if (type == "no") {
            $('#noticInster1').collapse('hide');
        } else if (type == "ok") {
            $('#noticInster1').collapse('hide');
            notice.insertValue.id = $scope.mapBase.selectMarker.IntersectionID;
            notice.insertValue.NoticeContent = notice.insertValue.NoticeContent.replace(/\n/g, "<br />");
            notice.insertValue.Result = notice.insertValue.Result.replace(/\n/g, "<br />");
            notice.insertValue.Remark = notice.insertValue.Remark.replace(/\n/g, "<br />");
            $http({
                method: 'post',
                url: "json/GetPostNotice.ashx?type=insertNotice",
                data: notice.insertValue
            }).success(function (data, status, headers, config) {
                var a = data;
                a = a.split(",");
                if (a[0] == "err") {
                    postToastr("不正確的執行參數！", "warning");
                } else {
                    postToastr("新增通報成功");
                }
                notice.reLoad(notice.insertValue.id, "", "getNotice");
            }).error(function (data, status, headers, config) {
                postToastr("新增通報失敗，請聯絡系統管理者！", "error");
            });
        }
    }

    notice.updateData = function (type, index, item) {
        if (type == "edit") {
            notice.reSet();
            $('#noticUpdate1').collapse('show');
            $('#noticShow1').collapse('hide');
            notice.updateValue = angular.copy(item);
            notice.updateValue.NoticeDate = angular.copy(notice.updateValue.NoticeDate.replace(/<br \/>/g, " "));
            notice.updateValue.NoticeContent = angular.copy(notice.updateValue.NoticeContent.replace(/<br \/>/g, "\n"));
            notice.updateValue.Result = angular.copy(notice.updateValue.Result.replace(/<br \/>/g, "\n"));
            notice.updateValue.Remark = angular.copy(notice.updateValue.Remark.replace(/<br \/>/g, "\n"));
        } else if (type == "no") {
            $('#noticUpdate1').collapse('hide');
            $('#noticShow1').collapse('show');
        } else if (type == "ok") {
            $('#noticUpdate1').collapse('hide');
            $('#noticShow1').collapse('show');
            notice.updateValue.NoticeContent = notice.updateValue.NoticeContent.replace(/\n/g, "<br />");
            notice.updateValue.Result = notice.updateValue.Result.replace(/\n/g, "<br />");
            notice.updateValue.Remark = notice.updateValue.Remark.replace(/\n/g, "<br />");
            $http({
                method: 'post',
                url: "json/GetPostNotice.ashx?type=updateNotice",
                data: notice.updateValue
            }).success(function (data, status, headers, config) {
                var a = data;
                a = a.split(",");
                if (a[0] == "err") {
                    postToastr("不正確的執行參數！", "warning");
                } else {
                    postToastr("新增通報成功");
                }
                notice.reLoad($scope.mapBase.selectMarker.IntersectionID, "", "getNotice");
            }).error(function (data, status, headers, config) {
                postToastr("新增通報失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "delete") {
            $('#noticUpdate1').collapse('hide');
            $('#noticShow1').collapse('show');
            $http({
                method: 'post',
                url: "json/GetPostNotice.ashx?type=deleteNotice",
                data: notice.updateValue.NoticeID
            }).success(function (data, status, headers, config) {
                postToastr("刪除通報成功");
                notice.reLoad($scope.mapBase.selectMarker.IntersectionID, "", "getNotice");
            }).error(function (data, status, headers, config) {
                postToastr("刪除通報失敗，請聯絡系統管理者！", "error");
            });
        }
    }
    notice.ff = function () {
        $scope.mapBase.nowNoticeSelect = 0;
        var num = nowNot.length / 5 | 0
        $("#leftbtn").removeClass("disabled");
        $("#rightbtn").removeClass("disabled");
        if ($scope.mapBase.nowNoticeSelect == 0) {
            $("#leftbtn").addClass("disabled");
        }
        if ($scope.mapBase.nowNoticeSelect == num) {
            $("#rightbtn").addClass("disabled");
        }
    }
    notice.reSet = function () {
        for (var key in notice.insertValue) {
            notice.insertValue[key] = "";
        }
        for (var key in notice.updateData) {
            notice.insertValue[key] = "";
        }
    }

    notice.range = function (my) {
        var ret = [];
        var num = nowNot.length / 5
        for (var i = 0; i < num; i++) {
            ret.push(i);
        }
        return ret;
    };

    notice.gogo = function (i, type) {
        if (type == "this") {
            var num = nowNot.length / 5 | 0
            $scope.mapBase.nowNoticeSelect = i;
            nowSelect = $scope.mapBase.nowNoticeSelect;
            $("#leftbtn").removeClass("disabled");
            $("#rightbtn").removeClass("disabled");
            if ($scope.mapBase.nowNoticeSelect == 0) {
                $("#leftbtn").addClass("disabled");
            }
            if ($scope.mapBase.nowNoticeSelect == num) {
                $("#rightbtn").addClass("disabled");
            }
        } else if (type == "left") {
            var num = nowNot.length / 5 | 0
            if ($scope.mapBase.nowNoticeSelect != 0) {
                $scope.mapBase.nowNoticeSelect = $scope.mapBase.nowNoticeSelect - 1;
                nowSelect = $scope.mapBase.nowNoticeSelect;
            }
            $("#leftbtn").removeClass("disabled");
            $("#rightbtn").removeClass("disabled");
            if ($scope.mapBase.nowNoticeSelect == 0) {
                $("#leftbtn").addClass("disabled");
            }
            if ($scope.mapBase.nowNoticeSelect == num) {
                $("#rightbtn").addClass("disabled");
            }
        } else {
            var num = nowNot.length / 5 | 0
            if ($scope.mapBase.nowNoticeSelect != num) {
                $scope.mapBase.nowNoticeSelect = $scope.mapBase.nowNoticeSelect + 1;
                nowSelect = $scope.mapBase.nowNoticeSelect;
            }
            $("#leftbtn").removeClass("disabled");
            $("#rightbtn").removeClass("disabled");
            if ($scope.mapBase.nowNoticeSelect == 0) {
                $("#leftbtn").addClass("disabled");
            }
            if ($scope.mapBase.nowNoticeSelect == num) {
                $("#rightbtn").addClass("disabled");
            }
        }
    }


    //重新讀取頁面資料
    notice.reLoad = function (id, index, type, re) {
        $http({
            method: 'post',
            url: "json/GetPostNotice.ashx?type=" + type,
            data: id
        }).success(function (data, status, headers, config) {
            if (type == "getNotice") {
                $scope.mapBase.Notice = data;
            }
        }).error(function (data, status, headers, config) {
            postToastr("同步失敗，請聯絡系統管理者！", "warning");
        });
    }
});
var nowNot = [];
app.filter('searchNoticeKey', function () {
    return function (input, key) {
        if (!!input && !!key) {
            var nowNum = 0;
            var allout = [];
            var start = (nowSelect * 5) - 1;
            var end = (nowSelect * 5) + 5;
            if (key.length > 0) {
                var pattern = new RegExp("[`~!@#$^&*()=|{}':;',\\[\\].<>/?~！@#￥……&*（）——|{}【】『；：」「'。，、？]")
                var rs = "";
                for (var i = 0; i < key.length; i++) {
                    rs = rs + key.substr(i, 1).replace(pattern, '');
                }
                key = rs;
                if (key.length > 0) {
                    var out = [];
                    angular.forEach(input, function (alls) {
                        var toHave = false;
                        if (!!alls.Who) {
                            if (alls.Who.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.NoticeDate) {
                            if (alls.NoticeDate.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.NoticeContent) {
                            if (alls.NoticeContent.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.Result) {
                            if (alls.Result.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.Remark) {
                            if (alls.Remark.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (toHave) {
                            if (nowNum > start && nowNum < end) {
                                out.push(alls);
                            }
                            allout.push(alls);
                            nowNum = nowNum + 1;
                        }
                    })
                    nowNot = allout;
                    return out;
                }
            }
        } else {
            var out = [];
            var allout = [];
            var nowNum = 0;
            var start = (nowSelect * 5) - 1;
            var end = (nowSelect * 5) + 5;
            angular.forEach(input, function (alls) {
                if (nowNum > start && nowNum < end) {
                    out.push(alls);
                }
                nowNum = nowNum + 1;
                allout.push(alls);
            });
            nowNot = allout;
            return out;
        }
    };
});