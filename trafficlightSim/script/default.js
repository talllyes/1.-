var map;
var TimingPlans;
var trafficLights = [];
var trafficLightIdIndex = 1;
var selectedTrafficLight;

$(document).ready(function() {

    'use strict';

    var intersectionDetailId = location.search.replace("?intersectionDetailId=", "");
    var intersectionJson = getIntersectionJson(intersectionDetailId);
    var postion = intersectionJson.Position.split(",");
    TimingPlans = getTimingPlanJson(intersectionDetailId);
    var timePhaseDescription = getTimePhaseDescription(intersectionDetailId);
    //console.log(timePhaseDescription);

    var checkIfNull = getTrafficLightJson(intersectionDetailId);
    if (checkIfNull != null) { trafficLights = getTrafficLightJson(intersectionDetailId); }

    tableInit(TimingPlans, timePhaseDescription);

    initMap(postion);

    $("#save").on("click", function() {
        saveTrafficLightJson(intersectionDetailId);
    });

    $("#add").on("click", function() {

        $(".trafficLight").css({
            "border-color": "black"
        });

        var trafficLightObj = {
            Id: trafficLightIdIndex,
            Lat: map.getCenter().lat(),
            Lng: map.getCenter().lng(),
            Rotate: 0,
            Phases: [1],
            Bulbs: [{
                Type: "red",
                Phases: [1]
            }, {
                Type: "yellow",
                Phases: [1]
            }, {
                Type: "green",
                Phases: [1]
            }]
        };

        trafficLightIdIndex++;

        trafficLights.push(trafficLightObj);
        addTrafficLightOnMap(trafficLightObj, "yellow");

        selectedTrafficLight = trafficLights[trafficLights.length - 1];

        prepareControlPanelTable();
        $("#controlPanel").dialog("open");

    });

    $("#controlPanel").on("dialogopen", function(event, ui) {

        $("#save").prop("disabled", true);
        $("#play").prop("disabled", true);
        $("#stop").prop("disabled", true);
        $("#add").prop("disabled", true);
        $(".speed").prop("disabled", true);

    });

    $("#controlPanel").on("dialogclose", function(event, ui) {

        $("#save").prop("disabled", false);
        $("#play").prop("disabled", false);
        $("#stop").prop("disabled", true);
        $("#add").prop("disabled", false);
        $(".speed").prop("disabled", false);

        $(".trafficLight").css({
            "border-color": "black"
        });

    });

    /////////////////// Control Panel start ///////////////////

    var rotate;
    var flag = true;

    $(".fa-repeat").on("mousedown", function() {

        if (flag)
        {
            var reverse = $(this).hasClass('fa-flip-horizontal');

            var id = selectedTrafficLight.Id;

            rotate = setInterval(function () {

                if (reverse) {
                    selectedTrafficLight.Rotate -= 5;
                } else {
                    selectedTrafficLight.Rotate += 5;
                }

                $("#" + id).css({ transform: "rotate(" + selectedTrafficLight.Rotate + "deg)" });

            }, 100);
            flag = false;
        }

    });

    $(".fa-repeat").on("mouseup", function() {
        clearInterval(rotate);
        flag = true;
    });

    $(".fa-repeat").on("mouseleave", function() {
        clearInterval(rotate);
    });

    $(".fa-check").on("click", function() {
        $("#controlPanel").dialog("close");
    });

    $("#delete").on("click", function() {

        $("#save").prop("disabled", false);
        $("#play").prop("disabled", false);
        $("#stop").prop("disabled", true);
        $("#add").prop("disabled", false);
        $(".speed").prop("disabled", flase);

        $("#" + selectedTrafficLight.Id).parent().remove();

        var i;
        for (i = 0; i < trafficLights.length; i += 1) {
            if (trafficLights[i].Id == selectedTrafficLight.Id) {
                trafficLights.splice(i, 1);
            }
        }
        $("#controlPanel").dialog("close");
    });

    $("#controlPanel input:checkbox").on("click", function() {

        if ($("#controlPanel input:checkbox:checked").length == 0) {
            $(this).prop({
                checked: 'true'
            });
        } else {
            var phase = $(this).attr("value");
            if ($(this).prop("checked")) {
                // true
                $(this).parent().siblings().find("i").removeClass('light').addClass('dark').show();
                $(this).parent().siblings().find("i.fa.fa-circle").removeClass('dark').addClass('light');
            } else {
                // false
                $(this).parent().siblings().find("i").hide();
            }
        }

        $("#" + selectedTrafficLight.Id).parent().remove();
        updateSelectedTrafficLight();
        addTrafficLightOnMap(selectedTrafficLight, "yellow");

    });

    $("#controlPanel tr:gt(0) i").on("click", function() {

        if ($(this).hasClass('light') && $(this).parents("tr").find('i.light:visible').length == 1) {
            // do nothing
        } else {

            var bulb = $(this);

            if (bulb.hasClass('light')) {
                bulb.removeClass('light').addClass('dark');
            } else {
                bulb.removeClass('dark').addClass('light');
            }

        }

        updateSelectedTrafficLight();
        $("#" + selectedTrafficLight.Id).parent().remove();
        addTrafficLightOnMap(selectedTrafficLight, "yellow");

    });

    $("#controlPanel").dialog({
        position: { my: "center", at: "right", of: window },
        width: 500,
        autoOpen: false,
        show: {
            effect: "blind",
            duration: 1000
        },
        hide: {
            effect: "blind",
            duration: 1000
        }
    });

    /////////////////// Control Panel end ///////////////////

    /////////////////// simulation start ///////////////////

    //var cycle;
    //var PhaseNumber;
    var timer = 0;
    var timerInPhase = 0;
    var simulation;

    $("#stop").prop("disabled", true);

    $("#play").on("click", function() {

        $("#save").prop("disabled", true);
        $("#play").prop("disabled", true);
        $("#stop").prop("disabled", false);
        $("#add").prop("disabled", true);
        $(".speed").prop("disabled", true);

        // 選擇時制計畫編號
        var selectRadio = $("#dashboard input:radio:checked").attr("value");
        var selectTimingPlan = TimingPlans[selectRadio].Phase;

        $("#dashboard tbody tr:eq(" + selectRadio + ")").siblings("tr").hide();
        $(".progress").show();
        var valueForProgressBar = 0;

        var cycle = TimingPlans[selectRadio].Cycle;
        var PhaseNumber = selectTimingPlan.length;
        // simulation start，為每個燈產生diagram
        genaralDiagram(selectTimingPlan, cycle, PhaseNumber);
        //printDiagram();

        $(".trafficLight").each(function() {

            for (var i in trafficLights) {
                if (trafficLights[i].Id == $(this).attr("id")) {
                    var index = 0;
                    $(this).find(".lightBulb ").each(function() {
                        $(this).data("diagram", trafficLights[i].Bulbs[index].Diagram);
                        index++;
                    });
                }
            }

        });

        simulation = setInterval(function() {
            clockStart();
        }, $("#speed").attr("interval"));

        function clockStart() {

            timer++;
            timerInPhase++;
            var nowPhase = NowPhase();

            var g = selectTimingPlan[nowPhase - 1].G;
            var gy = selectTimingPlan[nowPhase - 1].G + selectTimingPlan[nowPhase - 1].Y;
            var gyr = selectTimingPlan[nowPhase - 1].G + selectTimingPlan[nowPhase - 1].Y + selectTimingPlan[nowPhase - 1].R;

            if (timerInPhase <= g) {
                valueForProgressBar++;
                var width = Math.round(valueForProgressBar / selectTimingPlan[nowPhase - 1].G * 100);
                $("#dashboard tbody tr:eq(" + selectRadio + ") td.phase" + nowPhase + ".g .progress-bar").css('width', width + '%');
                if (width == 100) {
                    valueForProgressBar = 0;
                }
            }
            if (g < timerInPhase && timerInPhase <= gy) {
                valueForProgressBar++;
                var width = Math.round(valueForProgressBar / selectTimingPlan[nowPhase - 1].Y * 100);
                $("#dashboard tbody tr:eq(" + selectRadio + ") td.phase" + nowPhase + ".y .progress-bar").css('width', width + '%');
                if (width == 100) {
                    valueForProgressBar = 0;
                }
            }
            if (gy < timerInPhase && timerInPhase <= gyr) {
                valueForProgressBar++;
                var width = Math.round(valueForProgressBar / selectTimingPlan[nowPhase - 1].R * 100);
                $("#dashboard tbody tr:eq(" + selectRadio + ") td.phase" + nowPhase + ".r .progress-bar").css('width', width + '%');
                if (width == 100) {
                    valueForProgressBar = 0;
                }
            }

            $(".lightBulb").each(function() {

                var diagram = $(this).data("diagram").toString().split(",");

                if (diagram[timer - 1] == 1)
                    $(this).css("opacity", 1);
                else
                    $(this).css("opacity", 0);

            });

            timer = timer % cycle;
            timerInPhase = timerInPhase % selectTimingPlan[nowPhase - 1].PH;
            if (timer == 0) {
                $(".progress-bar").css('width', 0 + '%');
            }
        }

        function NowPhase() {
            var ph = 0;
            for (var i in selectTimingPlan) {
                ph = ph + selectTimingPlan[i].G + selectTimingPlan[i].Y + selectTimingPlan[i].R;
                if (timer <= ph)
                    return (parseInt(i) + 1);
            }
        }

    });

    $("#forward").on("click", function() {
        
        var speed = $("#speed").attr("speed");
        if (speed < 10) {
            speed++;
            var interval = 1000/speed;
            $("#speed").attr({
                speed: speed,
                interval: interval
            });
            $("#speed").text(speed + "X");
        }

        console.log($("#speed").attr("speed") + " " + $("#speed").attr("interval"));

    });
    $("#backward").on("click", function() {
        
        var speed = $("#speed").attr("speed");
        if (speed > 1) {
            speed--;
            var interval = 1000/speed;
            $("#speed").attr({
                speed: speed,
                interval: interval
            });
            $("#speed").text(speed + "X");
        }
        console.log($("#speed").attr("speed") + " " + $("#speed").attr("interval"));
    });

    $("#stop").on("click", function() {

        $("#save").prop("disabled", false);
        $("#play").prop("disabled", false);
        $("#stop").prop("disabled", true);
        $("#add").prop("disabled", false);
        $(".speed").prop("disabled", false);

        timer = 0;
        timerInPhase = 0;
        clearInterval(simulation);

        $("#dashboard tbody tr").show();
        $(".progress-bar").css('width', 0 + '%');
        $(".progress").hide();
        $(".lightBulb").css("opacity", 1);

    });

    ///////////////////simulation end///////////////////

}); // end $(document).ready()



