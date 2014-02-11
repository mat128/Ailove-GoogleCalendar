var prefs = new gadgets.Prefs;

function millisecondsToHours(a) {
    return Math.round(a / 1E3 / 60 / 30) / 2
}

function rangeToJs(a) {
    return {
        startTime: google.calendar.utils.toDate(a.startTime),
        endTime: google.calendar.utils.toDate(a.endTime)
    }
}

function rangeDuration(a) {
    return a.endTime - a.startTime
}

function rangeIntersection(a, b) {
    return {
        startTime: a.startTime > b.startTime ? a.startTime : b.startTime,
        endTime: a.endTime < b.endTime ? a.endTime : b.endTime
    }
}
var visibleDatesJs;

function eventsCallback(a) {
    var b = {}, d = 0,
        k = "",
        f = 0;
    a.forEach(function (c) {
        c.events.forEach(function (e) {
            if (!e.allDay) {
                var g = rangeDuration(rangeIntersection(visibleDatesJs, rangeToJs(e)));
                f += g;
                var i = /^tags: ?((?:.*, ?)*.*)$/m.exec(e.details);
                if (i) i[1].split(/, ?/).forEach(function (j) {
                    b[j] = (b[j] || 0) + g
                });
                else {
                    d += g;
                    k += e.title + " "
                }
            }
        })
    });
    a = '<table width="100%" style="font-size:smaller"><tr style="background: #e8eef7"><th>' + prefs.getMsg("Tag") + "</th><th>" + prefs.getMsg("Hours") + "</th><th>%</th></tr>";
    var h = [];
    for (tag in b) h.push({
        tag: tag,
        count: b[tag]
    });
    h.sort(function (c, e) {
        return e.count - c.count
    });
    a += h.map(function (c) {
        return "<tr><td>" + c.tag + '</td><td align="right">' + millisecondsToHours(c.count) + '</td><td align="right">' + Math.round(100 * c.count / f) + "%</td></tr>"
    }).join("");
    if (d) a += '<tr style="color: red"><td>untagged</td><td align="right">' + millisecondsToHours(d) + '</td><td align="right">' + Math.round(100 * d / f) + "%</td></tr>";
    a += '<tr style="background: #e8eef7"><th>' + prefs.getMsg("Total") + '</th><th align="right">' + millisecondsToHours(f) + "</th><th>100%</th></tr></table>";
    a += '<center style="font-size:xx-small">&copy;' + (new Date).getFullYear() + ' <a href="http://www.TheProductivityGame.com/TimeTracker" target="_blank">The Productivity Game</a></center>';
    document.getElementById("main").innerHTML = a;
    gadgets.window.adjustHeight()
}
gadgets.util.registerOnLoadHandler(function () {
    function a() {
        b && google.calendar.read.getEvents(eventsCallback, "selected", b.startTime, b.endTime, {
            requestedFields: ["details"]
        })
    }
    var b;
    google.calendar.subscribeToDates(function (d) {
        b = d;
        b.endTime.date++;
        visibleDatesJs = rangeToJs(b);
        a()
    });
    google.calendar.subscribeToDataChange(a)
});