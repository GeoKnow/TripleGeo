#!/bin/bash

cd /usr/lib/triplegeo

command=${1}

classpath='./lib/triplegeo.jar:/usr/share/java/*:./lib/vendor/*'

jvm_args='-Xms2048m'

case "${command}" in
    shp)
        main_class=eu.geoknow.athenarc.triplegeo.ShpToRdf
        config_file=${2}
        if test -z "${config_file}"; then
            echo "Convert a shapefile (SHP) into RDF"
            echo
            echo "Usage: ${0} ${command} <config-file>"
        else
            java ${jvm_args} -cp "${classpath}" ${main_class} ${config_file}
        fi
        ;;
    rdb)
        main_class=eu.geoknow.athenarc.triplegeo.wkt.RdbToRdf
        config_file=${2}
        if test -z "${config_file}"; then
            echo "Convert a relational table (RDB) into RDF"
            echo
            echo "Usage: ${0} ${command} <config-file>"
        else
            java ${jvm_args} -cp "${classpath}" ${main_class} ${config_file}
        fi
        ;;
    gml)
        main_class=eu.geoknow.athenarc.triplegeo.GmlToRdf
        input_file=${2}
        output_file=${3}
        if test -z "${input_file}"; then
            echo "Convert a GML file into RDF"
            echo
            echo "Usage: ${0} ${command} <input-file> [<output-file>]"
        else
            test -z "${output_file}" && output_file=/tmp/$(basename ${input_file}).rdf
            java ${jvm_args} -cp "${classpath}" ${main_class} ${input_file} ${output_file}
        fi
        ;;
    kml)
        main_class=eu.geoknow.athenarc.triplegeo.KmlToRdf
        input_file=${2}
        output_file=${3}
        if test -z "${input_file}"; then
            echo "Convert a KML file into RDF"
            echo
            echo "Usage: ${0} ${command} <input-file> [<output-file>]"
        else
            test -z "${output_file}" && output_file=/tmp/$(basename ${input_file}).rdf
            java ${jvm_args} -cp "${classpath}" ${main_class} ${input_file} ${output_file}
        fi
        ;;
    inspire)
        main_class=eu.geoknow.athenarc.triplegeo.InspireToRdf
        input_file=${2}
        output_file=${3}
        if test -z "${input_file}"; then
            echo "Convert an INSPIRE-aligned XML file into RDF"
            echo
            echo "Usage: ${0} ${command} <input-file> [<output-file>]"
        else
            test -z "${output_file}" && output_file=/tmp/$(basename ${input_file}).rdf
            java ${jvm_args} -cp "${classpath}" ${main_class} ${input_file} ${output_file}
        fi
        ;;
    *)
        echo "Usage: ${0} <command> <args>"
        echo "  <command>     one of {shp,rdb,gml,kml,inspire}"
        echo "  <args>        command-specific args" 
        ;;
esac    

exit 0
