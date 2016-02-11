<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
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
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts custom">
    <xsl:import href="EATLAS_rif.xsl"/>
    <xsl:import href="AAD_rif.xsl"/>
    <xsl:import href="AIMS_rif.xsl"/>
    <xsl:import href="IMOS_rif.xsl"/>
    <xsl:import href="IMAS_rif.xsl"/>
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_group" select="'IMOS:Integrated Marine Observing System'"/>
    
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
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="IMOS_aggregating"/>
        </registryObjects>
        
    </xsl:template>
    
    
    <xsl:template match="*:MD_Metadata" mode="IMOS_aggregating">
        
        <xsl:variable name="originatingSource" select="custom:originatingSource(.)"/>
        
        <xsl:variable name="metadataPointOfTruth_sequence" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol/gco:CharacterString), 'metadata-url')]/gmd:URL" as="xs:string*"/>
        
        <xsl:message select="concat('$originatingSource: ', $originatingSource)"/>
        <xsl:for-each select="distinct-values($metadataPointOfTruth_sequence)">
            <xsl:message select="concat('$metadataPointOfTruth_sequence: ', .)"/>
        </xsl:for-each>
        
               
        <xsl:choose>
            <xsl:when test="
                custom:sequenceContains($metadataPointOfTruth_sequence, 'eatlas') or
                contains(lower-case($originatingSource), 'eatlas') or
                contains(lower-case($originatingSource), 'e-atlas')">
                <xsl:apply-templates select="." mode="EATLAS">
                    <xsl:with-param name="source" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="
                contains(lower-case($originatingSource), 'aims') or
                contains(lower-case($originatingSource), 'australian institute of marine science')">
                <xsl:apply-templates select="." mode="AIMS">
                    <xsl:with-param name="source" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="
                contains(lower-case($originatingSource), 'imas') or
                contains(lower-case($originatingSource), 'utas') or
                contains(lower-case($originatingSource), 'institute for marine and antarctic studies') or
                contains(lower-case($originatingSource), 'university of tasmania')">
                <xsl:apply-templates select="." mode="IMAS">
                    <xsl:with-param name="source" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
            <!--xsl:when test="
                contains(lower-case($originatingSource), 'csiro oceans')">
                <xsl:apply-templates select="." mode="CSIRO">
                    <xsl:with-param name="source" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when-->
            <!-- Uncomment the following when we have the AAD XSLT working
                from the same anzlic as is fed to AODN -->
            <!--xsl:when test="
                contains($metadataTruthURL, $global_AAD_baseURI) or
                custom:sequence_contains($contact_sequence, 'australian antarctic division') or
                custom:sequence_contains($contact_sequence, 'aad')">
                <xsl:apply-templates select="." mode="AAD">
                <xsl:with-param name="source" select="$global_group"/>
                </xsl:apply-templates>
                </xsl:when-->
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="IMOS">
                    <xsl:with-param name="source" select="$global_group"/>
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
</xsl:stylesheet>