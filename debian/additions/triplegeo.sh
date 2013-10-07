#!/bin/bash

runnable_class=${1}
config_file=${2}

java -cp '/usr/share/java/triplegeo.jar:/usr/share/java/triplegeo/vendor/lib/*' ${runnable_class} ${config_file}


