var app = angular.module('excel', ['ngSanitize']);
app.controller('exc', function ($scope, $http) {
    var ex = this
    ex.rootList = "";
    ex.importNum = 0;
    ex.nowNum = 0;
    ex.error = "";
    ex.roadNum = 0;
    ex.getRoot = function () {
        $http({
            method: 'GET',
            url: 'rootSearch.ashx'
        }).success(function (data, status, headers, config) {
            ex.rootList = data;
        }).error(function (data, status, headers, config) {
        });
    }
    ex.import = function (index) {
        ex.nowNum = 0;
        ex.importNum = ex.rootList[index].excel.length;
        ex.nowfileroot = ex.rootList[index].fileroot;
        if (ex.nowNum < ex.importNum) {
            ex.importStart(ex.rootList[index].fileroot, ex.rootList[index].excel[ex.nowNum],index);
        }
    };
    ex.importStart = function (fileroot, name, index) {
        $http({
            method: 'GET',
            url: 'excelimport.ashx?fileroot=' + fileroot + '&name=' + name
        }).success(function (data, status, headers, config) {
            ex.nowNum = ex.nowNum + 1;
            ex.error = ex.error + data.split(',')[0];
            if (!isNaN(parseInt(data.split(',')[1]))) {
                ex.roadNum = ex.roadNum + parseInt(data.split(',')[1]);
            }           
            if (ex.nowNum < ex.importNum) {
                ex.importStart(ex.rootList[index].fileroot, ex.rootList[index].excel[ex.nowNum], index);
            }
        }).error(function (data, status, headers, config) {
            ex.error = ex.error + name + "匯入失敗";
        });
    }
    ex.getRoot();

});