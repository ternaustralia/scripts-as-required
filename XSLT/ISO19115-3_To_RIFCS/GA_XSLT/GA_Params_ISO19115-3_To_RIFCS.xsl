<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:param name="global_PID_Codespace" select="'ecatid'"/>
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
   
    
</xsl:stylesheet>
