#!/bin/bash
f=TimeTracker
cat $f-header.xml > $f.xml
coffee -cb module.coffee & cat module.js >> $f.xml
echo '</script>]]></Content></Module>' >> $f.xml 