function updateSelectedTrafficLight() {

    // update TrafficLight phase

    // init
    selectedTrafficLight.Phases.length = 0;
    selectedTrafficLight.Bulbs.length = 0;

    // setting selectedTrafficLight.Phases
    $("#controlPanel input:checkbox:checked").each(function() {
        selectedTrafficLight.Phases.push(parseInt($(this).attr("value")));
    });

    var red = {
        "Type": "red",
        "Phases": []
    };

    var yellow = {
        "Type": "yellow",
        "Phases": []
    };

    red.Phases = selectedTrafficLight.Phases;
    yellow.Phases = selectedTrafficLight.Phases;

    selectedTrafficLight.Bulbs.push(red);
    selectedTrafficLight.Bulbs.push(yellow);

    if ($("#controlPanel i.light[data-type='green']:visible").length > 0) {
        var green = {
            "Type": "green",
            "Phases": []
        };
        $("#controlPanel i.light[data-type='green']:visible").each(function() {
            green.Phases.push(parseInt($(this).data("phase")));
        });
        selectedTrafficLight.Bulbs.push(green);
    }

    if ($("#controlPanel i.light[data-type='left']:visible").length > 0) {
        var left = {
            "Type": "left",
            "Phases": []
        };
        $("#controlPanel i.light[data-type='left']:visible").each(function() {
            left.Phases.push(parseInt($(this).data("phase")));
        });
        selectedTrafficLight.Bulbs.push(left);
    }

    if ($("#controlPanel i.light[data-type='straight']:visible").length > 0) {
        var straight = {
            "Type": "straight",
            "Phases": []
        };
        $("#controlPanel i.light[data-type='straight']:visible").each(function() {
            straight.Phases.push(parseInt($(this).data("phase")));
        });
        selectedTrafficLight.Bulbs.push(straight);
    }

    if ($("#controlPanel i.light[data-type='right']:visible").length > 0) {
        var right = {
            "Type": "right",
            "Phases": []
        };
        $("#controlPanel i.light[data-type='right']:visible").each(function() {
            right.Phases.push(parseInt($(this).data("phase")));
        });
        selectedTrafficLight.Bulbs.push(right);
    }

}


