<?xml version="1.0" encoding="UTF-8"?>
<!-- ================================================================ -->
<!-- Stylesheet for transformation of 2-dimensional OGC geometries    -->
<!-- from Keyhole Markup Language (KML) to Well Known Text (WKT).     -->
<!-- Spatial types currently handled in Placemarks:                   -->
<!--     Point, LineString, Polygon, GeometryCollection.              -->
<!-- CAUTION: Returned 2-d coordinates are georeferenced in WGS84.    -->
<!-- Project: GeoKnow, http://geoknow.eu                              -->
<!-- Institute for the Management of Information Systems, Athena R.C. -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr       -->
<!-- Version: 0.2                                                     -->
<!-- Last update: 5/4/2014                                            -->
<!-- ================================================================ -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:kml="http://www.opengis.net/kml/2.2"  >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
		
	<!-- IMPORTANT: Specify here whether each placemark in the KML is expressed in 2 or 3 dimensions -->
	<xsl:variable name='dimensions' select="3" />

	<xsl:template match="*:Point">
		<xsl:text>POINT</xsl:text>
		<xsl:apply-templates select="*:coordinates"/>
	</xsl:template>

	<xsl:template match="*:LineString">
		<xsl:text>LINESTRING</xsl:text>
		<xsl:apply-templates select="*:coordinates"/>
	</xsl:template>

	<xsl:template match="*:Polygon">
		<xsl:text>POLYGON(</xsl:text>
		<xsl:apply-templates select="*:outerBoundaryIs"/>
		<xsl:apply-templates select="*:innerBoundaryIs"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<!-- Must handle each geometry member differently -->
	<xsl:template match="*:MultiGeometry|*:GeometryCollection">
		<xsl:text>GEOMETRYCOLLECTION(</xsl:text>
		<xsl:for-each select="*">			
			<!-- Handle accordingly each geometry member, e.g., LineString, Polygon, etc. -->	
			<xsl:apply-templates select="../current()" />

            <!-- Separate multiple members with commas -->			
			<xsl:if test="not(position()=last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="*:outerBoundaryIs">
		<xsl:apply-templates select="*:LinearRing"/>
	</xsl:template>

	<xsl:template match="*:innerBoundaryIs">
		<xsl:text>,</xsl:text>
		<xsl:apply-templates select="*:LinearRing"/>
	</xsl:template>

	<xsl:template match="*:LinearRing">
		<xsl:apply-templates select="*:coordinates"/>
	</xsl:template>

	<xsl:template match="*:coordinates">
		<xsl:call-template name="posList"/>
	</xsl:template>

	<!-- Allowing two possible expressions for lists of KML coordinates; the latter allows attributes in the list. -->
	<xsl:template name="posList">
		<xsl:call-template name="processPosList"/>
	</xsl:template>

	<xsl:template match="posList">
		<xsl:call-template name="processPosList"/>
	</xsl:template>
	
	<!-- Converting list of KML coordinates into WKT coordinates, by exchanging commas and space characters -->
	<xsl:template name="processPosList">
		<xsl:text>(</xsl:text>
			<xsl:for-each select="tokenize(replace(replace(.,'\s+$',''),'^\s+',''), '[,\s\n\r]+')">
				<xsl:variable name="t" select="concat('', if (($dimensions = 3) and ((position() mod $dimensions) = 0)) then '' else . )" />
				<xsl:value-of select="concat($t, if (position() = last()) then '' else if (($dimensions = 3) and ((position() mod $dimensions) = 0)) then ', ' else if ((position() mod $dimensions) = 0) then ', ' else ' ')" />
			</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>
