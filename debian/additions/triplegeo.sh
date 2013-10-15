#!/bin/bash

command=${1}
config_file=${2}

if test "${command}" == "run-on-shp" 
then
    runnable_class=eu.geoknow.athenarc.triplegeo.ShpToRdf
elif test "${command}" == "run-on-rdb"
then
    runnable_class=eu.geoknow.athenarc.triplegeo.wkt.RdbToRdf
else
    echo "Usage: ${0} <command> <config-file>"
    echo "  <command>          one of {help,run-on-shp,run-on-rdb}"
    echo "  <config-file>      ini-style configuration file" 
    exit 0
fi

classpath='/usr/share/java/triplegeo.jar:/usr/share/java/*:/usr/share/java/triplegeo/vendor/lib/*'

java -Xms2048m -cp "${classpath}" ${runnable_class} ${config_file}

exit 0