TrafficLightOverlay.prototype = new google.maps.OverlayView();

TrafficLightOverlay.prototype.onAdd = function() {

    var container = document.createElement('div'),
        that = this;

    // 紀錄疊加層的位置
    var recordLat;
    var recordLng;

    if (typeof this.get('content').nodeName !== 'undefined') {
        container.appendChild(this.get('content'));
    } else {
        if (typeof this.get('content') === 'string') {
            container.innerHTML = this.get('content');
        } else {
            return;
        }
    }

    container.style.position = 'absolute';
    container.draggable = true;

    google.maps.event.addDomListener(this.get('map').getDiv(),
        'mouseleave',
        function() {
            google.maps.event.trigger(container, 'mouseup');
        }
    );

    google.maps.event.addDomListener(container,
        'dblclick',
        function(e) {

            $("#stop").trigger("click");

            var $trafficLight = $(container.firstElementChild);

            for (var i in trafficLights) {
                if (container.firstElementChild.id == trafficLights[i].Id) {
                    selectedTrafficLight = trafficLights[i];
                }
            }

            // init
            $(".trafficLight").css({
                "border-color": "black"
            });

            $trafficLight.css({
                "border-color": "yellow"
            });

            prepareControlPanelTable();
            $("#controlPanel").dialog("open");

            // var position = new google.maps.LatLng(selectedTrafficLight.Lat, selectedTrafficLight.Lng);
            // map.panTo(position);

        }
    );

    google.maps.event.addDomListener(container,
        'mousedown',
        function(e) {

            var index;

            for (var i in trafficLights) {
                if (container.firstElementChild.id == trafficLights[i].Id) {
                    index = i;
                }
            }

            this.style.cursor = 'move';
            that.map.set('draggable', false);
            that.set('origin', e);

            that.moveHandler = google.maps.event.addDomListener(that.get('map').getDiv(),
                'mousemove',
                function(e) {
                    var origin = that.get('origin'),
                        left = origin.clientX - e.clientX,
                        top = origin.clientY - e.clientY,
                        pos = that.getProjection()
                        .fromLatLngToDivPixel(that.get('position')),
                        latLng = that.getProjection()
                        .fromDivPixelToLatLng(new google.maps.Point(pos.x - left,
                            pos.y - top));
                    that.set('origin', e);
                    that.set('position', latLng);
                    that.draw();

                    // console.log(latLng.toString());
                    trafficLights[index].Lat = latLng.lat();
                    trafficLights[index].Lng = latLng.lng();

                });

        }
    );

    google.maps.event.addDomListener(container, 'mouseup', function() {
        that.map.set('draggable', true);
        this.style.cursor = 'default';
        google.maps.event.removeListener(that.moveHandler);
    });

    this.set('container', container)
    this.getPanes().floatPane.appendChild(container);

};

