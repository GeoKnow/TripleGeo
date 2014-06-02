<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming datasets compliant with INSPIRE           -->
<!-- "Data Themes I : HYDROGRAPY (NETWORK)" from GML into RDF.               -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- FIXME: Nillable properties NOT handled : relatedHydroObject.          -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr            -->
<!-- Version: 0.2                                                          -->
<!-- Last update: 21/3/2014                                                -->
<!-- ===================================================================== -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd/"
	xmlns:geo='http://www.opengis.net/ont/geosparql#'
	xmlns:base="urn:x-inspire:specification:gmlas:BaseTypes:3.2"
	xmlns:BASE="http://inspire.jrc.ec.europa.eu/schemas/base/3.2/"
	xmlns:gn="urn:x-inspire:specification:gmlas:GeographicalNames:3.0"
	xmlns:GN="http://inspire.jrc.ec.europa.eu/schemas/gn/3.0/"
	xmlns:hy="urn:x-inspire:specification:gmlas:HydroBase:3.0"
	xmlns:HY="http://inspire.jrc.ec.europa.eu/schemas/hy/3.0/"
	xmlns:hy-n="urn:x-inspire:specification:gmlas:HydroNetwork:3.0"
	xmlns:HY-N="http://inspire.jrc.ec.europa.eu/schemas/hy-n/3.0/"
	xmlns:net="urn:x-inspire:specification:gmlas:Network:3.2"
	xmlns:NET="http://inspire.jrc.ec.europa.eu/schemas/net/3.2"	>
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>

	<!-- Template to handle each link of Hydrography Network in the given GML -->	
	<xsl:template match='hy-n:WatercourseLink'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='net:inspireId//base:localId' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />	

			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $t, '/', $id)" />
            </xsl:attribute>
		
			<!-- Create 'beginLifespanVersion' element (may be NULL) -->
			<xsl:element name='NET:beginLifespanVersion'>
				<xsl:value-of select='net:beginLifespanVersion' />
			</xsl:element>

			<!-- Create 'endLifespanVersion' element (may be NULL) -->
			<xsl:element name='NET:endLifespanVersion'>
				<xsl:value-of select='net:endLifespanVersion' />
			</xsl:element>
			
		    <!-- Create 'inNetwork' element (may be NULL) -->
            <xsl:element name='NET:inNetwork'>
                <xsl:value-of select='net:inNetwork' />
            </xsl:element>

			<!-- Create 'fictitious' element (may be NULL) -->
            <xsl:element name='NET:fictitious'>
                <xsl:value-of select='net:fictitious' />
            </xsl:element>
		
			<!-- Create geometry RDF - GeoSPARQL specs -->
			<xsl:element name='geo:hasGeometry' >
				<rdf:Description>
                    <xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
                    </xsl:attribute>
                </rdf:Description>
			</xsl:element>
	
			<!-- Create geometry RDF - INSPIRE specs -->
			<xsl:element name='NET:centrelineGeometry'>
				<rdf:Description>
                    <xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
					</xsl:attribute>
					<!-- Geometry as GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select='net:centrelineGeometry' /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

			<!-- Process geographical names -->
			<xsl:element name='HY-N:geographicalName'>
				<rdf:Description >
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/name/', $id)"/>
					</xsl:attribute>

					<!-- Call generic template for all attributes in Geographical Names -->
					<xsl:for-each select="hy-n:geographicalName">
						<xsl:call-template name="names" >
							<xsl:with-param name='baseURI'>
								<xsl:value-of select='$baseURI' />
							</xsl:with-param>
							<xsl:with-param name='id'>
								<xsl:value-of select='$id'/>
							</xsl:with-param>
							<xsl:with-param name='theme'>
								<xsl:value-of select='$t' />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</rdf:Description>
			</xsl:element>

			<!-- Create 'flowDirection' element (may be NULL) -->	
			<xsl:element name='HY-N:flowDirection'>
				<xsl:value-of select='hy-n:flowDirection' />
			</xsl:element>
			
			<!-- Create 'length' element (may be NULL) -->	
			<!-- FIXME: Check the units that length values are expressed in. -->
			<xsl:element name='HY-N:length'>
				<xsl:attribute name='rdf:datatype'>
					<xsl:choose>
						<xsl:when test="*[@uom = 'm']"> <xsl:value-of select="concat('http://www.opengis.net/def/uom/OGC/1.0/','metre')" /> </xsl:when>	
						<!-- xsl:when test="*[@uom = 'd']"> <xsl:value-of select="concat('http://www.opengis.net/def/uom/OGC/1.0/','degree')" /> </xsl:when -->	
					</xsl:choose>				
				</xsl:attribute>
				<xsl:value-of select='hy-n:length' />
			</xsl:element>
				
			<!-- Create 'hydroId' element -->
			<!-- FIXME: Is it equivalent to InspireID ?  Then, it may be redundant? -->
			<xsl:element name='HY-N:hydroId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/hydroId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='HY:localId'>
						<xsl:value-of select='hy-n:hydroId//hy:localId' />
					</xsl:element>
					<xsl:element name='HY:namespace'>
						<xsl:value-of select='hy-n:hydroId//hy:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>
			
			<!-- Create InspireID element -->
			<xsl:element name='NET:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='net:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='net:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		</rdf:Description>
	</xsl:template>

</xsl:stylesheet>
