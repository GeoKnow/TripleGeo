<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming datasets compliant with INSPIRE           -->
<!-- "Data Themes I : PROTECTED SITES" from GML into RDF.                  -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Nikos Georgomanolis, ngeorgomanolis@imis.athena-innovation.gr -->
<!-- Revised by: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr        -->
<!-- Version: 0.4                                                          -->
<!-- Last update: 24/3/2014                                                -->
<!-- ===================================================================== -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd/"
	xmlns:geo="http://www.opengis.net/ont/geosparql#"
	xmlns:base="urn:x-inspire:specification:gmlas:BaseTypes:3.2"
	xmlns:BASE="http://inspire.jrc.ec.europa.eu/schemas/base/3.2/"
	xmlns:gn="urn:x-inspire:specification:gmlas:GeographicalNames:3.0"
	xmlns:GN="http://inspire.jrc.ec.europa.eu/schemas/gn/3.0/"
	xmlns:ps="urn:x-inspire:specification:gmlas:ProtectedSites:3.0"
    xmlns:PS="http://inspire.jrc.ec.europa.eu/schemas/ps/3.0/" >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>

	<!-- Template to handle each Protected Site in the given GML -->	
	<xsl:template match='ps:ProtectedSite'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='ps:inspireID//base:localId' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />	

			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $t, '/', $id)" />
            </xsl:attribute>
		
		    <!-- Create LegalFoundationDocument element (may be NULL) -->
            <xsl:element name='PS:LegalFoundationDocument'>
                <xsl:value-of select='ps:LegalFoundationDocument' />
            </xsl:element>

			<!-- Create LegalFoundationDate element (may be NULL) -->
            <xsl:element name='PS:LegalFoundationDate'>
                <xsl:value-of select='ps:LegalFoundationDate' />
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
			<xsl:element name='PS:geometry'>
				<rdf:Description>
                    <xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
					</xsl:attribute>
					<!-- Geometry as GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select='ps:geometry' /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

			<!-- Process geographical names -->
			<xsl:element name='PS:siteName'>
				<rdf:Description >
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/siteName/', $id)"/>
					</xsl:attribute>

					<!-- Call generic template for all attributes in Geographical Names -->
					<xsl:for-each select="ps:siteName">
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

			<!-- Create SiteProtectionClassification element -->	
			<xsl:element name='PS:siteProtectionClassification'>
				<xsl:value-of select='ps:siteProtectionClassification' />
			</xsl:element>
		
			<!-- Create SiteDesignation element -->
			<xsl:element name='PS:siteDesignation'>
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/siteDesignation/', $id)" />
					</xsl:attribute>
					<xsl:element name='PS:designationScheme'>
						<xsl:value-of select='ps:siteDesignation//ps:designationScheme' />
					</xsl:element>
					<xsl:element name='PS:designation'>
						<xsl:value-of select='ps:siteDesignation//ps:designation' />
					</xsl:element>
					<xsl:element name='PS:percentageUnderDesignation'>
						<xsl:value-of select='ps:siteDesignation//ps:percentageUnderDesignation' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>
		
			<!-- Create InspireID element -->
			<xsl:element name='PS:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='ps:inspireID//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='ps:inspireID//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		</rdf:Description>
	</xsl:template>

</xsl:stylesheet>
