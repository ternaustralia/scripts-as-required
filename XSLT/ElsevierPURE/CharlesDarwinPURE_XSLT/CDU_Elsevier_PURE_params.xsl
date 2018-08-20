<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:include href="Elsevier_PURE_API511_rifcs.xsl"/>
        
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Charles Darwin University'"/>
    <xsl:param name="global_baseURI" select="'cdu-staging.pure.elsevier.com'"/>
    <xsl:param name="global_acronym" select="'CDU_PURE'"/>
    <xsl:param name="global_group" select="'Charles Darwin University (API 511)'"/>
    <xsl:param name="global_publisherName" select="'Charles Darwin University'"/>
    
</xsl:stylesheet>