TrafficLightOverlay.prototype.draw = function() {
    var pos = this.getProjection().fromLatLngToDivPixel(this.get('position'));
    this.get('container').style.left = pos.x + 'px';
    this.get('container').style.top = pos.y + 'px';
};

TrafficLightOverlay.prototype.onRemove = function() {
    this.get('container').parentNode.removeChild(this.get('container'));
    this.set('container', null);
};

function initMap(postion) {

    var lat = parseFloat(postion[0]);
    var lng = parseFloat(postion[1]);

    map = new google.maps.Map(document.getElementById('map-canvas'), {
        zoom: 20,
        maxZoom: 20,
        minZoom: 20,
        center: new google.maps.LatLng(lat, lng),
        mapTypeId: google.maps.MapTypeId.HYBRID,
        disableDoubleClickZoom: true,
        zoomControl: false,
        styles: [{
            featureType: 'poi',
            elementType: 'labels',
            stylers: [
                { visibility: 'off' }
            ]
        }]
    });

    for (var i in trafficLights) {
        addTrafficLightOnMap(trafficLights[i], "black");
    }

}

function prepareControlPanelTable() {

    // init

    $("#controlPanel input:checkbox").prop("checked", false);
    $("#controlPanel tr:gt(0) i").removeClass('light').addClass('dark').hide();

    for (var i in selectedTrafficLight.Phases) {
        var chechbox = $("#controlPanel input:checkbox:eq(" + (selectedTrafficLight.Phases[i] - 1) + ")");
        chechbox.prop("checked", true);
        chechbox.parent().siblings().find('i').show();
    }

    for (var j in selectedTrafficLight.Bulbs) {

        switch (selectedTrafficLight.Bulbs[j].Type) {
            case "green":
                for (var k in selectedTrafficLight.Bulbs[j].Phases) {
                    $("#controlPanel td.phase" + selectedTrafficLight.Bulbs[j].Phases[k] + " i.fa-circle").removeClass('dark').addClass('light');
                }
                break;
            case "left":
                for (var k in selectedTrafficLight.Bulbs[j].Phases) {
                    $("#controlPanel td.phase" + selectedTrafficLight.Bulbs[j].Phases[k] + " i.fa-arrow-left").removeClass('dark').addClass('light');
                }
                break;
            case "straight":
                for (var k in selectedTrafficLight.Bulbs[j].Phases) {
                    $("#controlPanel td.phase" + selectedTrafficLight.Bulbs[j].Phases[k] + " i.fa-arrow-up").removeClass('dark').addClass('light');
                }
                break;
            case "right":
                for (var k in selectedTrafficLight.Bulbs[j].Phases) {
                    $("#controlPanel td.phase" + selectedTrafficLight.Bulbs[j].Phases[k] + " i.fa-arrow-right").removeClass('dark').addClass('light');
                }
                break;
        }

    }

}



