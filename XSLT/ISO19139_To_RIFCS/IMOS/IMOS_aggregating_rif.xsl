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
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts custom">
    <xsl:import href="EATLAS_rif.xsl"/>
    <xsl:import href="AAD_rif.xsl"/>
    <xsl:import href="AIMS_rif.xsl"/>
    <xsl:import href="IMOS_rif.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_EATLAS_baseURI" select="'eatlas.org.au'"/>
    <xsl:param name="global_IMOS_baseURI" select="'imosmest.aodn.org.au'"/>
    <xsl:param name="global_IMOS_baseURI_123" select="'catalogue-123.aodn.org.au'"/>
    <xsl:param name="global_AAD_baseURI" select="'data.aad.gov.au'"/>
    <xsl:param name="global_AIMS_baseURI" select="'data.aims.gov.au'"/>
    
    <xsl:param name="global_group" select="'IMOS'"/>

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
        <xsl:message select="concat('aodn_iso19139mcp_rif.xsl: match slash', '')"/>
       
        <xsl:variable name="metadataTruthURL" select="//*:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL"/>
        <xsl:message select="concat('metadataTruthURL: ', $metadataTruthURL)"/>
       
        <xsl:variable name="fileIdentifier" select="//*:MD_Metadata/gmd:fileIdentifier"/>
        <xsl:message select="concat('fileIdentifier: ', $fileIdentifier)"/>
        
        <xsl:variable name="contact_sequence" as="node()*" select="//*:MD_Metadata/gmd:contact"/>
        
        <xsl:for-each select="distinct-values($contact_sequence)">
            <xsl:message select="concat('contact: ', .)"/>
        </xsl:for-each>
        
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
        
             <xsl:choose>
                 <xsl:when test="
                     contains($metadataTruthURL, $global_EATLAS_baseURI)">
                     <xsl:apply-templates select="//*:MD_Metadata" mode="EATLAS">
                         <xsl:with-param name="source" select="$global_group"/>
                     </xsl:apply-templates>
                 </xsl:when>
                 <xsl:when test="
                     contains($metadataTruthURL, $global_AIMS_baseURI)">
                     <xsl:apply-templates select="//*:MD_Metadata" mode="AIMS">
                         <xsl:with-param name="source" select="$global_group"/>
                     </xsl:apply-templates>
                 </xsl:when>
                 <!-- Uncomment the following when we have the AAD XSLT working
                     from the same anzlic as is fed to AODN -->
                 <!--xsl:when test="
                     contains($metadataTruthURL, $global_AAD_baseURI) or
                     custom:sequence_contains($contact_sequence, 'australian antarctic division') or
                     custom:sequence_contains($contact_sequence, 'aad')">
                     <xsl:apply-templates select="//*:MD_Metadata" mode="AAD">
                     <xsl:with-param name="source" select="$global_group"/>
                     </xsl:apply-templates>
                 </xsl:when-->
                 <xsl:otherwise>
                     <xsl:apply-templates select="//*:MD_Metadata" mode="IMOS">
                         <xsl:with-param name="source" select="$global_group"/>
                     </xsl:apply-templates>
                 </xsl:otherwise>
             </xsl:choose>
        
        </registryObjects>
        
    </xsl:template>
    
   
</xsl:stylesheet>