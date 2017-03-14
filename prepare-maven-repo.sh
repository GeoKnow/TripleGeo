 #!/bin/bash

mkdir -p ./repo

#mvn install:install-file -Dfile=lib/hatbox-1.0.b7.jar -DgroupId=vendor -DartifactId=hatbox -Dversion=1.0.b7 -Dpackaging=jar -DlocalRepositoryPath=./repo/
 
mvn install:install-file -Dfile=lib/jena-2.6.3.jar -DgroupId=vendor -DartifactId=jena -Dversion=2.6.3 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/tdb-0.8.7.jar -DgroupId=vendor -DartifactId=tdb -Dversion=0.8.7 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/gt-main-2.7-M0.jar -DgroupId=vendor -DartifactId=gt-main -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/jts-1.11.jar -DgroupId=vendor -DartifactId=jts -Dversion=1.11 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/net.opengis.ows-2.7-M0.jar -DgroupId=vendor -DartifactId=net.opengis.ows -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/net.opengis.wcs-2.7-M0.jar -DgroupId=vendor -DartifactId=net.opengis.wcs -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/net.opengis.wfs-2.7-M0.jar -DgroupId=vendor -DartifactId=net.opengis.wfs -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/net.opengis.wfsv-2.7-M0.jar -DgroupId=vendor -DartifactId=net.opengis.wfsv -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/net.opengis.wps-2.7-M0.jar -DgroupId=vendor -DartifactId=net.opengis.wps -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/gt-referencing-2.7-M0.jar -DgroupId=vendor -DartifactId=gt-referencing -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/geoapi-2.3-M1.jar -DgroupId=vendor -DartifactId=geoapi -Dversion=2.3-M1 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/gt-metadata-2.7-M0.jar -DgroupId=vendor -DartifactId=gt-metadata -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/gt-api-2.7-M0.jar -DgroupId=vendor -DartifactId=gt-api -Dversion=2.7-M0 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/geoapi-pending-2.3-M1.jar -DgroupId=vendor -DartifactId=geoapi-pending -Dversion=2.3-M1 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/geoapi-pending-2.3-M1.jar -DgroupId=vendor -DartifactId=geoapi-pending -Dversion=2.3-M1 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/arq-2.8.5.jar -DgroupId=vendor -DartifactId=arq -Dversion=2.8.5 -Dpackaging=jar -DlocalRepositoryPath=./repo/
mvn install:install-file -Dfile=lib/iri-0.8.jar -DgroupId=vendor -DartifactId=iri -Dversion=0.8 -Dpackaging=jar -DlocalRepositoryPath=./repo/
