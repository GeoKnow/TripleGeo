<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!-- Stylesheet for transforming name elements compliant with INSPIRE      -->
<!-- "Data Themes I : GEOGRAPHICAL NAMES" from GML into RDF.               -->
<!-- Requires: It must be called by another XSL.                           -->
<!-- Project: GeoKnow, http://geoknow.eu                                   -->
<!-- Institute for the Management of Information Systems, Athena R.C.      -->
<!-- Author: Nikos Georgomanolis, ngeorgomanolis@imis.athena-innovation.gr -->
<!-- Revised by: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr        -->
<!-- Version: 0.5                                                          -->
<!-- Last update: 24/3/2014                                                -->
<!-- ===================================================================== -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:gn="urn:x-inspire:specification:gmlas:GeographicalNames:3.0"	
	xmlns:GN="http://inspire.jrc.ec.europa.eu/schemas/gn/3.0/" >

	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name='names'>
		<xsl:param name='baseURI' />
		<xsl:param name='id' />
		<xsl:param name='theme' />
	
		<xsl:element name='GN:GeographicalName'>
            <rdf:Description>
                <xsl:attribute name='rdf:about'>	
                    <xsl:value-of select="concat($baseURI, $theme, '/GeographicalName/', $id)"/> 
				</xsl:attribute>	
				
				<!-- Define language as a variable, in order to provide language-tagged literals -->
				<xsl:variable name='lang' select='gn:GeographicalName/gn:language' />
				
				<!-- Consider each attribute defined for this Geographical Name -->			
                <xsl:element name='GN:language'>
                    <xsl:value-of select='$lang' />
                </xsl:element>
				
                <xsl:element name='GN:nativeness'>
                    <xsl:value-of select='gn:GeographicalName/gn:nativeness' />
                </xsl:element>
                <xsl:element name='GN:nameStatus'>
                    <xsl:value-of select='gn:GeographicalName/gn:nameStatus' />
                </xsl:element>
				
				<xsl:element name='GN:sourceOfName'>
                    <xsl:value-of select='gn:GeographicalName/gn:sourceOfName' />
                </xsl:element>
				
                <xsl:element name='GN:pronunciation'>
                     <xsl:value-of select='gn:GeographicalName/gn:pronunciation' />
                </xsl:element>
	               
				<xsl:element name='GN:grammaticalGender'>
                     <xsl:value-of select='gn:GeographicalName/gn:grammaticalGender' />
                </xsl:element>
				
				<xsl:element name='GN:grammaticalNumber'>
                     <xsl:value-of select='gn:GeographicalName/gn:grammaticalNumber' />
                </xsl:element>
				
				<xsl:element name='GN:spelling'>
                    <rdf:Description >
                        <xsl:attribute name='rdf:about'>
                            <xsl:value-of select="concat($baseURI, $theme, '/spelling/', $id)"/>
                        </xsl:attribute>
                        <xsl:element name='GN:SpellingOfName'>
                            <rdf:Description>
                                <xsl:attribute name='rdf:about'>
									<xsl:value-of select="concat($baseURI, $theme, '/SpellingOfName/', $id)"/>
                                </xsl:attribute>
                                <xsl:element name='GN:text'>
								    <!-- Handle language-tagged elements for names -->
									<xsl:attribute name='xml:lang'>
										<xsl:value-of select="substring($lang,1,2)"/>
										<!--
										<xsl:choose>
											<xsl:when test="*[$lang = 'ell']"> <xsl:value-of select="string('el')" /> </xsl:when>
											<xsl:when test="*[$lang = 'ita']"> <xsl:value-of select="string('it')" /> </xsl:when>
											<xsl:when test="*[$lang = 'fra']"> <xsl:value-of select="string('fr')" /> </xsl:when>
											<xsl:otherwise> <xsl:value-of select="string('en')" /> </xsl:otherwise>    
										</xsl:choose>	
										-->										
									</xsl:attribute>
 					                <xsl:value-of select='gn:GeographicalName/gn:spelling/gn:SpellingOfName/gn:text' />
                                </xsl:element>
                                <xsl:element name='GN:script'>
                          			<xsl:value-of select='gn:GeographicalName/gn:spelling/gn:SpellingOfName/gn:script' />
                                </xsl:element>
                            </rdf:Description>
                        </xsl:element>
                    </rdf:Description>
                </xsl:element>
            </rdf:Description>
        </xsl:element>
	</xsl:template>

</xsl:stylesheet>

