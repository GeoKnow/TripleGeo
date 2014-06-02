<?xml version="1.0" encoding="UTF-8"?>
<!-- ======================================================================= -->
<!-- Stylesheet for transformation of 2-dimensional OGC geometries           -->
<!-- from Geometry Markup Language (GML) to Well Known Text (WKT).           -->
<!-- Returns: A GeoSPARQL WKT for RDF representation of features.            -->
<!-- Spatial types currently handled: (MULTI)POINT, (MULTI)LINESTRING,       -->
<!-- (MULTI)POLYGON, CURVE, MULTISURFACE, MULTIGEOMETRY, GEOMETRYCOLLECTION. -->
<!-- Issues: Avoid SRS for members in GEOMETRYCOLLECTION items.              -->
<!-- Project: GeoKnow, http://geoknow.eu                                     -->
<!-- Institute for the Management of Information Systems, Athena R.C.        -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr              -->
<!-- Version: 0.8                                                            -->
<!-- Last update: 7/4/2014                                                  -->
<!-- ======================================================================= -->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	
	xmlns:gml="http://www.opengis.net/gml/3.2" >

	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<!-- Compose the base URI for georeference systems, according to EPSG catalogue --> 
	<xsl:variable name='epsg' select="concat('http://www.opengis.net/def/crs/EPSG/','0/')" />
	
	<!-- Use metadata with extreme corners of the bounding box for the dataset and construct a polygon equivalent to this rectangle. -->
	<xsl:template match="gml:boundedBy">
		<xsl:apply-templates />     		<!-- May involve either a gml:Box (older specification) or a gml:Envelope (latest OGC standard) -->
	</xsl:template>

	<xsl:template match="gml:Box">
		<xsl:param name="separator" select="' '" />
		<xsl:call-template name="gml:srsName"/>
		<xsl:variable name="coords" select="tokenize(replace(replace(gml:coordinates,'\s+$',''),'^\s+',''), '[,\s\n\r]+')" />
		<xsl:variable name="MINX"><xsl:value-of select="$coords[1]"/></xsl:variable>
		<xsl:variable name="MINY"><xsl:value-of select="$coords[2]"/></xsl:variable>
		<xsl:variable name="MAXX"><xsl:value-of select="$coords[3]"/></xsl:variable>
		<xsl:variable name="MAXY"><xsl:value-of select="$coords[4]"/></xsl:variable>
		<xsl:value-of select="concat('POLYGON((', $MINX, ' ', $MINY, ', ', $MAXX, ' ', $MINY, ', ', $MAXX, ' ', $MAXY, ', ', $MINX, ' ', $MAXY, ', ', $MINX, ' ', $MINY, '))')"/>
	</xsl:template>
	
	<xsl:template match="gml:Envelope">
		<xsl:param name="separator" select="' '"/>
		<xsl:call-template name="gml:srsName"/>
		<xsl:variable name="MINX"><xsl:value-of select="normalize-space(substring-before(gml:lowerCorner, $separator))"/></xsl:variable>
		<xsl:variable name="MINY"><xsl:value-of select="normalize-space(substring-after(gml:lowerCorner, $separator))"/></xsl:variable>
		<xsl:variable name="MAXX"><xsl:value-of select="normalize-space(substring-before(gml:upperCorner, $separator))"/></xsl:variable>
		<xsl:variable name="MAXY"><xsl:value-of select="normalize-space(substring-after(gml:upperCorner, $separator))"/></xsl:variable>
		<xsl:value-of select="concat('POLYGON((', $MINX, ' ', $MINY, ', ', $MAXX, ' ', $MINY, ', ', $MAXX, ' ', $MAXY, ', ', $MINX, ' ', $MAXY, ', ', $MINX, ' ', $MINY, '))')"/>
	</xsl:template>
		
	<xsl:template match="gml:Point">
		<xsl:call-template name="gml:srsName"/>
		<xsl:text>POINT</xsl:text>
		<xsl:call-template name="gml:posList"/>
	</xsl:template>

	<xsl:template match="gml:LineString">
		<xsl:call-template name="gml:srsName"/>
		<xsl:text>LINESTRING</xsl:text>
		<xsl:call-template name="gml:posList"/>
	</xsl:template>

	<xsl:template match="gml:Polygon">
		<xsl:call-template name="gml:srsName"/>
		<xsl:text>POLYGON(</xsl:text>
		<xsl:apply-templates select="gml:exterior|gml:outerBoundaryIs"/>
		<xsl:apply-templates select="gml:interior|gml:innerBoundaryIs"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="gml:MultiPoint">
		<xsl:call-template name="gml:srsName"/>
		<xsl:text>MULTIPOINT(</xsl:text>
		<xsl:for-each select="gml:pointMember//gml:Point|gml:pointMembers//gml:Point">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:apply-templates />
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="gml:MultiLineString">
		<xsl:call-template name="gml:srsName"/>
		<xsl:text>MULTILINESTRING(</xsl:text>
		<xsl:for-each select="gml:lineStringMember">
				<xsl:call-template name="gml:lineStringMember"/>
				<xsl:if test="(position()!=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="gml:Curve">
		<xsl:call-template name="gml:srsName"/>
		<xsl:for-each select="gml:segments//gml:LineStringSegment">
			<xsl:choose>
				<xsl:when test="not(position()=1)">
					<xsl:text>,</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>MULTILINESTRING(</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates />
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<!-- CAUTION: Call to template for "gml:srsName" must be placed in one of the two possible places: either (a) or (b) -->
	<xsl:template match="gml:MultiPolygon">
	    <xsl:call-template name="gml:srsName"/>                         <!-- (a) SRS is specified in the MultiPolygon element -->
		<xsl:for-each select="gml:polygonMember//gml:Polygon">
			<xsl:choose>
				<xsl:when test="not(position()=1)">
					<xsl:text>,</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="gml:srsName"/>             <!-- (b) SRS is specified for each member Polygon element -->
					<xsl:text>MULTIPOLYGON(</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>(</xsl:text>
			<xsl:apply-templates select="gml:exterior|gml:outerBoundaryIs"/>
			<xsl:apply-templates select="gml:interior|gml:innerBoundaryIs"/>
			<xsl:text>)</xsl:text>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="gml:MultiSurface">
		<xsl:for-each select="gml:surfaceMember//gml:Surface|gml:surfaceMember//gml:Polygon">
			<xsl:choose>
				<xsl:when test="not(position()=1)">
					<xsl:text>,</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="gml:srsName"/>    <!-- Workaround in order to print the SRS before the WKT geometry -->
					<xsl:text>MULTIPOLYGON(</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>(</xsl:text>
			<xsl:apply-templates />
			<xsl:text>)</xsl:text>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<!-- FIXME: In case that each geometryMember also defines an srsName, this is also emitted before the respective WKT geometry.  -->
	<!-- The final WKT will contain multiple srsNames, one per geometryMember; this is not conforming with GeoSPARQL specification. -->
	<!-- However, this case does arise for GML geometries generated from INSPIRE datasets with the HUMBOLDT Alignment Editor (HALE). -->
	<xsl:template match="gml:MultiGeometry|gml:GeometryCollection">
		<xsl:call-template name="gml:srsName"/>
		<xsl:text>GEOMETRYCOLLECTION(</xsl:text>
		<xsl:for-each select="gml:geometryMember">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:apply-templates select="*[not(local-name()='gml:srsName')]" />
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="gml:pointMember">
		<xsl:apply-templates select="gml:Point"/>
	</xsl:template>

	<xsl:template name="gml:lineStringMember">
		<xsl:call-template name="gml:posList"/>
	</xsl:template>

	<xsl:template match="gml:LineStringSegment">
		<xsl:apply-templates select="gml:posList"/>
	</xsl:template>
	
	<!-- FIXME: Workaround in order to avoid an extra pair of parentheses in multi-surfaces with patches. -->
	<xsl:template match="gml:polygonMember|gml:patches//gml:PolygonPatch">
		<!-- xsl:if test="not(position()=1)"><xsl:text>,</xsl:text></xsl:if -->
		<!-- xsl:text>(</xsl:text -->
		<xsl:apply-templates select="gml:exterior|gml:outerBoundaryIs"/>
		<xsl:apply-templates select="gml:interior|gml:innerBoundaryIs"/>
		<!-- xsl:text>)</xsl:text -->
	</xsl:template>

	<xsl:template match="gml:exterior|gml:outerBoundaryIs">
		<xsl:apply-templates select="gml:LinearRing"/>
	</xsl:template>

	<xsl:template match="gml:interior|gml:innerBoundaryIs">
		<xsl:text>,</xsl:text>
		<xsl:apply-templates select="gml:LinearRing"/>
	</xsl:template>

	<xsl:template match="gml:LinearRing">
		<xsl:call-template name="gml:posList"/>
	</xsl:template>

	<xsl:template match="gml:pos">
		<xsl:call-template name="gml:posList"/>
	</xsl:template>

	<xsl:template match="gml:coordinates">
		<xsl:call-template name="gml:posList"/>
	</xsl:template>

	<!-- Allowing two possible expressions for lists of GML coordinates; the latter allows attributes in the list. -->
	<xsl:template name="gml:posList">
		<xsl:call-template name="gml:processPosList"/>
	</xsl:template>

	<xsl:template match="gml:posList">
		<xsl:call-template name="gml:processPosList"/>
	</xsl:template>
	
	<!-- Converting list of GML coordinates into WKT coordinates, by exchanging commas and space characters -->
	<xsl:template name="gml:processPosList">
		<xsl:text>(</xsl:text>
			<xsl:for-each select="tokenize(replace(replace(.,'\s+$',''),'^\s+',''), '[,\s\n\r]+')">
				<xsl:variable name="t" select="." />
				<xsl:value-of select="concat($t, if (position() = last()) then '' else if ((position() mod 2) = 0) then ', ' else ' ')" />
			</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<!-- ASSUMPTION: Spatial reference system SRS must be declared according to the EPSG catalogue. -->
	<xsl:template name="gml:srsName">
		<xsl:variable name="srsName" select="." />
		<xsl:if test="string-length(@srsName)>0">
			<xsl:value-of select="concat('&lt;', $epsg, tokenize(@srsName, '[:#]')[last()],'&gt; ') "/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>