function addTrafficLightOnMap(trafficLightObj, borderColor) {

    var position = new google.maps.LatLng(trafficLightObj.Lat, trafficLightObj.Lng);

    var container = $("<div>");

    var newTrafficLight = $("<div id='" + trafficLightObj.Id + "' title='ID" + trafficLightObj.Id + "' class='trafficLight' style='transform: rotate(" + trafficLightObj.Rotate + "deg);'></div>");

    for (var j in trafficLightObj.Bulbs) {

        var type = trafficLightObj.Bulbs[j].Type;
        var icon = "";

        switch (type) {
            case "red":
                icon = "fa fa-circle";
                break;
            case "yellow":
                icon = "fa fa-circle";
                break;
            case "green":
                icon = "fa fa-circle";
                break;
            case "left":
                icon = "fa fa-arrow-left";
                break;
            case "straight":
                icon = "fa fa-arrow-up";
                break;
            case "right":
                icon = "fa fa-arrow-right";
                break;
            default:
                icon = "";
        }

        var bulb = $("<i class='lightBulb' data-diagram=''></i>").addClass(type + " " + icon);

        newTrafficLight.append(bulb);

        newTrafficLight.css({
            "border-color": borderColor
        });

    }

    var overlay = new TrafficLightOverlay(map, position, container.append(newTrafficLight).html());
}

function TrafficLightOverlay(map, position, content) {
    if (typeof draw === 'function') {
        this.draw = draw;
    }
    this.setValues({
        position: position,
        container: null,
        content: content,
        map: map
    });
}

