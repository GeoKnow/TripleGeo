<?xml version="1.0" encoding="UTF-8"?>
<!-- ================================================================ -->
<!-- Stylesheet for transforming geodatasets from KML into RDF.       -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.       -->
<!-- Spatial types currently handled in Placemarks: Point, LineString,-->
<!--     LinearRing, Polygon, GeometryCollection.                     -->
<!-- CAUTION: Exported 2-d coordinates are georeferenced in WGS84.    -->
<!-- CAUTION: Conversion ignores non-spatial features and attributes. -->
<!-- Project: GeoKnow, http://geoknow.eu                              -->
<!-- Institute for the Management of Information Systems, Athena R.C. -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr       -->
<!-- Version: 0.2                                                     -->
<!-- Last update: 2/6/2014                                            -->
<!-- ================================================================ -->
<xsl:stylesheet version="2.0" 
    xmlns="http://www.opengis.net/kml/2.2"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:geo="http://www.opengis.net/ont/geosparql#"
    xmlns:kml="http://www.opengis.net/kml/2.2"  >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<!-- Include other XSLs that handle subsets of the data -->
	<xsl:include href="KML2WKT.xsl"/>
	
	<!-- EDIT: Compose the base URI for all RDF entities -->
	<xsl:variable name='baseURI' select="concat('http://geodata.gov.gr/','id/')" />
	
	<!-- EDIT: Specify the geospatial ontology for RDF geometries -->
	<xsl:variable name="typeWKT"><xsl:value-of select="concat('http://www.opengis.net/ont/geosparql#','wktLiteral')" /></xsl:variable>
	
	<!-- Matching starts from here -->
	<xsl:template match='/'>
		<rdf:RDF>
			<!-- Handle all tags as specified by the custom templates, and for each feature create its RDF representation -->
            <xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	
	<!-- EDIT: Ignore non-spatial attributes, symbology, and KML specifics -->
	<xsl:template match="*:Style" />
	<xsl:template match="*:open" />
	<xsl:template match="*:name" />
	<xsl:template match="*:visibility" />
	<xsl:template match="*:description" />
	<xsl:template match="*:LookAt" />
	<xsl:template match="*:styleUrl" />
	<xsl:template match="*:extrude" />
	<xsl:template match="*:altitudeMode" />
	<xsl:template match="*:Icon" />
    <xsl:template match="*:LatLonBox" />

	
	<!-- Template to handle each Placemark in the given KML -->	
	<xsl:template match='*:Placemark'>
		<rdf:Description>
		
		    <!-- Use an existing placemark identifier, otherwise generate a random one -->
			<xsl:variable name='id' select="if (@id) then @id else generate-id()" />
			
			<xsl:attribute name='rdf:about'>
				<xsl:value-of select="concat($baseURI, $id)" />
			</xsl:attribute>
		
			<!-- Create 'rdfs:label' element with the 'name' attribute -->
			<xsl:element name='rdfs:label'>
				<xsl:value-of select='*:name' />
			</xsl:element>
			
			<!-- Create geometry RDF - GeoSPARQL specs -->
			<xsl:element name='geo:hasGeometry' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, 'geometry/', $id)" />
					</xsl:attribute>
					<!-- Geometry as GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select=' *:Point | *:LineString | *:Polygon |*:MultiGeometry ' /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		</rdf:Description>
	</xsl:template>
	
</xsl:stylesheet>
