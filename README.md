<html>
<HEAD>
</head>
<body>

<div id="readme" class="clearfix announce instapaper_body md">
<article class="markdown-body entry-content" itemprop="mainContentOfPage">

<h1><a name="welcome-to-triplegeo" class="anchor" href="#welcome-to-triplegeo"><span class="octicon octicon-link"></span></a>TripleGeo: An open-source tool for extracting geospatial features into RDF triples</h1>

<p>TripleGeo is a utility developed by the <a href="http://www.ipsyp.gr/">Institute for the Management of Information Systems</a> at <a href="http://www.athena-innovation.gr/en.html">Athena Research Center</a> under the EU/FP7 project <a href="http://geoknow.eu">GeoKnow: Making the Web an Exploratory for Geospatial Knowledge</a>. This generic purpose, open-source tool can be used for integrating features from geospatial databases into RDF triples.</p>

<p>TripleGeo is based on open-source utility <a href="https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF">geometry2rdf</a>. TripleGeo is written in Java and is still under development; more enhancements will be included in future releases. However, all supported features have been tested and work smoothly in both MS Windows and Linux platforms.</p>

<p>The web site for <a href="https://web.imis.athena-innovation.gr/redmine/projects/geoknow_public/wiki/TripleGeo">TripleGeo</a> provides more details about the project, its architecture, usage tips, and foreseen extensions.</p>

<h2>
<a name="quick-start" class="anchor" href="#Quick start"><span class="octicon octicon-link"></span></a>Quick start</h2>

How to use TripleGeo:

You have 2 options: either build from source (using Apache Ant) or use the prepackaged binaries (JARs) shipped with this code.

<h4>1.a Build from source</h4>

<ul>
<li>Build (with ant):<br/>
<code>mkdir build</code><br/>
<code>ant compile</code>
</li>
<li>Package as a jar (with ant):<br/>
<code>ant package</code><br/>
If build finishes successfully, generated JARs will be placed under <code>build/jars</code>.
</li>
</ul>

<h4>1.b Use prepackaged JARs</h4>

In order to use TripleGeo for extracting triples from a spatial dataset, the user should follow these steps (in a Windows platform, but these are similar in Linux as well):
<ul>

