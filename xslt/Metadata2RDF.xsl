<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================================= -->
<!-- Stylesheet for transforming INSPIRE-compliant metadata from XML into RDF.     -->
<!-- Returns: an RDF/XML file with geometries in GeoSPARQL or Virtuoso WKT.        -->
<!-- Project: GeoKnow, http://geoknow.eu                                           -->
<!-- Institute for the Management of Information Systems, Athena R.C.              -->
<!-- Author: Nikos Georgomanolis, mailto:ngeorgomanolis@imis.athena-innovation.gr  -->
<!-- Revised by: Kostas Patroumpas, mailto:kpatro@dblab.ece.ntua.gr                -->
<!-- Version: 0.6                                                                  -->
<!-- Last update: 2/6/2014                                                        -->
<!-- ============================================================================= -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/TR/2008/REC-xml-20081126#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:locn="http://www.w3.org/ns/locn#"	
	xmlns:prov="http://www.w3.org/ns/prov#"
	xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
	xmlns:rdfs="http://www.w3.org/1999/01/rdf-schema#"
	xmlns:schema="http://schema.org"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
	xmlns:gml="http://www.opengis.net/gml/"
	xmlns:gco="http://www.isotc211.org/2005/gco"  >
 
	<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
	
	<xsl:template match='*'>	

	<rdf:RDF>
		
		<xsl:for-each select='//gmd:MD_Metadata' >
            <xsl:variable name='pass' select='gmd:identificationInfo//gmd:geographicElement//gmd:westBoundLongitude' />
            <xsl:if test=" $pass &gt; -179 " >
                 
				<!--Metadata identifier -->		
				<xsl:variable name='id' select='gmd:fileIdentifier' />
				<xsl:variable name='resourceURI' select="gmd:distributionInfo//gmd:linkage/gmd:URL" />
				<!--<xsl:variable name='resourceURI' select="concat('http://geodata.gov.gr/datasets/attachments/',$id)" /> -->
				<xsl:variable name='metadataURI' select="concat('urn:uuid:',$id)" />
				
				<!--common language-->
				<xsl:variable name='language' select='(gmd:identificationInfo//gmd:language)[1]' />
				<!-- <xsl:variable name='language' select="'el'"/>  -->
						
				<!--Metadata on Metadata -->
				<rdf:Description rdf:about='{$metadataURI}'>
					<foaf:primaryTopic rdf:resource='{$resourceURI}' />
					<!--Metadata Language -->
					<dct:language rdf:datatype="http://purl.org/dc/terms/ISO639-2"><xsl:value-of select='gmd:language' /></dct:language>
			
					<!--Metadata Date -->	
					<dct:modified rdf:datatype='http://www.w3.org/2001/XMLSchema#date'><xsl:value-of select='gmd:dateStamp'/></dct:modified>
					
					<xsl:variable name='mail' select='gmd:contact//gmd:electronicMailAddress' />
					<!--Metadata Point of Contact -->
					<dct:creator>
						<foaf:Organisation>
							<foaf:name xml:lang='{$language}'><xsl:value-of select='gmd:contact//gmd:organisationName' /></foaf:name>
							<foaf:mbox rdf:resource="{concat('mailto:',$mail)}" />
						</foaf:Organisation>
					</dct:creator>			
					
				</rdf:Description>				
			

				<!--Resource Metadata-->
				<rdf:Description rdf:about='{$resourceURI}'>

					<foaf:primaryTopicOf rdf:resource='{$metadataURI}' />
					
					<!--Resource Language -->	
					<dct:language rdf:datatype="http://purl.org/dc/terms/ISO639-2"><xsl:value-of select='(gmd:identificationInfo//gmd:language)[1]' /></dct:language>

					<!--Resource Title -->
					<dct:title xml:lang='{$language}'><xsl:value-of select='gmd:identificationInfo//gmd:title/gco:CharacterString' /></dct:title>

					<!--Resource Abstract -->			
					<dct:description xml:lang='{$language}'><xsl:value-of select='//gmd:abstract' /></dct:description>
					
					<!--Resource Type -->
					<rdf:type rdf:resource='http://www.w3.org/ns/dcat#Dataset' />

					<!--Resource Locator-->
					<dcat:landingPage rdf:resource='{gmd:distributionInfo//gmd:linkage/gmd:URL}' />

					<!--Unique Resource Identifier -->
					<dct:identifier rdf:datatype='http://www.w3.org/2001/XMLSchema#string'><xsl:value-of select='gmd:identificationInfo//gmd:codeSpace' /></dct:identifier>
					
					<!--Topic Category -->
					<dct:subject><xsl:value-of select='//gmd:MD_TopicCategoryCode' /></dct:subject>
					
					<!--Free Keywords-->
					<xsl:for-each select='gmd:identificationInfo//gmd:keyword'>
						<dcat:keyword xml:lang='{$language}'><xsl:value-of select='.'/></dcat:keyword>
					</xsl:for-each>	
					
					<!--Check for controlled vocabulary like Thesaurus, GEMET -->		
					<xsl:if test='//gmd:thesaurusName'>
					<dcat:theme>
						<skos:Concept>
							<skos:inScheme>
								<skos:ConceptScheme>
									<rdfs:label><xsl:value-of select='//gmd:thesaurusName//gmd:title' /></rdfs:label>					
									<dct:issued rdf:datatype='http://www.w3.org/2001/XMLSchema#date'>
										<xsl:value-of select='//gmd:thesaurusName//gco:Date' />
									</dct:issued>
								</skos:ConceptScheme>
							</skos:inScheme>
						</skos:Concept>
					</dcat:theme>
					</xsl:if>

					<!--Geographic Bounding Box,Virtuoso and GeoSparql Specs -->
					<xsl:variable name='MAXX' select='gmd:identificationInfo//gmd:geographicElement//gmd:eastBoundLongitude' />
					<xsl:variable name='MINX' select='gmd:identificationInfo//gmd:geographicElement//gmd:westBoundLongitude' />
					<xsl:variable name='MAXY' select='gmd:identificationInfo//gmd:geographicElement//gmd:northBoundLatitude' />
					<xsl:variable name='MINY' select='gmd:identificationInfo//gmd:geographicElement//gmd:southBoundLatitude' />
					
					<!--BBOX Virtuoso Specs -->
					<!--Uncomment for Virtuoso Specs  -->
					<!--
					<dct:spatial>
						<dct:Location>
							<locn:geometry rdf:datatype='http://www.openlinksw.com/schemas/virtrdf#Geometry' >
								<xsl:value-of select="concat('BOX2D(',$MINX,' ',$MINY,',',$MAXX,' ',$MAXY,')')"  />
							</locn:geometry>
						</dct:Location>
					</dct:spatial>
					-->

					<!--BBOX GeoSparql Specs -->
					<dct:spatial>
						<dct:Location>
							<locn:geometry rdf:datatype='http://www.opengis.net/ont/geosparql#wktLiteral'>
					<xsl:value-of select="concat('POLYGON ((', $MINX, ' ', $MINY, ',', $MAXX, ' ', $MINY, ',', $MAXX, ' ', $MAXY, ',', $MINX, ' ', $MAXY, ',', $MINX, ' ', $MINY, '))')"/>
							</locn:geometry>
						</dct:Location>
					</dct:spatial>


					<!--Create Date elements -->
					<xsl:for-each select='gmd:identificationInfo//gmd:citation//gmd:date/gmd:CI_Date' >
						<xsl:if test='gmd:dateType/gmd:CI_DateTypeCode[@codeListValue = "publication"]' >
							<!--Date of publication -->
							<dct:issued rdf:datatype='http://www.w3.org/2001/XMLSchema#date'>
								<xsl:value-of select='gmd:date/gco:DateTime' />
							</dct:issued>
						</xsl:if>
								
						<xsl:if test='gmd:dateType/gmd:CI_DateTypeCode[@codeListValue = "revision"]' >
							<!--Date of last revision -->
							<dct:modified rdf:datatype='http://www.w3.org/2001/XMLSchema#date'>
								<xsl:value-of select='gmd:date/gco:DateTime' />
							</dct:modified>
						</xsl:if>

						<xsl:if test='gmd:dateType/gmd:CI_DateTypeCode[@codeListValue = "creation"]' >
							<!--Date of creation -->
							<dct:created rdf:datatype='http://www.w3.org/2001/XMLSchema#date'>
								<xsl:value-of select='gmd:date/gco:DateTime' />
							</dct:created>
									</xsl:if>
					</xsl:for-each>
					
					<!--Lineage -->
					<dct:provenance>
						<dct:ProvenanceStatement>
							<rdfs:label xml:lang='{$language}'><xsl:value-of select='//gmd:LI_Lineage/gmd:statement/gco:CharacterString' /></rdfs:label>
						</dct:ProvenanceStatement>
					</dct:provenance>

					<!--Conditions for access and use -->
					<dcat:distribution>
						<dcat:Distribution>
							<dct:rights>
								<dct:RightsStatements>
									<rdfs:label><xsl:value-of select='//gmd:useLimitation/gco:CharacterString' /></rdfs:label>
								</dct:RightsStatements>
							</dct:rights>
							<!--Limitations on public access -->
							<dct:accessRights>
								<dct:RightsStatement>
									<rdfs:label><xsl:value-of select='//gmd:otherConstraints/gco:CharacterString'/></rdfs:label>
								</dct:RightsStatement>
							</dct:accessRights>
						 </dcat:Distribution>
								</dcat:distribution>

					<!-- Responsible Organization -->
					<!-- role owner-->
					<xsl:variable name='mail2' select='gmd:identificationInfo//gmd:pointOfContact//gmd:electronicMailAddress' />
					<dct:rightsHolder>
						<foaf:Organisation>
							<foaf:name xml:lang='{$language}'><xsl:value-of select='(//gmd:organisationName/gco:CharacterString)[1]'/></foaf:name>	
							<foaf:mbox rdf:resource="{concat('mailto:',$mail2)}" />
						</foaf:Organisation>
					</dct:rightsHolder>

					<!-- Resource provider -->
					<prov:qualifiedAttribution>
						<prov:Attribution>
							<prov:agent>
								<vcard:Kind>
									<vcard:organization-name xml:lang='{$language}'><xsl:value-of select='(//gmd:organisationName/gco:CharacterString)[1]'/></vcard:organization-name>
									<vcard:hasEmail rdf:resource="{concat('mailto:',$mail2)}"/>
								</vcard:Kind>
							</prov:agent>
							<dct:type rdf:resource='http://inspire.ec.europa.eu/codelist/ResponsiblePartyRole/resourceProvider'/>
						</prov:Attribution>
					</prov:qualifiedAttribution>

					<!--Role- point of contact -->
					<dcat:contactPoint>
						<vcard:Kind>
							<vcard:organization-name xml:lang='{$language}'><xsl:value-of select='(//gmd:organisationName/gco:CharacterString)[1]' /></vcard:organization-name>
							<vcard:hasEmail rdf:resource="{concat('mailto:',$mail2)}"/>
						</vcard:Kind>
					</dcat:contactPoint>
					<prov:qualifiedAttribution>
						<prov:Attribution>
							<prov:agent>
								<vcard:Kind>
									<vcard:organization-name xml:lang='{$language}'><xsl:value-of select='(//gmd:organisationName/gco:CharacterString)[1]' /></vcard:organization-name>
									<vcard:hasEmail rdf:resource="{concat('mailto:',$mail2)}"/>
								</vcard:Kind>
							</prov:agent>
							<dct:type rdf:resource='http://inspire.ec.europa.eu/codelist/ResponsiblePartyRole/pointOfContact'/>
						</prov:Attribution>
					</prov:qualifiedAttribution>

					<!--Conformity -->
					<dct:conformsTo>
						<dct:Standard>
							<dct:title xml:lang='en'><xsl:value-of select='//gmd:report//gmd:title/gco:CharacterString' /></dct:title>
							<dct:issued rdf:datatype='http://www.w3.org/2001/XMLSchema#date'><xsl:value-of select='//gmd:report//gco:Date' /></dct:issued>
						</dct:Standard>
					</dct:conformsTo>

				</rdf:Description>
			</xsl:if>
		</xsl:for-each>		
	
	</rdf:RDF>
</xsl:template>

</xsl:stylesheet>
