<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming datasets compliant with INSPIRE           -->
<!-- "Data Themes I : TRANSPORT NETWORKS (ROADS)" from GML into RDF.       -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- FIXME: A simplified schema is followed, due to many missing properties-->
<!-- in the original data. The official INSPIRE specification includes     -->
<!-- many properties that reflect traffic regulations, speed limits,       -->
<!-- number of lanes, maintenance authorities, road classification etc.    -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr            -->
<!-- Version: 0.2                                                          -->
<!-- Last update: 24/3/2014                                                -->
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
    xmlns:tn="urn:x-inspire:specification:gmlas:CommonTransportElements:3.0"
	xmlns:TN="http://inspire.jrc.ec.europa.eu/schemas/tn/3.0/"
	xmlns:tn-ro="urn:x-inspire:specification:gmlas:RoadTransportNetwork:3.0"
	xmlns:TN-RO="http://inspire.jrc.ec.europa.eu/schemas/tn-ro/3.0/"
	xmlns:net="urn:x-inspire:specification:gmlas:Network:3.2"
	xmlns:NET="http://inspire.jrc.ec.europa.eu/schemas/net/3.2"	>
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<!-- Template to handle each link of Transport (Road) Network in the given GML -->	
	<xsl:template match='tn-ro:RoadLink'>
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
			<xsl:element name='TN:geographicalName'>
				<rdf:Description >
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/name/', $id)"/>
					</xsl:attribute>

					<!-- Call generic template for all attributes in Geographical Names -->
					<xsl:for-each select="tn:geographicalName">
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
