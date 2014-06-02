<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming datasets compliant with INSPIRE           -->
<!-- "Data Themes I : CADASTRAL PARCELS" from GML into RDF.                -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- FIXME: Nillable properties NOT handled : administrativeUnit, parcel,  -->
<!--        referencePoint, basicPropertyUnit, zoning, level, levelName,   -->
<!--        nationalCadastalZoningReference, originalMapScaleDenominator,  -->
<!--        upperLevelUnit.                                                -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr            -->
<!-- Version: 0.3                                                          -->
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
    xmlns:cp="urn:x-inspire:specification:gmlas:CadastralParcels:3.0"
	xmlns:CP="http://inspire.jrc.ec.europa.eu/schemas/cp/3.0/"	 >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>

	<!-- Template to handle each Cadastral Parcel in the given GML -->	
	<xsl:template match='cp:CadastralParcel'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='cp:inspireId//base:localId' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />	

			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $t, '/', $id)" />
            </xsl:attribute>
		
			<!-- Create 'beginLifespanVersion' element (may be NULL) -->
			<xsl:element name='CP:beginLifespanVersion'>
				<xsl:value-of select='cp:beginLifespanVersion' />
			</xsl:element>
			
			<!-- Create 'endLifespanVersion' element (may be NULL) -->
			<xsl:element name='CP:endLifespanVersion'>
				<xsl:value-of select='cp:endLifespanVersion' />
			</xsl:element>	
			
		    <!-- Create 'label' element (may be NULL) -->
            <xsl:element name='CP:label'>
                <xsl:value-of select='cp:label' />
            </xsl:element>
			
		    <!-- Create 'nationalCadastralReference' element (may be NULL) -->
            <xsl:element name='CP:nationalCadastralReference'>
                <xsl:value-of select='cp:nationalCadastralReference' />
            </xsl:element>
			
			<!-- Create 'validFrom' element (may be NULL) -->
            <xsl:element name='CP:validFrom'>
                <xsl:value-of select='cp:validFrom' />
            </xsl:element>
		
		    <!-- Create 'validTo' element (may be NULL) -->
            <xsl:element name='CP:validTo'>
                <xsl:value-of select='cp:validTo' />
            </xsl:element>
			
			<!-- Create geometry RDF - GeoSPARQL Specs -->
			<xsl:element name='geo:hasGeometry' >
				<rdf:Description>
                    <xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
                    </xsl:attribute>
                </rdf:Description>
			</xsl:element>
	
			<!-- Create geometry RDF - INSPIRE specs -->
			<xsl:element name='CP:geometry'>
				<rdf:Description>
                    <xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
					</xsl:attribute>
					<!-- Geometry as GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select='cp:geometry' /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

			<!-- Process geographical names (if exist) -->
			<xsl:if test="CP:name">
				<xsl:element name='CP:name'>
					<rdf:Description >
						<xsl:attribute name='rdf:about'>
							<xsl:value-of select="concat($baseURI, $t, '/siteName/', $id)"/>
						</xsl:attribute>

						<!-- Call generic template for all attributes in Geographical Names -->
						<xsl:for-each select="cp:name">
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
			</xsl:if>
	
			<!-- Create 'estimatedAccuracy' element (may be NULL) -->
            <xsl:element name='CP:estimatedAccuracy'>
                <xsl:value-of select='cp:estimatedAccuracy' />
            </xsl:element>
			
			<!-- Create 'areaValue' element (may be NULL) -->	
			<!-- FIXME: Check the units that area values are expressed in. -->
			<xsl:element name='CP:areaValue'>
				<xsl:attribute name='rdf:datatype'>
					<xsl:choose>
						<xsl:when test="*[@uom = 'm']"> <xsl:value-of select="concat('http://www.opengis.net/def/uom/OGC/1.0/','metre')" /> </xsl:when>	
						<xsl:when test="*[@uom = 'm2']"> <xsl:value-of select="concat('http://www.w3.org/2001/XMLSchema#','double')" /> </xsl:when>	
					</xsl:choose>				
				</xsl:attribute>
				<xsl:value-of select='cp:areaValue' />
			</xsl:element>
				
			<!-- Create InspireID element -->
			<xsl:element name='CP:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='cp:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='cp:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		</rdf:Description>
	</xsl:template>

</xsl:stylesheet>
