
var app = angular.module('MyMap', ['ngSanitize']);
app.controller('ManageController', function ($scope, $http) {
    var manage = this;

    manage.User = "";
    manage.UserSelect = false;
    manage.EditUserMenu = {};
    manage.NewUserMenu = {};
    manage.Premission = [];
    manage.NullPremission = [];

    manage.Url = {
        Manage: "template/manage.html",
        TopNavBar: "template/ManageDetail/topNavBar.html",
        Permission: "template/ManageDetail/Permission.html",
        UserBase: "template/ManageDetail/UserBase.html",
        NewUser: "template/ManageDetail/NewUser.html",
        NewUserBase: "template/ManageDetail/NewUserBase.html",
        NewPermission: "template/ManageDetail/NewPermission.html",
        loadDiv:"template/loadDiv.html"
    }
    manage.getUser = function (id) {
        $http({
            method: 'post',
            url: "json/GetPostUser.ashx?type=getUser",
            data: id
        }).success(function (data, status, headers, config) {
            manage.User = data;
        }).error(function (data, status, headers, config) {
            postToastr("取得使用者資料失敗，請聯絡系統管理者！", "error");
        });
    }

    manage.getPermission = function (id) {
        $http({
            method: 'post',
            url: "json/GetPostUser.ashx?type=getPermission",
            data: id
        }).success(function (data, status, headers, config) {
            manage.Premission = data;
            document.getElementById("loadDiv").style.display = "none";
        }).error(function (data, status, headers, config) {
            postToastr("取得使用者資料失敗，請聯絡系統管理者！", "error");
        });
    }

    manage.getNullPermission = function () {
        $http({
            method: 'post',
            url: "json/GetPostUser.ashx?type=getNullPermission",
            data: 99999
        }).success(function (data, status, headers, config) {
            manage.NullPremission = data;
        }).error(function (data, status, headers, config) {
            postToastr("取得使用者資料失敗，請聯絡系統管理者！", "error");
        });
    }

    manage.changeOnOff = function (my) {
        if (my.Permission) {
            my.Class = ""
            my.Permission = false;
        } else {
            my.Class = "toggle-on"
            my.Permission = true;
        }
    }

    manage.editUser = function (type, my) {
        if (type == "edit") {
            document.getElementById("loadDiv").style.display = "";
            $http({
                method: 'post',
                url: "json/GetPostUser.ashx?type=getUserMenu",
                data: my.UserLoginID
            }).success(function (data, status, headers, config) {
                manage.EditUserMenu = data;
            }).error(function (data, status, headers, config) {
                postToastr("取得使用者資料失敗，請聯絡系統管理者！", "error");
            });
            manage.getPermission(my.UserLoginID);
            if (!manage.UserSelect) {
                $('#newUserDiv').collapse('hide').on('hidden.bs.collapse', function () {
                    $('#editUserDiv').collapse('show');
                    $('#newUserDiv').off('hidden.bs.collapse');
                });
                manage.UserSelect = true;
            }
        } else if (type == "ok") {
            var res = true;
            var err = "";
            if (manage.toVerify(manage.EditUserMenu.UserName)) {
                res = false;
                err = "姓名不可有特殊字元";
            }
            if (manage.toVerify(manage.EditUserMenu.JobTitle)) {
                res = false;
                err = "職稱不可有特殊字元";
            }
            if (manage.toVerify(manage.EditUserMenu.Password)) {
                res = false;
                err = "密碼不可有特殊字元";
            }
            if (manage.EditUserMenu.UserID == "" || manage.EditUserMenu.UserID == null) {
                res = false;
                err = "帳號不可為空";
            }
            if (manage.EditUserMenu.UserName == "" || manage.EditUserMenu.UserName == null) {
                res = false;
                err = "姓名不可為空";
            }
            if (res) {
                $('#newUserBase').collapse('hide');
                $('#newUser').collapse('show');
                $('#editUserDiv').collapse('hide').on('hidden.bs.collapse', function () {
                    $('#newUserDiv').collapse('show');
                    $('#editUserDiv').off('hidden.bs.collapse');
                });
                manage.Premission.UserName = manage.EditUserMenu.UserName;
                manage.Premission.JobTitle = manage.EditUserMenu.JobTitle;
                manage.Premission.Password = manage.EditUserMenu.Password;
                manage.Premission.State = manage.EditUserMenu.State;
                manage.Premission.admin = manage.EditUserMenu.admin;
                $http({
                    method: 'post',
                    url: "json/GetPostUser.ashx?type=updateUser",
                    data: manage.Premission
                }).success(function (data, status, headers, config) {
                    postToastr("修改成功");
                    manage.getUser();
                }).error(function (data, status, headers, config) {
                    postToastr("修改失敗，請聯絡系統管理者！", "error");
                });
                manage.UserSelect = false;
            } else {
                alert(err);
            }
        } else if (type == "no") {
            $('#newUserBase').collapse('hide');
            $('#newUser').collapse('show');
            $('#editUserDiv').collapse('hide').on('hidden.bs.collapse', function () {
                $('#newUserDiv').collapse('show');
                $('#editUserDiv').off('hidden.bs.collapse');
            });
            manage.UserSelect = false;
        }
    }


    manage.getMakerJob = function (id) {
        $http({
            method: 'post',
            url: "json/GetPostJob.ashx?type=getJob",
            data: id
        }).success(function (data, status, headers, config) {
            manage.Job = data;
        }).error(function (data, status, headers, config) {
            postToastr("取得派工資料失敗，請聯絡系統管理者！", "error");
        });
    }

    manage.showNewUser = function (type) {
        if (type == "new") {
            manage.NewUserMenu = {};
            manage.getNullPermission();
            $('#newUser').collapse('hide').on('hidden.bs.collapse', function () {
                $('#newUserBase').collapse('show');
                $('#newUser').off('hidden.bs.collapse');
            });
        } else if (type == "ok") {
            var res = true;
            var err = "";           
            
            if (manage.toVerify(manage.NewUserMenu.JobTitle)) {
                res = false;
                err = "職稱不可有特殊字元";
            }
            if (manage.toVerify(manage.NewUserMenu.Password)) {
                res = false;
                err = "密碼不可有特殊字元";
            }
            if (manage.toVerify(manage.NewUserMenu.UserName)) {
                res = false;
                err = "姓名不可有特殊字元";
            }
            if (manage.toVerify(manage.NewUserMenu.UserID)) {
                res = false;
                err = "帳號不可有特殊字元";
            }
            if (manage.NewUserMenu.UserName == "" || manage.NewUserMenu.UserName == null) {
                res = false;
                err = "姓名不可為空";
            }
            if (manage.NewUserMenu.Password == "" || manage.NewUserMenu.Password == null) {
                res = false;
                err = "密碼不可為空";
            }
            if (manage.NewUserMenu.UserID == "" || manage.NewUserMenu.UserID == null) {
                res = false;
                err = "帳號不可為空";
            }
            if (res) {
                manage.NullPremission.UserID = manage.NewUserMenu.UserID;
                manage.NullPremission.UserName = manage.NewUserMenu.UserName;
                manage.NullPremission.JobTitle = manage.NewUserMenu.JobTitle;
                manage.NullPremission.Password = manage.NewUserMenu.Password;
                $http({
                    method: 'post',
                    url: "json/GetPostUser.ashx?type=newUser",
                    data: manage.NullPremission
                }).success(function (data, status, headers, config) {
                    if (data == "err") {
                        alert("使用者帳號已有人使用，請更換。")
                    } else {
                        manage.getUser();
                        postToastr("新增成功");
                        $('#newUserBase').collapse('hide').on('hidden.bs.collapse', function () {
                            $('#newUser').collapse('show');
                            $('#newUserBase').off('hidden.bs.collapse');
                        });
                    }
                }).error(function (data, status, headers, config) {
                    $('#newUserBase').collapse('hide').on('hidden.bs.collapse', function () {
                        $('#newUser').collapse('show');
                        $('#newUserBase').off('hidden.bs.collapse');
                    });
                    postToastr("新增失敗，請聯絡系統管理者！", "error");
                });
            } else {
                alert(err);
            }
        } else if (type == "no") {
            $('#newUserBase').collapse('hide').on('hidden.bs.collapse', function () {
                $('#newUser').collapse('show');
                $('#newUserBase').off('hidden.bs.collapse');
            });
        }
    }


    manage.toVerify = function (value) {
        var pattern = new RegExp("[`~!@#$^&*()=|{}':;',\\[\\].<>/ ?~！@#￥……&*（）——|{}【】『；：」「'。，、？]")
        return pattern.test(value);
    }







    manage.getUser();
    manage.getNullPermission();
});


app.filter('searchUserKey', function () {
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
                        if (!!alls.UserName) {
                            if (alls.UserName.search(key) != -1) {
                                toHave = true;
                            }
                        }
                        if (!!alls.JobTitle) {
                            if (alls.JobTitle.search(key) != -1) {
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