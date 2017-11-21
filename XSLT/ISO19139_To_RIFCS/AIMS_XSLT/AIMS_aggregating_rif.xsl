<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts custom customGMD">
    <xsl:import href="AIMS_rif.xsl"/>
    <xsl:import href="IMOS_rif.xsl"/>
    <xsl:import href="EATLAS_rif.xsl"/>
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="CustomFunctionsGMD.xsl"/>
    
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_EATLAS_baseURI" select="'eatlas.org.au'"/>
    <xsl:param name="global_IMOS_baseURI" select="'imosmest.aodn.org.au'"/>
    <xsl:param name="global_IMOS_baseURI_123" select="'catalogue-123.aodn.org.au'"/>
    <xsl:param name="global_IMOS_baseURI_top" select="'catalogue-imos.aodn.org.au'"/>
    
    <xsl:param name="global_AAD_baseURI" select="'data.aad.gov.au'"/>
    <xsl:param name="global_AIMS_baseURI" select="'data.aims.gov.au'"/>
        
    <xsl:param name="global_group" select="'AIMS:Australian Institute of Marine Science'"/>

    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:template match="oai:responseDate"/>
    <xsl:template match="oai:request"/>
    <xsl:template match="oai:error"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:setSpec"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:setSpec"/>
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
       
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="AIMS_aggregating"/>
        </registryObjects>
        
    </xsl:template>
    
    
    <xsl:template match="*:MD_Metadata" mode="AIMS_aggregating">
        
        <xsl:variable name="originatingSourceOrganisation" select="customGMD:originatingSourceOrganisation(.)"/>
        <xsl:message select="concat('$originatingSourceOrganisation: ', $originatingSourceOrganisation)"/>
        
        <xsl:variable name="metadataPointOfTruth_sequence" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol/gco:CharacterString), 'metadata-url')]/gmd:URL" as="xs:string*"/>
        
        <xsl:message select="concat('$originatingSourceOrganisation: ', $originatingSourceOrganisation)"/>
        <xsl:for-each select="distinct-values($metadataPointOfTruth_sequence)">
            <xsl:message select="concat('$metadataPointOfTruth_sequence: ', .)"/>
        </xsl:for-each>
        
        
        <xsl:choose>
            <xsl:when test="
                custom:sequenceContains($metadataPointOfTruth_sequence, 'eatlas') or
                contains(lower-case($originatingSourceOrganisation), 'eatlas') or
                contains(lower-case($originatingSourceOrganisation), 'e-atlas')">
                <xsl:apply-templates select="." mode="EATLAS">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="
                custom:sequenceContains($metadataPointOfTruth_sequence, 'imos') or
                contains(lower-case($originatingSourceOrganisation), 'imos') or
                contains(lower-case($originatingSourceOrganisation), 'integrated marine observing system')">
                <xsl:apply-templates select="." mode="IMOS">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="
                custom:sequenceContains($metadataPointOfTruth_sequence, 'data.aims') or
                contains(lower-case($originatingSourceOrganisation), 'aims') or
                contains(lower-case($originatingSourceOrganisation), 'australian institute of marine science')">
                <xsl:apply-templates select="." mode="AIMS">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
   
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="AIMS">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
         
   
</xsl:stylesheet>
