<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    <!-- stylesheet to convert data.nt.gov.au xml (transformed from json with python script) to RIF-CS -->
    <xsl:import href="CKAN_json_to_rif-cs.xsl"/>

    <xsl:param name="global_originatingSource" select="'http://data.nt.gov.au'"/>
    <xsl:param name="global_baseURI" select="'http://data.nt.gov.au/'"/>
    <xsl:param name="global_group" select="'data.nt.gov.au'"/>
    <xsl:param name="global_contributor" select="'data.nt.gov.au'"/>
    <xsl:param name="global_publisherName" select="'data.nt.gov.au'"/>
    <xsl:param name="global_publisherPlace" select="'Australia'"/>
    <xsl:param name="global_includeDownloadLinks" select="true()"/>

    
</xsl:stylesheet>
