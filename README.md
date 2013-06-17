<html>
<HEAD>
</head>
<body>

<div id="readme" class="clearfix announce instapaper_body md">
<article class="markdown-body entry-content" itemprop="mainContentOfPage">

<h2><a name="welcome-to-triplegeo" class="anchor" href="#welcome-to-triplegeo"><span class="octicon octicon-link"></span></a>Welcome to TripleGeo: An open-source tool for extracting geospatial features into RDF triples</h2>

<p>TripleGeo is a utility developed by the <a href="http://www.ipsyp.gr/">Institute for the Management of Information Systems</a> at <a href="http://www.athena-innovation.gr/en.html">Athena Research Center</a> under the EU/FP7 project <a href="http://geoknow.eu">GeoKnow: Making the Web an Exploratory for Geospatial Knowledge</a>. This generic purpose, open-source tool can be used for integrating features from geospatial databases into RDF triples.</p>

<p>TripleGeo is based on open-source utility <a href="https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF">geometry2rdf</a>. TripleGeo is written in Java and is still under development; more enhancements will be included in future releases. However, all supported features have been tested and work smoothly in both MS Windows and Linux platforms.</p>

<p>The web site for <a href="https://web.imis.athena-innovation.gr/redmine/projects/geoknow_public/wiki/TripleGeo">TripleGeo</a> provides more details about the project, its architecture, usage tips, and foreseen extensions.</p>

<h3>
<a name="quick-start" class="anchor" href="#Quick start"><span class="octicon octicon-link"></span></a>Quick start</h3>

<p>In order to use TripleGeo you need Java JRE/SDK 1.7 or newer on the path (check with <code>java -version</code> if you are not sure).</p>

How to use TripleGeo:
<ul>
<li>Download the code and extract the archive to a suitable location.</li>
<li>The current distribution comes with a dummy configuration file <code>options.conf</code>. This file contains indicative values for the most important properties. Self-contained brief instructions can guide you into the extraction process.</li>
<li>Run the utility from the command line in two alternative modes, depending on the input data source:</li>
<ul>
<li>In case that triples will be extracted from ESRI shapefiles, and assuming that binaries are bundled together in <code>TripleGeo.jar</code>, give a command like this:</br>
<code>java -cp lib/*;TripleGeo.jar eu.geoknow.athenarc.triplegeo.ShpToRdf options.conf</code></li>
<li>Alternatively, if triples will be extracted from a geospatially-enabled DBMS (e.g., Oracle Spatial), give a command like this:</br>
<code>java -cp lib/*;TripleGeo.jar eu.geoknow.athenarc.triplegeo.wkt.RdbToRdf options.conf</code></li>
</ul>
<li>Wait until the process gets finished, and verify that the resulting output file is according to your specifications.</li>
</ul>



<p>Indicative configuration files for several cases are available <a href="https://github.com/GeoKnow/TripleGeo/tree/master/test/conf/">here</a> in order to assist you when preparing your own.

<h3>
<a name="input" class="anchor" href="#Input"><span class="octicon octicon-link"></span></a>Input</h3>

<p>The current version of TripleGeo utility can access geometries from:</p>
<ul>
<li>ESRI shapefiles, a widely used file-based format for storing geospatial features.</li>
<li>Several geospatially-enabled DBMSs, including: Oracle Spatial 11g, PostGIS, MySQL, and IBM DB2 with Spatial extender.</li>
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
