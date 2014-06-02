<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming datasets compliant with INSPIRE           -->
<!-- "Data Themes I : ADDRESSES" from GML into RDF.                        -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL WKT.            -->
<!-- Requires: GML2WKT.xsl, GeographicalNames.xsl                          -->
<!-- FIXME: Nillable properties NOT handled : alternativeIdentifier,       -->
<!--     status, parcel, parentAddress, building, component,               -->
<!--     withinScopeOf, situatedWithin, AddressAreaName, ThoroughfareName. -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr            -->
<!-- Version: 0.3                                                          -->
<!-- Last update: 31/3/2014                                                -->
<!-- ===================================================================== -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd/"
	xmlns:geo="http://www.opengis.net/ont/geosparql#"
	xmlns:base="urn:x-inspire:specification:gmlas:BaseTypes:3.2"
	xmlns:BASE="http://inspire.jrc.ec.europa.eu/schemas/base/3.2/"
	xmlns:gn="urn:x-inspire:specification:gmlas:GeographicalNames:3.0"
	xmlns:GN="http://inspire.jrc.ec.europa.eu/schemas/gn/3.0/"
	xmlns:ad="urn:x-inspire:specification:gmlas:Addresses:3.0"
    xmlns:AD="http://inspire.jrc.ec.europa.eu/schemas/ad/3.0/"	 >
	
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<!-- Template to handle intervals (common to all address components) -->
	<xsl:template name='ad:valid'>
			<!-- Create 'beginLifespanVersion' element (may be NULL) -->
			<xsl:element name='AD:beginLifespanVersion'>
				<xsl:value-of select='ad:beginLifespanVersion' />
			</xsl:element>
			
			<!-- Create 'endLifespanVersion' element (may be NULL) -->
			<xsl:element name='AD:endLifespanVersion'>
				<xsl:value-of select='ad:endLifespanVersion' />
			</xsl:element>	
			
			<!-- Create 'validFrom' element (may be NULL) -->
            <xsl:element name='AD:validFrom'>
                <xsl:value-of select='ad:validFrom' />
            </xsl:element>
		
		    <!-- Create 'validTo' element (may be NULL) -->
			<xsl:element name='AD:validTo'>
				<xsl:value-of select='ad:validTo' />
			</xsl:element>
	</xsl:template>
	
	<!-- Template to handle each AddressAreaName in the given GML -->	
	<xsl:template match='ad:AddressAreaName'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='@gml:id' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />

			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $topic, '#', $id)" />
            </xsl:attribute>
			
			<xsl:call-template name='ad:valid' />
			
			<!-- Process geographical names (if exist) -->
			<xsl:if test="ad:name">
				<xsl:element name='AD:name'>
					<rdf:Description >
						<xsl:attribute name='rdf:about'>
							<xsl:value-of select="concat($baseURI, $t, '/name/', $id)"/>
						</xsl:attribute>

						<!-- Call generic template for all attributes in Geographical Names -->
						<xsl:for-each select="ad:name">
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
			
			<!-- Create InspireID element -->
			<xsl:element name='AD:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='ad:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='ad:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>
			
		</rdf:Description>
	</xsl:template>
		
	<!-- Template to handle each PostalDescriptor in the given GML -->	
	<xsl:template match='ad:PostalDescriptor'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='@gml:id' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />

			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $topic, '#', $id)" />
            </xsl:attribute>
			
			<xsl:call-template name='ad:valid' />
			
			<!-- Create 'postCode' element -->
			<xsl:element name='AD:postCode'>
				<xsl:value-of select='ad:postCode' />
			</xsl:element>
			
			<!-- Create InspireID element -->
			<xsl:element name='AD:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='ad:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='ad:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>
			
		</rdf:Description>
	</xsl:template>
	
	<!-- Template to handle each ThoroughfareName in the given GML -->	
	<xsl:template match='ad:ThoroughfareName'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='@gml:id' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />
	
			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $topic, '#', $id)" />
            </xsl:attribute>
			
			<xsl:call-template name='ad:valid' />
			
			<!-- Process geographical names for thoroughfares (if exist) -->
			<xsl:if test="ad:name">
				<xsl:element name='AD:name'>
					<rdf:Description >
						<xsl:attribute name='rdf:about'>
							<xsl:value-of select="concat($baseURI, $t, '/name/', $id)"/>
						</xsl:attribute>

						<!-- Call generic template for all attributes in Geographical Names -->
						<xsl:for-each select="ad:name">
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
			
			<!-- Create InspireID element -->
			<xsl:element name='AD:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='ad:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='ad:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>
			
		</rdf:Description>
	</xsl:template>
		
	<!-- Template to handle each Address in the given GML -->	
	<xsl:template match='ad:Address'>
		<rdf:Description>
			<!-- Local variables defined for this entity -->
			<xsl:variable name='id' select='ad:inspireId//base:localId' />
			<xsl:variable name='theme' select="normalize-space(substring-after(name(.),':'))" />
			<xsl:variable name='t' select="concat($theme,'/',$topic)" />	

			<xsl:attribute name='rdf:about'>
             	<xsl:value-of select="concat($baseURI, $t, '/', $id)" />
            </xsl:attribute>
			
			<xsl:call-template name='ad:valid' />
			
			<!-- Create 'locator' element -->
			<xsl:element name='AD:locator'>
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/locator/', $id)" />
					</xsl:attribute>
					<xsl:element name='AD:AddressLocator'>
						<rdf:Description>
							<xsl:attribute name='rdf:about'>
								<xsl:value-of select="concat($baseURI, $t, '/AddressLocator/', $id)" />
							</xsl:attribute>
							<xsl:element name='AD:designator'>
								<rdf:Description>
									<xsl:attribute name='rdf:about'>
										<xsl:value-of select="concat($baseURI, $t, '/designator/', $id)" />
									</xsl:attribute>
									<xsl:element name='AD:LocatorDesignator'>
										<rdf:Description>
											<xsl:attribute name='rdf:about'>
												<xsl:value-of select="concat($baseURI, $t, '/LocatorDesignator/', $id)" />
											</xsl:attribute>
											<xsl:element name='AD:designator'>
												<xsl:value-of select='ad:locator//ad:AddressLocator//ad:designator//ad:designator' />
											</xsl:element>
											<xsl:element name='AD:type'>
												<xsl:value-of select='ad:locator//ad:AddressLocator//ad:designator//ad:type' />
											</xsl:element>
										</rdf:Description>
									</xsl:element>
								</rdf:Description>
							</xsl:element>
							<xsl:element name='AD:level'>
								<xsl:value-of select='ad:locator//ad:AddressLocator//ad:level' />
							</xsl:element>
						</rdf:Description>
					</xsl:element>
				</rdf:Description>
			</xsl:element>
			
			<!-- Create 'position' element of this address location -->
			<xsl:element name='AD:position'>
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/position/', $id)" />
					</xsl:attribute>
					<xsl:element name='AD:GeographicPosition'>
						<rdf:Description>
							<xsl:attribute name='rdf:about'>
								<xsl:value-of select="concat($baseURI, $t, '/GeographicPosition/', $id)" />
							</xsl:attribute>
							
							<!-- Create geometry RDF - GeoSPARQL Specs -->
							<xsl:element name='geo:hasGeometry' >
								<rdf:Description>
									<xsl:attribute name='rdf:about'>
										<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
									</xsl:attribute>
								</rdf:Description>
							</xsl:element>
							
							<!-- Create geometry RDF - INSPIRE specs -->
							<xsl:element name='AD:geometry'>
								<rdf:Description>
									<xsl:attribute name='rdf:about'>
										<xsl:value-of select="concat($baseURI, $t, '/geometry/', $id)" />
									</xsl:attribute>
									<!-- Geometry as GeoSPARQL WKT literal -->
									<xsl:element name='geo:asWKT'>
										<xsl:attribute name='rdf:datatype'>
											<xsl:value-of select='$typeWKT' />
										</xsl:attribute>
										<xsl:value-of><xsl:apply-templates select='ad:position//ad:geometry' /></xsl:value-of>
									</xsl:element>
								</rdf:Description>
							</xsl:element>
							
							<xsl:element name='AD:specification'>
								<xsl:value-of select='ad:position//ad:specification' />
							</xsl:element>
							<xsl:element name='AD:method'>
								<xsl:value-of select='ad:position//ad:method' />
							</xsl:element>
							<xsl:element name='AD:default'>
								<xsl:value-of select='ad:position//ad:default' />
							</xsl:element>
							
						</rdf:Description>
					</xsl:element>
				</rdf:Description>
			</xsl:element>

			<!-- Create 'component' element for resources (multiple components may exist, e.g., thoroughfare, area, postcode) -->
			<xsl:for-each select="ad:component">
				<xsl:element name='AD:component'>
				<rdf:Description>
				<xsl:attribute name='rdf:about'>
					<xsl:value-of select="concat($baseURI, $topic, @xlink:href)" />
					</xsl:attribute>
					</rdf:Description>
				</xsl:element>
				
			</xsl:for-each>
			
			<!-- Create InspireID element -->
			<xsl:element name='AD:inspireId' >
				<rdf:Description>
					<xsl:attribute name='rdf:about'>
						<xsl:value-of select="concat($baseURI, $t, '/inspireId/', $id)" />
					</xsl:attribute> 
					<xsl:element name='BASE:localId'>
						<xsl:value-of select='ad:inspireId//base:localId' />
					</xsl:element>
					<xsl:element name='BASE:namespace'>
						<xsl:value-of select='ad:inspireId//base:namespace' />
					</xsl:element>
				</rdf:Description>
			</xsl:element>

		</rdf:Description>
	</xsl:template>

</xsl:stylesheet>
