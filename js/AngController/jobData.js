app.controller('jobData', function ($scope, NgMap, $http) {
    var job = this;
    job.insertValue = {                       //新增暫存區
        "IntersectionID": "",
        "ZoneName": "",
        "JobDate": "",
        "JobContent": "",
        "RepairDate": "",
        "Src": ""
    };
    job.updateValue = {                       //新增暫存區
        "JobID": "",
        "ZoneName": "",
        "JobDate": "",
        "JobContent": "",
        "RepairDate": "",
        "Src": ""
    };



    job.newData = function (type) {
        if (type == "edit") {
            job.reSet();
            $('#jobInster1').collapse('toggle');
            var d = new Date();
            var mon = (d.getMonth() + 1) + "";
            if (mon.length == 1) {
                mon = "0" + mon;
            }
            var dd = (d.getDate()) + "";
            if (dd.length == 1) {
                dd = "0" + dd;
            }
            job.insertValue.JobDate = (d.getFullYear() - 1911) + "-" + mon + "-" + dd + " " + d.getHours() + ":" + d.getMinutes();
            job.insertValue.RepairDate = (d.getFullYear() - 1911) + "-" + mon + "-" + dd + " " + d.getHours() + ":" + d.getMinutes();
        } else if (type == "no") {
            $('#jobInster1').collapse('hide');
        } else if (type == "ok") {
            $('#jobInster1').collapse('hide');
            job.insertValue.IntersectionID = $scope.mapBase.selectMarker.IntersectionID;
            job.insertValue.JobContent = job.insertValue.JobContent.replace(/\n/g, "<br />");
            $http({
                method: 'post',
                url: "json/GetPostjob.ashx?type=insertJob",
                data: job.insertValue
            }).success(function (data, status, headers, config) {
                var a = data;
                a = a.split(",");
                if (a[0] == "warning") {
                    postToastr(a[1], "warning");
                } else if (a[0] == "error") {
                    postToastr(a[1], "error");
                }
                else {
                    postToastr("新增派工成功");
                }
                job.reLoad($scope.mapBase.selectMarker.IntersectionID, "", "getJob");
            }).error(function (data, status, headers, config) {
                postToastr("新增派工失敗，請聯絡系統管理者！", "error");
            });
        }
    }

    job.updateData = function (type, index, item) {
        if (type == "edit") {
            job.reSet();
            $('#jobUpdate1').collapse('show');
            $('#jobShow1').collapse('hide');
            job.updateValue = angular.copy(item);
            job.updateValue.JobDate = angular.copy(job.updateValue.JobDate.replace(/<br \/>/g, " "));
            job.updateValue.RepairDate = angular.copy(job.updateValue.RepairDate.replace(/<br \/>/g, " "));
            job.updateValue.JobContent = angular.copy(job.updateValue.JobContent.replace(/<br \/>/g, "\n"));
        } else if (type == "no") {
            $('#jobUpdate1').collapse('hide');
            $('#jobShow1').collapse('show');
        } else if (type == "ok") {
            $('#jobUpdate1').collapse('hide');
            $('#jobShow1').collapse('show');
            job.updateValue.JobContent = job.updateValue.JobContent.replace(/\n/g, "<br />");
            $http({
                method: 'post',
                url: "json/GetPostJob.ashx?type=updateJob",
                data: job.updateValue
            }).success(function (data, status, headers, config) {
                var a = data;
                a = a.split(",");
                if (a[0] == "err") {
                    postToastr("不正確的執行參數！", "warning");
                } else {
                    postToastr("修改派工成功");
                }
                job.reLoad($scope.mapBase.selectMarker.IntersectionID, "", "getJob");
            }).error(function (data, status, headers, config) {
                postToastr("修改派工失敗，請聯絡系統管理者！", "error");
            });
        } else if (type == "delete") {
            $('#jobUpdate1').collapse('hide');
            $('#jobShow1').collapse('show');
            $http({
                method: 'post',
                url: "json/GetPostJob.ashx?type=deleteJob",
                data: job.updateValue.JobID
            }).success(function (data, status, headers, config) {
                postToastr("刪除派工成功");
                job.reLoad($scope.mapBase.selectMarker.IntersectionID, "", "getJob");
            }).error(function (data, status, headers, config) {
                postToastr("刪除派工失敗，請聯絡系統管理者！", "error");
            });
        }
    }


    job.reSet = function () {
        for (var key in job.insertValue) {
            job.insertValue[key] = "";
        }
        for (var key in job.updateData) {
            job.insertValue[key] = "";
        }
        var f = document.getElementById("data1");
        var f2 = document.getElementById("data2");
        f.value = "";
        f2.value = "";
    }


    job.uploadData = function (my, type) {
        var f = document.getElementById(my.id);
        var fileSize = f.files.item(0).size;
        var fileName = f.files.item(0).name;
        var extIndex = fileName.lastIndexOf('.');
        if (extIndex != -1) {
            fileName = fileName.substr(extIndex + 1, fileName.length);
        }
        if (fileSize < 3000000) {
            var re = /(jpg|gif|png|jpeg|bmp|png|xls|doc|odt|xlsx|docx|pdf)$/i;
            if (!re.test(fileName)) {
                alert("只允許上傳jpg,gif,png,jpeg,bmp,png,xls,doc,odt,xlsx,docx,pdf");
            } else {
                $("#ajaxForm1").ajaxSubmit(
                    {
                        beforeSubmit: function () { },
                        success: function (resp, st, xhr, $form) {
                            if (resp != "err") {
                                postToastr("檔案上傳成功！");
                                if (type == "insert") {
                                    job.insertValue.Src = "upload/jobData/" + resp;
                                } else if (type == "update") {
                                    job.updateValue.Src = "upload/jobData/" + resp;
                                }
                            }
                            else {
                                postToastr("檔案上傳失敗，請聯絡系統管理者！", "error");
                                f.value = "";
                            }
                        }
                    });
            }
        } else {
            alert("檔案超過3MB，請重新選擇！");
            f.value = "";
        }
    }



    //重新讀取頁面資料
    job.reLoad = function (id, index, type, re) {
        $http({
            method: 'post',
            url: "json/GetPostJob.ashx?type=" + type,
            data: id
        }).success(function (data, status, headers, config) {
            if (type == "getJob") {
                $scope.mapBase.Job = data;
            } 
        }).error(function (data, status, headers, config) {
            postToastr("同步失敗，請聯絡系統管理者！", "warning");
        });
    }
});


app.filter('searchJobKey', function () {
    return function (input, key) {
        if (!!input && !!key) {
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
                        if (!!alls.ZoneName) {
                            if (alls.ZoneName.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.JobDate) {
                            if (alls.JobDate.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.JobContent) {
                            if (alls.JobContent.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.RepairDate) {
                            if (alls.RepairDate.search(key) != -1) {
                                toHave = true;
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