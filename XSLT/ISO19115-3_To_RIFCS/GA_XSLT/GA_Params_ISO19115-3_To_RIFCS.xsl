<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0" 
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="mdb mcc">
    
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Geoscience Australia'"/>
    <xsl:param name="global_acronym" select="'GA'"/>
    <xsl:param name="global_baseURI" select="'ecat.ga.gov.au'"/>
    <xsl:param name="global_baseURI_PID" select="'pid.geoscience.gov.au'"/>
    <xsl:param name="global_path_PID" select="'/dataset/ga/'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/search?uuid='"/>
    <xsl:param name="global_group" select="'Geoscience Australia'"/>
    <xsl:param name="global_publisherName" select="'Geoscience Australia'"/>
    <xsl:param name="global_publisherPlace" select="'Canberra'"/>
     
    <xsl:template match="/">
        <!-- include all records except those with scopecode 'Document'-->
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:for-each select="//mdb:MD_Metadata[count(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode[contains(lower-case(@codeListValue), 'document') or contains(lower-case(@codeListValue), 'nongeographicdataset')]) = 0]">
                <xsl:apply-templates select="." mode="registryObjects"/>
            </xsl:for-each>
        </registryObjects>
    </xsl:template>
    
</xsl:stylesheet>
