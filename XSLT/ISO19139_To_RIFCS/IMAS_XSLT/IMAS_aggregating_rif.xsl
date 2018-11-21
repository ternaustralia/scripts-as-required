<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:dwc="http://rs.tdwg.org/dwc/terms/" 
    xmlns:gml="http://www.opengis.net/gml" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:geonet="http://www.fao.org/geonetwork" 
    gco:isoType="gmd:MD_Metadata" 
    xsi:schemaLocation="http://schemas.aodn.org.au/mcp-2.0 http://schemas.aodn.org.au/mcp-2.0/schema.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://rs.tdwg.org/dwc/terms/ http://schemas.aodn.org.au/mcp-2.0/mcpDwcTerms.xsd"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customIMAS="http://customIMAS.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xlink geonet gmx oai xsi gmd srv gml gco mcp dwc customIMAS custom customGMD">
    
    <xsl:import href="IMAS_rif.xsl"/>
    <xsl:import href="IMOS_rif.xsl"/>
    <xsl:import href="AIMS_rif.xsl"/>
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="CustomFunctionsGMD.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_group" select="'UTAS:University of Tasmania, Australia'"/>
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    

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
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="IMAS_aggregating"/>
        </registryObjects>
        
    </xsl:template>
    
    
    <xsl:template match="*:MD_Metadata" mode="IMAS_aggregating">
        
        <xsl:variable name="originatingSourceOrganisation" select="customGMD:originatingSourceOrganisation(.)"/>
        <xsl:if test="$global_debug">
            <xsl:message select="concat('$originatingSourceOrganisation: ', $originatingSourceOrganisation)"/>
        </xsl:if>
        
        <xsl:variable name="metadataPointOfTruth_sequence" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL" as="xs:string*"/>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('count $metadataPointOfTruth_sequence: ', count($metadataPointOfTruth_sequence))"/>
            
            <xsl:for-each select="distinct-values($metadataPointOfTruth_sequence)">
                <xsl:message select="concat('$metadataPointOfTruth_sequence: ', .)"/>
            </xsl:for-each>
        </xsl:if>
        
        
        
        <xsl:choose>
            <!-- Note that we may have metadata point of truth containing 'eatlas' while originating source is AIMS.
                 In such a case, we want the eatlas crosswalk to be called, hence placing the test for 'eatlas'
                 in metadata point of truth above the test for 'aims' in originating source -->
            <xsl:when test="
                custom:sequenceContains($metadataPointOfTruth_sequence, 'eatlas') or
                contains(lower-case($originatingSourceOrganisation), 'eatlas') or
                contains(lower-case($originatingSourceOrganisation), 'e-atlas')">
                <xsl:apply-templates select="." mode="EATLAS">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
             </xsl:when>
             <xsl:when test="
                 custom:sequenceContains($metadataPointOfTruth_sequence, 'imas') or
                 custom:sequenceContains($metadataPointOfTruth_sequence, 'utas') or
                 contains(lower-case($originatingSourceOrganisation), 'imas') or
                 contains(lower-case($originatingSourceOrganisation), 'utas') or
                 contains(lower-case($originatingSourceOrganisation), 'institute for marine and antarctic studies') or
                 contains(lower-case($originatingSourceOrganisation), 'university of tasmania')">
                 <xsl:apply-templates select="." mode="IMAS">
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
                 <xsl:if test="$global_debugExceptions">
                     <xsl:message select="concat('Exception: No xslt for originating source ', $originatingSourceOrganisation, ' so using IMAS XSLT')">
                         <xsl:apply-templates select="." mode="IMAS">
                             <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                         </xsl:apply-templates>
                     </xsl:message>
                 </xsl:if>
             </xsl:otherwise>
         </xsl:choose>
    </xsl:template>
    
   
</xsl:stylesheet>
