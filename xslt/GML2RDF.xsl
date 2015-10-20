<?xml version="1.0" encoding="UTF-8"?>
<!-- ======================================================================= -->
<!-- Stylesheet for transforming geodatasets from GML into RDF.              -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.              -->
<!-- Spatial types currently handled: (MULTI)POINT, (MULTI)LINESTRING,       -->
<!-- (MULTI)POLYGON, CURVE, MULTISURFACE, MULTIGEOMETRY, GEOMETRYCOLLECTION. -->
<!-- CAUTION: Conversion ignores non-spatial features and attributes.        -->
<!-- IMPORTANT: Input dataset must be specified w.r.t. GML 3.2; set namespace-->
<!--          xmlns:gml="http://www.opengis.net/gml/3.2" in input file.      -->
<!-- Project: GeoKnow, http://geoknow.eu                                     -->
<!-- Institute for the Management of Information Systems, Athena R.C.        -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr              -->
<!-- Version: 0.2                                                            -->
<!-- Last update: 7/4/2014                                                   -->
<!-- ======================================================================= -->
<xsl:stylesheet version="2.0" 
    xmlns="http://www.opengis.net/gml/3.2"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:geo="http://www.opengis.net/ont/geosparql#"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:ogr="http://ogr.maptools.org/"	>
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<!-- Include other XSLs that handle subsets of the data -->
	<xsl:include href="GML2WKT.xsl"/>
	
	<!-- EDIT: Compose the base URI for all RDF entities -->
	<xsl:variable name='baseURI' select="concat('http://geodata.gov.gr/','id/')" />
	
	<!-- EDIT: Compose the identifier of the resulting RDF dataset -->
	<xsl:variable name="datasetid"><xsl:value-of select="*/@gml:id"/></xsl:variable>
	
	<!-- EDIT: Specify the geospatial ontology for RDF geometries -->
	<xsl:variable name="typeWKT"><xsl:value-of select="concat('http://www.opengis.net/ont/sf#','wktLiteral')" /></xsl:variable>
	
	<!-- FIXME: Examine whether it is possible to declare here all tags of interest as variables (e.g., properties for geometry, id, name, etc.) -->
	<xsl:variable name="geom"><xsl:value-of select="ogr:geometryProperty" /></xsl:variable>
	
	
	<!-- Matching starts from here -->
	<xsl:template match='/'>
		<rdf:RDF>
			<!-- Export boundary (i.e., geographic extent) of the entire dataset (if included in the header of the original dataset) -->
			<xsl:if test="//*:boundedBy">
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, 'boundary/', $datasetid)" />   
					</xsl:attribute>
					<!-- Rectangular extent of the dataset as a GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select="//*:boundedBy" /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:if>
			
			<!-- Handle all other tags as specified by the custom templates, and for each feature create its RDF representation -->
			<xsl:apply-templates select="//*:featureMember" />	

		</rdf:RDF>
	</xsl:template>
	
	<!-- Template to handle each feature in the given GML -->	
	<xsl:template match="ogr:oikodomika_tetragwna">     <!-- EDIT: Change this tag according to the given dataset -->
		<rdf:Description>
		    <!-- Use an existing feature or GML identifier, otherwise generate a random one -->
			<xsl:variable name='id' select="if (@gml:id) then @gml:id else generate-id()" />
			
			<xsl:attribute name='rdf:about'>
				<xsl:value-of select="concat($baseURI, $id)" />
			</xsl:attribute>
		
			<!-- EDIT: Create 'rdfs:label' element with a particular attribute -->
			<xsl:element name='rdfs:label'>
				<xsl:value-of select='ogr:arot' />
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
						<!-- EDIT: Change this geometry tag according to the given dataset -->
						<xsl:value-of><xsl:apply-templates select='ogr:geometryProperty' /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		</rdf:Description>
	</xsl:template>
	
</xsl:stylesheet>
