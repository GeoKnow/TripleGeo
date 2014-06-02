<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming datasets compliant with INSPIRE           -->
<!-- "Data Themes I : ADMINISTRATIVE UNITS" from GML into RDF.             -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- FIXME: Nillable properties NOT handled : condominium, lowerLevelUnit, -->
<!--        upperLevelUnit, administeredBy, coAdminister, legalStatus,     -->
<!--        technicalStatus, admUnit.                                      -->
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
    xmlns:au="urn:x-inspire:specification:gmlas:AdministrativeUnits:3.0"
    xmlns:AU="http://inspire.jrc.ec.europa.eu/schemas/au/3.0/" >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<!-- Template to handle each Administrative Unit in the given GML -->	
	<xsl:template match='au:AdministrativeUnit'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='au:inspireId//base:localId' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />

			<xsl:attribute name='rdf:about'>
				<xsl:value-of select="concat($baseURI, $t, '/', $id)" />
			</xsl:attribute>
			
			<!-- Create beginLifespanVersion element (may be NULL) -->
			<xsl:element name='AU:beginLifespanVersion'>
				<xsl:value-of select='au:beginLifespanVersion' />
			</xsl:element>

			<!-- Create 'endLifespanVersion' element (may be NULL) -->
			<xsl:element name='AU:endLifespanVersion'>
				<xsl:value-of select='au:endLifespanVersion' />
			</xsl:element>
			
			<!-- Create 'boundary' element (may be NULL) -->
			<xsl:element name='AU:boundary'>
				<xsl:value-of select='au:boundary' />
			</xsl:element>
				
		    <!-- Create residenceOfAuthority element (may be NULL) -->
		    <xsl:element name='AU:residenceOfAuthority'>
				<xsl:value-of select='au:residenceOfAuthority' />
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
			<xsl:element name='AU:geometry'>
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
					</xsl:attribute>
					<!-- Geometry as GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select='au:geometry' /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
		   </xsl:element>

			<!-- Process geographical names -->
			<xsl:element name='AU:name'>
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/name/', $id)"/>
					</xsl:attribute>

					<!-- Call generic template for all attributes in Geographical Names -->
					<xsl:for-each select="au:name">
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

			<!-- Create NationalCode element -->
			<xsl:element name='AU:nationalCode'>
				<xsl:value-of select='au:nationalCode' />
			</xsl:element>
			
			<!-- Create NationalLevel element -->
			<xsl:element name='AU:nationalLevel'>
				<xsl:value-of select='au:nationalLevel' /> 
			</xsl:element>					
			
			<!-- Create NationalLevelName element -->
			<xsl:element name='AU:nationalLevelName'>
				<xsl:value-of select='au:nationalLevelName/gmd:LocalisedCharacterString' />
			</xsl:element>
			
			<!-- Create NUTS element -->
			<xsl:element name='AU:NUTS'>
				<xsl:value-of select='au:NUTS'/>
			</xsl:element>		

			<!-- Create InspireID element -->
			<xsl:element name='AU:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='au:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='au:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>

			<!-- Create Country element -->
			<xsl:element name='AU:country' >
				<rdf:Description >
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/country/', $id)" />
					</xsl:attribute> 
					<xsl:element name='gmd:Country'>
						<xsl:value-of select='au:country'/>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		 </rdf:Description>
	</xsl:template>

</xsl:stylesheet>