<li>
Download the current software bundle from https://github.com/GeoKnow/TripleGeo/archive/master.zip</li>
<li>
Extract the downloaded .zip file into a separate folder, e.g., <code>c:\temp</code>.</li>
<li>
Open a terminal window (in DOS or in Linux) and navigate to the directory where TripleGeo has been extracted, e.g.,
<code>cd c:\temp\TripleGeo-master</code>. This directory must be the one that holds the LICENSE file. For convenience, this is where you can place your configuration file (e.g., options.conf), although you can specify another path for your configuration if you like.</li>
<li>Normally, under this same folder there must be a lib/ subdirectory with the required libraries. Make sure that the actual TripleGeo.jar is under the bin/ subdirectory.</li>
<li>Verify that Java JRE (or SDK) ver 1.7 or later is installed. Currently installed version of Java can be checked using <code>java –version</code> from the command line.</li>
<li>Next, specify all properties in the required configuration file, e.g., options.conf. You must specify correct paths to files (i.e., in[parameters inputFile, outputFile, and tmpDir), which are RELATIVE to the executable.</li>
<li>In case that triples will be extracted from ESRI shapefiles, give the following command (in one line):<br/>
    <code>java -cp lib/*;bin/TripleGeo.jar eu.geoknow.athenarc.triplegeo.ShpToRdf options.conf</code><br/>
Make sure that the specified paths to .jar files are correct. You must modify these paths to the libraries and/or the configuration file, if you run this command from a path other than the one containing the LICENSE file, as specified in step (3).</li>
<li>While conversion is running, it periodically issues notifications about its progress. Note that for large datasets (i.e., hundreds of thousands of records), conversion may take several minutes. As soon as processing is finished and all triples are written into a file, the user is notified about the total amount of extracted triples and the overall execution time.</li>

</ul>

<h4>2. Usage and examples</h4>

<p>The current distribution comes with a dummy configuration file <code>options.conf</code>. This file contains indicative values for the most important properties when accessing data from ESRI shapefiles or a spatial DBMS. Self-contained brief instructions can guide you into the extraction process.</p>
<p>Run the jar file from the command line in several alternative modes, depending on the input data source (of course, you should change the directory separator to the one your OS understands, e.g. ":" in the case of *nix systems):</p>

<p>In case that triples will be extracted from ESRI shapefiles, and assuming that binaries are bundled together in <code>triplegeo.jar</code>, give a command like this:</br>
<code>java -cp "./lib/*;./build/jars/triplegeo.jar" eu.geoknow.athenarc.triplegeo.ShpToRdf options.conf</code></p>
<p>Alternatively, if triples will be extracted from a geospatially-enabled DBMS (e.g., Oracle Spatial), give a command like this:</br>
<code>java -cp "./lib/*;./build/jars/triplegeo.jar" eu.geoknow.athenarc.triplegeo.wkt.RdbToRdf options.conf</code></p>

<p>Wait until the process gets finished, and verify that the resulting output file is according to your specifications.</p>

The current distribution also offers transformations from other geographical formats, and it also supports GML datasets aligned to EU INSPIRE Directive. More specifically, TripleGeo can transform into RDF triples geometries available in GML (Geography Markup Language) and KML (Keyhole Markup Language). It can also handle INSPIRE-aligned GML data for seven Data Themes (Annex I). Assuming that binaries are bundled together in <code>triplegeo.jar</code>, you may transform such datasets as follows:
<ul>
<li>In case that triples will be extracted from a GML file, give a command like this:</br>
<code>java -cp "./lib/*;./build/jars/triplegeo.jar" eu.geoknow.athenarc.triplegeo.GmlToRdf <input.gml> <output.rdf> </code></li>
<li>In case that triples will be extracted from a KML file, give a command like this:</br>
<code>java -cp "./lib/*;./build/jars/triplegeo.jar" eu.geoknow.athenarc.triplegeo.KmlToRdf <input.kml> <output.rdf> </code></li>
<li>In case that triples will be extracted from an INSPIRE-aligned GML file, you must first configure XSL stylesheet <code>Inspire_main.xsl</code> with specific parameters and then give a command like this:</br>
<code>java -cp "./lib/*;./build/jars/triplegeo.jar" eu.geoknow.athenarc.triplegeo.InspireToRdf <input.gml> <output.rdf> </code></li>
</ul>

An alternative way to run the TripleGeo utility (the jar file) is provided via ant targets:<br/>
in the case of a shapefile input:<br/>
<code>ant run-on-shp -Dconfig=options.conf</code><br/>
in the case of the relational database:<br/>
<code>ant run-on-rdb -Dconfig=options.conf</code><br/>
in the case of a GML input:<br/>
<code>ant run-on-gml -Dinput=sample.gml -Doutput=sample.rdf</code><br/>
in the case of a KML input:<br/>
<code>ant run-on-kml -Dinput=sample.kml -Doutput=sample.rdf</code><br/>
in the case of an INSPIRE-aligned XML input:<br/>
<code>ant run-on-inspire -Dinput=sample.xml -Doutput=sample.rdf</code><br/>

<p>Indicative configuration files for several cases are available <a href="https://github.com/GeoKnow/TripleGeo/tree/master/test/conf/">here</a> in order to assist you when preparing your own.

<h3>
<a name="input" class="anchor" href="#Input"><span class="octicon octicon-link"></span></a>Input</h3>

<p>The current version of TripleGeo utility can access geometries from:</p>
<ul>
<li>ESRI shapefiles, a widely used file-based format for storing geospatial features.</li>
<li>Geographical data stored in GML (Geography Markup Language) and KML (Keyhole Markup Language).</li>
<li>INSPIRE-aligned datasets for seven Data Themes (Annex I) in GML format: Addresses, Administrative Units, Cadastral Parcels, GeographicalNames, Hydrography, Protected Sites, and Transport Networks (Roads).</li>
<li>Several geospatially-enabled DBMSs, including: Oracle Spatial, PostGIS, MySQL, and IBM DB2 with Spatial extender.</li>
</ul>
</ul>

<p>Sample geographic <a href="https://github.com/GeoKnow/TripleGeo/tree/master/test/data/">datasets</a> for testing are available in ESRI shapefile format.</p>

<h3>
<a name="output" class="anchor" href="#Output"><span class="octicon octicon-link"></span></a>Output</h3>

<p>In terms of <i>output serializations</i>, triples can be obtained in one of the following formats: RDF/XML (<i>default</i>), RDF/XML-ABBREV, N-TRIPLES, N3, TURTLE (TTL).</p>
<p>Concerning <i>geospatial representations</i>, triples can be exported according to:</p>
<ul>
<li>the <a href="https://portal.opengeospatial.org/files/?artifact_id=47664">GeoSPARQL standard</a> for several geometric types (including points, linestrings, and polygons)</li>
<li>the <a href="http://www.w3.org/2003/01/geo/">WGS84 RDF Geoposition vocabulary</a> for point features</li>
<li>the <a href="http://docs.openlinksw.com/virtuoso/rdfsparqlgeospat.html">Virtuoso RDF vocabulary</a> for point features.</li>
</ul>

<p>Resulting triples are written into a local file, so that they can be readily imported into a triple store.</p>


<h2>
<a name="license" class="anchor" href="#license"><span class="octicon octicon-link"></span></a>License</h2>

<p>The contents of this project are licensed under the <a href="https://github.com/GeoKnow/TripleGeo/blob/master/LICENSE">GPL v3 License</a>.</p></article>

</body>
</html>
