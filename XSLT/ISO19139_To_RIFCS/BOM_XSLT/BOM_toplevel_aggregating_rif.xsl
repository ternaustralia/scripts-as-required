<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xsi gmd customGMD xs xsl">
    <xsl:import href="ISO19139_RIFCS.xsl"/>
   
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_acronym" select="'BOM'"/>
    <xsl:param name="global_originatingSourceOrganisation" select="'Australian Bureau of Meteorology'"/> <!-- Only used as originating source if organisation name cannot be determined from Point Of Contact -->
    <xsl:param name="global_group" select="'Australian Bureau of Meteorology'"/> 
    <xsl:param name="global_baseURI" select="'www.bom.gov.au'"/>
    <xsl:param name="global_path" select="'/metadata/19115/'"/>
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
        
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//gmd:MD_Metadata" mode="ISO19139_TO_RIFCS"/>
        </registryObjects>
        
    </xsl:template>
    
 </xsl:stylesheet>
