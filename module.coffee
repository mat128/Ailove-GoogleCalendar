millisecondsToHours = (a) ->
  Math.round(a / 1e3 / 60 / 30) / 2

rangeToJs = (a) ->
  startTime: google.calendar.utils.toDate(a.startTime)
  endTime: google.calendar.utils.toDate(a.endTime)

rangeDuration = (a) ->
  a.endTime - a.startTime

rangeIntersection = (a, b) ->
  startTime: (if a.startTime > b.startTime then a.startTime else b.startTime)
  endTime: (if a.endTime < b.endTime then a.endTime else b.endTime)

eventsCallback = (a) ->
  console.log(a)
  b = {}
  d = 0
  k = ""
  f = 0
  a.forEach (c) ->
    c.events.forEach (e) ->
      unless e.allDay
        g = rangeDuration(rangeIntersection(visibleDatesJs, rangeToJs(e)))
        f += g
        i = /^tags: ?((?:.*, ?)*.*)$/m.exec(e.details)
        unless i
          d += g
          k += e.title + " "

  a = "<table width=\"100%\" style=\"font-size:smaller\"><tr style=\"background: #e8eef7\"><th>" + prefs.getMsg("Tag") + "</th><th>" + prefs.getMsg("Hours") + "</th><th>%</th></tr>"
  h = []
  for tag of b
    h.push
      tag: tag
      count: b[tag]

  h.sort (c, e) ->
    e.count - c.count

  a += h.map((c) ->
    "<tr><td>" + c.tag + "</td><td align=\"right\">" + millisecondsToHours(c.count) + "</td><td align=\"right\">" + Math.round(100 * c.count / f) + "%</td></tr>"
  ).join("")
  a += "<tr style=\"color: red\"><td>untagged</td><td align=\"right\">" + millisecondsToHours(d) + "</td><td align=\"right\">" + Math.round(100 * d / f) + "%</td></tr>"  if d
  a += "<tr style=\"background: #e8eef7\"><th>" + prefs.getMsg("Total") + "</th><th align=\"right\">" + millisecondsToHours(f) + "</th><th>100%</th></tr></table>"
  a += "<center style=\"font-size:xx-small\">&copy;" + (new Date).getFullYear() + " <a href=\"http://www.TheProductivityGame.com/TimeTracker\" target=\"_blank\">The Productivity Game</a></center>"
  document.getElementById("main").innerHTML = a
  gadgets.window.adjustHeight()

prefs = new gadgets.Prefs

visibleDatesJs = undefined

gadgets.util.registerOnLoadHandler ->
  a = ->
    b and google.calendar.read.getEvents(eventsCallback, "selected", b.startTime, b.endTime,
      requestedFields: [ "details" ]
    )
  b = undefined
  
  google.calendar.subscribeToDates (d) ->
    b = d
    b.endTime.date++
    visibleDatesJs = rangeToJs(b)
    a()

  google.calendar.subscribeToDataChange a
