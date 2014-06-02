<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Main stylesheet for transforming INSPIRE datasets from GML into RDF.  -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- CAUTION: Depending on the dataset type (e.g., Administrative units),  -->
<!-- the respective stylesheet (e.g., InpireAU2RDF.xsl) must be included.  -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr            -->
<!-- Version: 0.3                                                          -->
<!-- Last update: 2/6/2014                                                -->
<!-- ===================================================================== -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:gmd="http://www.isotc211.org/2005/gmd/"
	xmlns:geo='http://www.opengis.net/ont/geosparql#'
	xmlns:ad="urn:x-inspire:specification:gmlas:Addresses:3.0"
    xmlns:AD="http://inspire.jrc.ec.europa.eu/schemas/ad/3.0/"
	xmlns:au="urn:x-inspire:specification:gmlas:AdministrativeUnits:3.0"
	xmlns:AU="http://inspire.jrc.ec.europa.eu/schemas/au/3.0/"
	xmlns:base="urn:x-inspire:specification:gmlas:BaseTypes:3.2"
	xmlns:BASE="http://inspire.jrc.ec.europa.eu/schemas/base/3.2/"
	xmlns:cp="urn:x-inspire:specification:gmlas:CadastralParcels:3.0"
	xmlns:CP="http://inspire.jrc.ec.europa.eu/schemas/cp/3.0/"
	xmlns:gn="urn:x-inspire:specification:gmlas:GeographicalNames:3.0"
	xmlns:GN="http://inspire.jrc.ec.europa.eu/schemas/gn/3.0/"
	xmlns:hy="urn:x-inspire:specification:gmlas:HydroBase:3.0"
	xmlns:HY="http://inspire.jrc.ec.europa.eu/schemas/hy/3.0/"
	xmlns:hy-n="urn:x-inspire:specification:gmlas:HydroNetwork:3.0"
	xmlns:HY-N="http://inspire.jrc.ec.europa.eu/schemas/hy-n/3.0/"
	xmlns:net="urn:x-inspire:specification:gmlas:Network:3.2"
	xmlns:NET="http://inspire.jrc.ec.europa.eu/schemas/net/3.2"
	xmlns:ps="urn:x-inspire:specification:gmlas:ProtectedSites:3.0"
    xmlns:PS="http://inspire.jrc.ec.europa.eu/schemas/ps/3.0/" 
	xmlns:tn="urn:x-inspire:specification:gmlas:CommonTransportElements:3.0"
	xmlns:TN="http://inspire.jrc.ec.europa.eu/schemas/tn/3.0/"
	xmlns:tn-ro="urn:x-inspire:specification:gmlas:RoadTransportNetwork:3.0"
	xmlns:TN-RO="http://inspire.jrc.ec.europa.eu/schemas/tn-ro/3.0/"  >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<!-- Include other XSLs that handle subsets of the data -->
	<xsl:include href="GML2WKT.xsl"/>
	<xsl:include href="GeographicalNames.xsl"/>
	
	<!-- EDIT: Include custom stylesheet for ONE specific data theme of INSPIRE Annex I -->
	<!-- xsl:include href="InspireAD2RDF.xsl"/ -->      <!-- Addresses -->
	<!-- xsl:include href="InspireAU2RDF.xsl"/ -->      <!-- Administrative Units -->
	<!-- xsl:include href="InspireCP2RDF.xsl"/ -->      <!-- Cadastral Parcels -->
	<!-- xsl:include href="InspireGN2RDF.xsl"/ -->      <!-- GeographicalNames -->
	<!-- xsl:include href="InspireHY2RDF.xsl"/ -->      <!-- Hydrography (Network) -->
	<xsl:include href="InspirePS2RDF.xsl"/>      <!-- Protected Sites -->
	<!-- xsl:include href="InspireTN-RO2RDF.xsl"/ -->   <!-- Transport Networks (Roads) -->
	
	<!-- EDIT: Specify ONE data topic that will be included in the URIs of the resulting RDF triples -->
	<!-- xsl:variable name='topic'><xsl:value-of>AddressesGR</xsl:value-of></xsl:variable -->
	<!-- xsl:variable name='topic'><xsl:value-of>Kallikratis</xsl:value-of></xsl:variable -->
	<!-- xsl:variable name='topic'><xsl:value-of>CadastralParcelsGR</xsl:value-of></xsl:variable -->
	<!-- xsl:variable name='topic'> <xsl:value-of>GeoNamesGR</xsl:value-of> </xsl:variable -->
	<!-- xsl:variable name='topic'><xsl:value-of>RiversGR</xsl:value-of></xsl:variable -->
	<xsl:variable name='topic'><xsl:value-of>Natura2000GR</xsl:value-of></xsl:variable>
	<!-- xsl:variable name='topic'><xsl:value-of>RoadsGR</xsl:value-of></xsl:variable -->
		
	<!-- EDIT: Compose the base URI for all RDF entities and the identifier of the resulting RDF dataset -->
	<xsl:variable name='baseURI' select="concat('http://geodata.gov.gr/','id/')" />
	<xsl:variable name="datasetid"><xsl:value-of select="base:SpatialDataSet/@gml:id"/></xsl:variable>
	<xsl:variable name="typeWKT"><xsl:value-of select="concat('http://www.opengis.net/ont/geosparql#','wktLiteral')" /></xsl:variable>
			
	<!-- Matching starts from here -->
	<xsl:template match='/'>
		<rdf:RDF>
			<!-- Export boundary (i.e., geographic extent) of the entire dataset (if included in the header of the original dataset) -->
			<!-- FIXME: Using a provisional URI for the RDF triple of this polygon geometry -->
			<xsl:if test="base:SpatialDataSet/gml:boundedBy">
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, 'boundary/',$topic, '/', $datasetid)" />   
					</xsl:attribute>
					<!-- Rectangular extent of the dataset as a GeoSPARQL WKT literal -->
					<xsl:element name='geo:asWKT'>
						<xsl:attribute name='rdf:datatype'>
							<xsl:value-of select='$typeWKT' />
						</xsl:attribute>
						<xsl:value-of><xsl:apply-templates select="base:SpatialDataSet/gml:boundedBy" /></xsl:value-of>
					</xsl:element>
				</rdf:Description>
			</xsl:if>
			
			<!-- Handle all other tags as specified by the custom templates, and for each feature create its RDF representation -->
			<xsl:apply-templates select="//base:member/*" />	
			
			<!-- ALTERNATIVE: Handle all other tags as required and for feature create its RDF representation-->
			<!-- xsl:apply-templates select="/*/node()[not(self::gml:boundedBy)]" / -->
			
		</rdf:RDF>
	</xsl:template>
	  
</xsl:stylesheet>

