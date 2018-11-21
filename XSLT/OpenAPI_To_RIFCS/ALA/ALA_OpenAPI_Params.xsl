<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:import href="OpenAPI_To_RIFCS.xsl"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_baseURI" select="'ala.org.au'"/>
    <xsl:param name="global_acronym" select="'ALA'"/>
    <xsl:param name="global_group" select="'Atlas of Living Australia'"/>
    <xsl:param name="global_publisherName" select="'Atlas of Living Australia'"/>
    
</xsl:stylesheet>