function genaralDiagram(timingPlan, cycle, PhaseNumber) {

    initialize(cycle); // initialize diagram of light

    var clockInPhase = 0;
    for (var clock = 0; clock < cycle; clock++) {
        clockInPhase++;
        var NowPhase = getNowPhase(clock, timingPlan);
        var NextPhase = (NowPhase + 1 > PhaseNumber) ? 1 : (NowPhase + 1);
        var g = timingPlan[NowPhase - 1].G;
        var g_y = timingPlan[NowPhase - 1].G + timingPlan[NowPhase - 1].Y;
        var g_y_r = timingPlan[NowPhase - 1].G + timingPlan[NowPhase - 1].Y + timingPlan[NowPhase - 1].R;

        for (var i in trafficLights) {
            if (trafficLights[i].Phases.indexOf(NowPhase) != -1) // 在該時相之號誌
            {
                for (var j in trafficLights[i].Bulbs) {
                    if (trafficLights[i].Bulbs[j].Phases.indexOf(NowPhase) != -1) // 在該時相之燈
                    {
                        // 三色燈
                        if (trafficLights[i].Bulbs[j].Type == "green" && clockInPhase <= g)
                            trafficLights[i].Bulbs[j].Diagram[clock] = 1;
                        if (trafficLights[i].Bulbs[j].Type == "yellow" && g < clockInPhase && clockInPhase <= g_y)
                            trafficLights[i].Bulbs[j].Diagram[clock] = 1;
                        if (trafficLights[i].Bulbs[j].Type == "red" && g_y < clockInPhase && clockInPhase <= g_y_r)
                            trafficLights[i].Bulbs[j].Diagram[clock] = 1;

                        // 箭頭綠燈
                        if ((trafficLights[i].Bulbs[j].Type == "straight" || trafficLights[i].Bulbs[j].Type == "left" || trafficLights[i].Bulbs[j].Type == "right")) {
                            if (trafficLights[i].Bulbs[j].Phases.indexOf(NextPhase) != -1) //下一時相續行
                            {
                                trafficLights[i].Bulbs[j].Diagram[clock] = 1;

                                // 如果直行綠燈續行，則不亮紅黃燈
                                if (trafficLights[i].Bulbs[j].Type == "straight") {
                                    for (var k in trafficLights[i].Bulbs) {
                                        if (trafficLights[i].Bulbs[k].Type == "yellow" || trafficLights[i].Bulbs[k].Type == "red")
                                            trafficLights[i].Bulbs[k].Diagram[clock] = 0;
                                    }
                                }

                            } else //下一時相不續行
                            {
                                if (clockInPhase <= g)
                                    trafficLights[i].Bulbs[j].Diagram[clock] = 1;
                            }

                        }
                    } else // 號誌在該時相，但燈不在該時相
                    {
                        if (trafficLights[i].Bulbs[j].Type == "straight") {
                            for (var m in trafficLights[i].Bulbs) {
                                if (trafficLights[i].Bulbs[m].Type == "red")
                                    trafficLights[i].Bulbs[m].Diagram[clock] = 1;
                            }
                        }
                    }
                }
            } else // 不在該時相之號誌，亮紅燈
            {
                for (var j in trafficLights[i].Bulbs) {
                    if (trafficLights[i].Bulbs[j].Type == "red")
                        trafficLights[i].Bulbs[j].Diagram[clock] = 1;
                }
            }
        }

        clockInPhase = clockInPhase % g_y_r; // reset每個時相的clock

    }


    // 亮黃燈時，關閉紅燈(紅燈右轉或紅燈左轉)
    for (var i in trafficLights) {
        for (var j in trafficLights[i].Bulbs) {
            if (trafficLights[i].Bulbs[j].Type == "yellow") {
                for (var second = 0; second < cycle; second++) {
                    if (trafficLights[i].Bulbs[j].Diagram[second] == 1) {
                        for (var k in trafficLights[i].Bulbs) {
                            if (trafficLights[i].Bulbs[k].Type != "yellow")
                                trafficLights[i].Bulbs[k].Diagram[second] = 0;
                        }
                    }
                }
            }
        }
    }
    // simulation end

}

function initialize(cycle) {
    for (var i in trafficLights) {
        for (var j in trafficLights[i].Bulbs) {
            trafficLights[i].Bulbs[j].Diagram = [];
            for (var second = 0; second < cycle; second++) {
                trafficLights[i].Bulbs[j].Diagram[second] = 0;
            }
        }
    }
}

// function getCycle(timingPlan) {
//     var length = 0;
//     for (var i in timingPlan) {
//         length = length + timingPlan[i].G + timingPlan[i].Y + timingPlan[i].R;
//     }
//     return length;
// }

// function getPhaseNumber(timingPlan) {
//     var count = 0;
//     for (var i in timingPlan)
//         count++;
//     return count;
// }

function getNowPhase(clock, timingPlan) {
    var ph = 0;
    for (var i in timingPlan) {
        ph = ph + timingPlan[i].G + timingPlan[i].Y + timingPlan[i].R;
        if (clock < ph)
            return (parseInt(i) + 1);
    }
}

function printDiagram() {
    for (var i in trafficLights) {
        for (var j in trafficLights[i].Bulbs) {
            console.log(trafficLights[i].Bulbs[j].Diagram + " " + trafficLights[i].Id + " ID:" + trafficLights[i].Id + " " + trafficLights[i].Bulbs[j].Type);
        }
    }
}

function tableInit(TimingPlans, timePhaseDescription) {

    var maxPhase = 0;
    for (var i = 0; i < TimingPlans.length; i++) {
        if (maxPhase < TimingPlans[i].Phase.length) {
            maxPhase = TimingPlans[i].Phase.length;
        }
    }

    for (var i = maxPhase + 1; i <= 6; i++) {
        $("#dashboard table th.phase" + i).remove();
        $("#dashboard table td.phase" + i).remove();
        $("#controlPanel table tr:last").remove();
    }

    for (var i = 1; i < TimingPlans.length; i++) {
        var newTR = $("#dashboard table tbody tr:first").clone();
        newTR.find("input").attr("value", i);
        newTR.appendTo("#dashboard table tbody");
    }

    $("input:radio:eq(0)").prop("checked", true);

    // 填資料
    for (var i = 0; i < TimingPlans.length; i++) {
        $("#dashboard table tbody tr:eq(" + i + ")").find(".number span").text(TimingPlans[i].No);
        $("#dashboard table tbody tr:eq(" + i + ")").find(".cycle span").text(TimingPlans[i].Cycle);

        for (var j = 0; j < TimingPlans[0].Phase.length; j++) {
            $("#dashboard table tbody tr:eq(" + i + ")").find(".phase" + (j + 1) + ".ph span").text(TimingPlans[i].Phase[j].PH);
            $("#dashboard table tbody tr:eq(" + i + ")").find(".phase" + (j + 1) + ".g span").text(TimingPlans[i].Phase[j].G);
            $("#dashboard table tbody tr:eq(" + i + ")").find(".phase" + (j + 1) + ".y span").text(TimingPlans[i].Phase[j].Y);
            $("#dashboard table tbody tr:eq(" + i + ")").find(".phase" + (j + 1) + ".r span").text(TimingPlans[i].Phase[j].R);
        }
    }

    for (var i = 0; i < timePhaseDescription.length; i++)
    {
        var description = timePhaseDescription[i];
        $("#dashboard .description.phase" + (i+1)).html(description);
    }    

    $("#dashboard .progress-bar").each(function() {
        var max = $(this).parent().siblings('span').text();
        $(this).attr("aria-valuemax", max);
    });

    $(".progress").hide();

    $("#dashboard table th, #dashboard table td").addClass('text-center');

}

function saveTrafficLightJson(id) {

    $.ajax({
        url: "webAPI/saveTrafficLightHandler.ashx",
        type: "POST",
        data: {
            intersectionDetailId: id,
            trafficLightJson: JSON.stringify(trafficLights)
        },
        dataType: "text",
        success: function(data) {
            postToastr("1500");
        }
    });

}

function getTrafficLightJson(id) {
    var json;
    $.ajax({
        url: "webAPI/getTrafficLightHandler.ashx",
        type: "POST",
        data: {
            intersectionDetailId: id
        },
        dataType: "json",
        async: false,
        success: function(data) {

            json = data;

            for (var i = 0; i < json.length; i++) {
                json[i].Id = trafficLightIdIndex;
                trafficLightIdIndex++;
            }

        }
    });

    return json;
}

function getTimePhaseDescription(id) {
    var json;
    $.ajax({
        url: "webAPI/getTimePhaseDescriptionHandler.ashx",
        type: "POST",
        data: {
            intersectionDetailId: id
        },
        dataType: "json",
        async: false,
        success: function (data) {
            json = data;
        }
    });

    return json;
}

function getTimingPlanJson(id) {
    var json;
    $.ajax({
        url: "webAPI/getTimingPlansHandler.ashx",
        type: "POST",
        data: {
            intersectionDetailId: id
        },
        dataType: "json",
        async: false,
        success: function(data) {
            json = data;
            for (var i = 0; i < json.length; i++) {
                json[i].Cycle = 0;
                for (var j = 0; j < json[i].Phase.length; j++) {
                    json[i].Phase[j].PH = json[i].Phase[j].G + json[i].Phase[j].Y + json[i].Phase[j].R;
                    json[i].Cycle += json[i].Phase[j].PH;
                }
            }
        }
    });

    return json;
}

function getIntersectionJson(id) {
    var json;
    $.ajax({
        url: "webAPI/getIntersectionHandler.ashx",
        type: "POST",
        data: {
            intersectionDetailId: id
        },
        dataType: "json",
        async: false,
        success: function(data) {
            json = data;
        }
    });
    return json;
}

function postToastr(second) {
    // if (!short) {
    //     short = "success";
    // }
    // if (!msg) {
    //     msg = "存檔完成";
    // }
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
        "timeOut": second,
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "swing",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    }
    var $toast = toastr["success"]("存檔完成");
}
