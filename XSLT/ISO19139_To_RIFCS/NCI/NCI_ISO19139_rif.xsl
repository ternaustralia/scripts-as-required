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
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts">
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_acronym" select="'NCI'"/>
    <xsl:param name="global_originatingSource" select="'National Computational Infrastructure'"/> <!-- Only used as originating source if organisation name cannot be determined from Point Of Contact -->
    <xsl:param name="global_group" select="'National Computational Infrastructure'"/> 
    <xsl:param name="global_baseURI" select="'geonetwork.nci.org.au'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    <xsl:param name="global_ActivityKeyNCI" select="'ncris.innovation.gov.au/activity/20'"/>
    <xsl:variable name="anzsrcCodelist" select="document('anzsrc-codelist.xml')"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
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
            <xsl:apply-templates select="//gmd:MD_Metadata"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="node()"/>

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="gmd:MD_Metadata">
        
       <xsl:variable name="originatingSource">
           
           <xsl:variable name="originator_sequence" as="node()*" select="
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator')] |
               gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator'] |
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator'] |
               gmd:contact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator']"/>
           
           <xsl:variable name="resourceProvider_sequence" as="node()*" select="
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               gmd:contact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'resourceProvider']"/>
           
           <xsl:variable name="owner_sequence" as="node()*" select="
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
               gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
               gmd:contact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner']"/>
           
            <xsl:variable name="custodian_sequence" as="node()*" select="
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'custodian'] |
               gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'custodian'] |
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'custodian'] |
               gmd:contact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'custodian']"/>
          
           <xsl:variable name="pointOfContact_sequence" as="node()*" select="
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               gmd:contact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact']"/>
           
           
           <xsl:variable name="contact_sequence" as="node()*" select="
              gmd:contact/gmd:CI_ResponsibleParty"/>
           
            
           
            <xsl:choose>
                <xsl:when test="(count($originator_sequence) > 0) and string-length($originator_sequence[1]/gmd:organisationName) > 0">
                     <xsl:value-of select="$originator_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($resourceProvider_sequence) > 0) and string-length($resourceProvider_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$resourceProvider_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($owner_sequence) > 0) and string-length($owner_sequence[1]/gmd:organisationName) > 0">
                     <xsl:value-of select="$owner_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($custodian_sequence) > 0) and string-length($custodian_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$custodian_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($pointOfContact_sequence) > 0) and string-length($pointOfContact_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$pointOfContact_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($contact_sequence) > 0) and string-length($contact_sequence[1]/gmd:organisationName) > 0">
                     <xsl:value-of select="$contact_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_originatingSource"/>    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_group"/>    
            </xsl:attribute>
            
            <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_key"/>
        
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
                
                
            <xsl:element name="{custom:registryObjectClass(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)}">
    
                <xsl:attribute name="type" select="custom:registryObjectType(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)"/>
                        
                <xsl:if test="custom:registryObjectClass(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
                        <xsl:if test="
                            (count(gmd:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and 
                            (string-length(gmd:dateStamp/*[contains(lower-case(name()),'date')][1]) > 0)">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="gmd:dateStamp/*[contains(lower-case(name()),'date')][1]"/>
                            </xsl:attribute>  
                        </xsl:if>
                            
                </xsl:if>
                       
                    <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_identifier"/>
                    <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_location_metadata"/>
                    <xsl:apply-templates select="gmd:parentIdentifier" mode="registryObject_related_object"/>
                    <xsl:apply-templates select="gmd:dataSetURI" mode="registryObject_relatedInfo_data_via_service"/>
                    <xsl:apply-templates select="gmd:children/gmd:childIdentifier" mode="registryObject_related_object"/>
                 
                    <xsl:apply-templates
                        select="gmd:distributionInfo"/>
                     
                    <xsl:apply-templates select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source[string-length(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code) > 0]"
                         mode="registryObject_relatedInfo"/>
                     
                    <xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                             <xsl:with-param name="originatingSource" select="$originatingSource"/>
                    </xsl:apply-templates>
                
                <xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                </xsl:apply-templates>
                    
                </xsl:element>
            </registryObject>

            <xsl:apply-templates></xsl:apply-templates>

            
    </xsl:template>
    
    <xsl:template match="gmd:distributionInfo">
         <xsl:apply-templates select="gmd:MD_Distribution/gmd:transferOptions"/>
    </xsl:template>
    
    <xsl:template match="gmd:transferOptions">
        
        <xsl:apply-templates select="gmd:MD_DigitalTransferOptions" mode="registryObject_identifier"/>
        
        <xsl:apply-templates select="gmd:MD_DigitalTransferOptions" mode="registryObject_relatedInfo"/>
        
    </xsl:template>
    
   <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="originatingSource"/>
        
        <xsl:apply-templates
            select="gmd:citation/gmd:CI_Citation/gmd:title"
            mode="registryObject_name"/>
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            ancestor::gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0]"
            group-by="gmd:individualName">
            <xsl:apply-templates select="." mode="registryObject_related_object"/>
        </xsl:for-each-group>
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0)] |
            ancestor::gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0)] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0)] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0)]" 
            group-by="gmd:organisationName">
            <xsl:apply-templates select="." mode="registryObject_related_object"/>
        </xsl:for-each-group>
        
        <xsl:apply-templates
            select="gmd:topicCategory/gmd:MD_TopicCategoryCode"
            mode="registryObject_subject"/>
        
        <xsl:apply-templates
            select="gmd:topicCategory/gmd:MD_TopicCategoryCode"
            mode="registryObject_subject"/>
        
        <xsl:apply-templates
            select="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
            select="gmd:abstract"
            mode="registryObject_description_brief"/>
        
        <xsl:apply-templates
            select="gmd:purpose"
            mode="registryObject_description_notes"/>
        
        <xsl:apply-templates
            select="gmd:credit"
            mode="registryObject_description_notes"/>
        
       <xsl:apply-templates select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial"/>
       <xsl:apply-templates select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon" mode="registryObject_coverage_spatial"/>
       
        <xsl:apply-templates
            select="gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
        
        <xsl:apply-templates
            select="gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
            mode="registryObject_coverage_temporal_period"/>
        
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/gmd:MD_CreativeCommons[exists(gmd:licenseLink)]"
            mode="registryObject_rights_licence_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/gmd:MD_CreativeCommons"
            mode="registryObject_rights_rightsStatement_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/gmd:MD_Commons[exists(gmd:licenseLink)]"
            mode="registryObject_rights_licence_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/gmd:MD_Commons"
            mode="registryObject_rights_rightsStatement_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/gmd:MD_LegalConstraints"
            mode="registryObject_rights_rights"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/gmd:MD_Constraints"
            mode="registryObject_rights_rights"/>
        
        <xsl:if test="custom:registryObjectClass(ancestor::gmd:MD_Metadata/gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
            
            <xsl:apply-templates
                select="gmd:citation/gmd:CI_Citation/gmd:date"
                mode="registryObject_dates"/>
            
            
            <xsl:apply-templates select="gmd:citation/gmd:CI_Citation"
                mode="registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="originatingSource" select="$originatingSource"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
            
   </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
        <xsl:param name="originatingSource"/>
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            ancestor::gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0]"
            group-by="gmd:individualName">
            <xsl:call-template name="partyPerson">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:call-template>
        </xsl:for-each-group>
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) > 0] |
            ancestor::gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:organisationName)) > 0] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:organisationName)) > 0]"
            group-by="gmd:organisationName">
            <xsl:call-template name="partyGroup">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    
    

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="registryObject_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
        </key>
    </xsl:template>

    <xsl:template match="gmd:fileIdentifier" mode="registryObject_identifier">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <identifier type="local">
                <xsl:value-of select="."/>
            </identifier>
            <identifier type="uri">
                <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
            </identifier>
        </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="gmd:MD_DigitalTransferOptions" mode="registryObject_identifier">
        <xsl:for-each select="gmd:onLine/gmd:CI_OnlineResource">
            <xsl:if test="contains(lower-case(gmd:protocol), 'metadata-url')">
                <xsl:if test="string-length(normalize-space(gmd:linkage/gmd:URL)) > 0">
                    <identifier>
                        <xsl:attribute name="type">
                            <xsl:text>uri</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(gmd:linkage/gmd:URL)"/>
                    </identifier>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - Name Element  -->
    <xsl:template
        match="gmd:citation/gmd:CI_Citation/gmd:title"
        mode="registryObject_name">
        <xsl:if test="string-length(normalize-space(.)) > 0">
          <name>
              <xsl:attribute name="type">
                  <xsl:text>primary</xsl:text>
              </xsl:attribute>
              <namePart>
                  <xsl:value-of select="normalize-space(.)"/>
              </namePart>
          </name>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Dates Element  -->
    <xsl:template
        match="gmd:citation/gmd:CI_Citation/gmd:date"
        mode="registryObject_dates">
        <xsl:variable name="dateValue">
            <xsl:if test="string-length(normalize-space(gmd:CI_Date/gmd:date/gco:Date)) > 0">
                <xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:Date)"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(gmd:CI_Date/gmd:date/gco:DateTime)) > 0">
                <xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:DateTime)"/>
            </xsl:if>
        </xsl:variable> 
        <xsl:variable name="dateCode"
            select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
        <xsl:variable name="transformedDateCode">
            <xsl:choose>
                <xsl:when test="contains(lower-case($dateCode), 'creation')">
                    <xsl:text>created</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($dateCode), 'publication')">
                    <xsl:text>issued</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($dateCode), 'revision')">
                    <xsl:text>modified</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if
            test="
            (string-length($dateValue) > 0) and
            (string-length($transformedDateCode) > 0)">
            <dates>
                <xsl:attribute name="type">
                    <xsl:value-of select="$transformedDateCode"/>
                </xsl:attribute>
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>dateFrom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="dateFormat">
                        <xsl:text>W3CDTF</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="translate($dateValue, '-', '')"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="gmd:parentIdentifier" mode="registryObject_related_object">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym,'/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>isPartOf</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
   <xsl:template match="gmd:fileIdentifier" mode="registryObject_location_metadata">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <location>
                <address>
                    <electronic>
                        <xsl:attribute name="type">
                            <xsl:text>url</xsl:text>
                        </xsl:attribute>
                        <value>
                            <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="registryObject_related_object">
         <relatedObject>
            <key>
                <xsl:variable name="mappedKey" select="custom:getMappedKey(translate(normalize-space(current-grouping-key()),' ',''))"/>
                <xsl:choose>
                    <xsl:when test="string-length($mappedKey) > 0">
                        <xsl:value-of select="$mappedKey"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($global_acronym,'/', translate(normalize-space(current-grouping-key()),' ',''))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </key>
            <xsl:for-each-group select="current-group()/gmd:role"
                group-by="gmd:CI_RoleCode/@codeListValue">
                <xsl:variable name="code">
                    <xsl:value-of select="normalize-space(current-grouping-key())"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($code) > 0">
                        <relation>
                            <xsl:attribute name="type">
                                <xsl:value-of select="$code"/>
                            </xsl:attribute>
                        </relation>
                    </xsl:when>
                    <xsl:otherwise>
                        <relation>
                            <xsl:attribute name="type">
                                <xsl:text>unknown</xsl:text>
                            </xsl:attribute>
                        </relation>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each-group>
        </relatedObject>
    </xsl:template>

    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="gmd:childIdentifier" mode="registryObject_related_object">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym,'/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:keyword" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
        
        <xsl:variable name="anzsrcMappedCode_sequence" as="xs:string*">
                
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:variable name="subjectSplit_sequence" as="xs:string*" select="tokenize(., '&gt;')"/>
                    <xsl:for-each select="distinct-values($subjectSplit_sequence)">
                        
                        <!-- seek an anzsrc-code within the text -->
                        <xsl:variable name="match" as="xs:string*">
                            <xsl:analyze-string select="normalize-space(.)"
                                regex="[0-9]+">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(0)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        
                        <xsl:if test="count($match) > 0">
                            <xsl:for-each select="distinct-values($match)">
                                <xsl:if test="string-length(normalize-space(.)) > 0">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        
                        <!-- determines whether any text has a corresponding mapped code -->
                        <xsl:variable name="keyword" select="normalize-space(.)"/>
                        <xsl:variable name="code"
                            select="(normalize-space($anzsrcCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='ANZSRCCode']/gmx:codeEntry/gmx:CodeDefinition/gml:identifier[lower-case(following-sibling::gml:name) = lower-case($keyword)]))[1]"/>
                        <xsl:if test="string-length($code) > 0">
                            <xsl:value-of select="$code"/>
                        </xsl:if>
                        
                    </xsl:for-each>
                </xsl:if>
        </xsl:variable>
        
        <xsl:for-each select="reverse($anzsrcMappedCode_sequence)">
            <subject>
                <xsl:attribute name="type">
                    <xsl:value-of select="'anzsrc-for'"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </subject>
        </xsl:for-each>
    </xsl:template>
    
   <xsl:template match="gmd:MD_TopicCategoryCode" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:abstract" mode="registryObject_description_brief">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="brief">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:purpose" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:credit" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial">
        
        <xsl:variable name="crsCode" select="ancestor::gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code[contains(lower-case(following-sibling::gmd:codeSpace), 'crs')]"/>
        <xsl:if test="string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal)) > 0"/>
        <xsl:if
             test="
                (string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gmd:southBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gmd:westBoundLongitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gmd:eastBoundLongitude/gco:Decimal)) > 0)">
                 <xsl:variable name="spatialString">
                     <xsl:value-of
                         select="normalize-space(concat('northlimit=',gmd:northBoundLatitude/gco:Decimal,'; southlimit=',gmd:southBoundLatitude/gco:Decimal,'; westlimit=',gmd:westBoundLongitude/gco:Decimal,'; eastLimit=',gmd:eastBoundLongitude/gco:Decimal))"/>
                     
                     <xsl:if
                         test="
                         (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real)) > 0) and
                         (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real)) > 0)">
                         <xsl:value-of
                             select="normalize-space(concat('; uplimit=',gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real,'; downlimit=',gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real))"
                         />
                     </xsl:if>
                     <xsl:choose>
                          <xsl:when test="string-length(normalize-space($crsCode)) > 0">
                             <xsl:value-of select="concat('; projection=', $crsCode)"/>
                          </xsl:when>
                         <xsl:otherwise>
                             <xsl:text>; projection=GDA94</xsl:text>
                         </xsl:otherwise>
                     </xsl:choose>
                 </xsl:variable>
                 <coverage>
                     <spatial>
                         <xsl:attribute name="type">
                             <xsl:text>iso19139dcmiBox</xsl:text>
                         </xsl:attribute>
                         <xsl:value-of select="$spatialString"/>
                     </spatial>
                     <spatial>
                         <xsl:attribute name="type">
                             <xsl:text>text</xsl:text>
                         </xsl:attribute>
                         <xsl:value-of select="$spatialString"/>
                     </spatial>
                 </coverage>
        </xsl:if>
    </xsl:template>


    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_BoundingPolygon" mode="registryObject_coverage_spatial">
        <xsl:if
            test="string-length(normalize-space(gmd:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates)) > 0">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>gmlKmlPolyCoords</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of
                        select="replace(normalize-space(gmd:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates), ',0', '')"
                    />
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="registryObject_coverage_temporal_period">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:beginPosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:endPosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:MD_DigitalTransferOptions" mode="registryObject_relatedInfo">
        <xsl:for-each select="gmd:onLine/gmd:CI_OnlineResource">

            <xsl:variable name="protocol" select="normalize-space(gmd:protocol)"/>
            <xsl:if test="(string-length($protocol) > 0) and not(contains(lower-case($protocol), 'metadata-url'))">

                <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
                <xsl:if test="string-length($identifierValue) > 0">
                    <relatedInfo type="relatedInformation">
                            <identifier>
                                <xsl:attribute name="type">
                                    <xsl:choose>
                                        <xsl:when test="contains(lower-case($identifierValue), 'doi')">
                                            <xsl:text>doi</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>uri</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:value-of select="$identifierValue"/>
                            </identifier>

                            <relation>
                                <xsl:attribute name="type">
                                    <xsl:text>isAssociatedWith</xsl:text>
                                </xsl:attribute>
                            </relation>

                        <xsl:choose>
                            <!-- Use name as title if we have it... -->
                            <xsl:when test="string-length(normalize-space(gmd:name)) > 0">
                                <title>
                                    <xsl:value-of select="normalize-space(gmd:name)"/>
                                </title>
                                <!-- ...and then description as notes -->
                                <xsl:if
                                    test="string-length(normalize-space(gmd:description)) > 0">
                                    <notes>
                                        <xsl:value-of
                                            select="normalize-space(gmd:description)"/>
                                    </notes>
                                </xsl:if>
                            </xsl:when>
                            <!-- No name, so use description as title if we have it -->
                            <xsl:otherwise>
                                <xsl:if
                                    test="string-length(normalize-space(gmd:description)) > 0">
                                    <title>
                                        <xsl:value-of
                                            select="normalize-space(gmd:description)"/>
                                    </title>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </relatedInfo>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="gmd:dataSetURI" mode="registryObject_relatedInfo_data_via_service">
        <xsl:variable name="dataAccessLink" select="normalize-space(.)"/>
        <xsl:if test="contains($dataAccessLink, 'thredds/catalog')">
            <relatedInfo type="service">
                <identifier type="uri">
                    <xsl:value-of select="concat(substring-before($dataAccessLink, 'thredds/catalog'), 'thredds/catalog.html')"/>
                </identifier>
                <relation type="supports">
                    <description>Data via the thredds server</description>
                    <url><xsl:value-of select="$dataAccessLink"/></url>
                </relation>
                <title>thredds server</title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source" mode="registryObject_relatedInfo">
     <xsl:if test="string-length(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code) > 0">
        <relatedInfo>
           <xsl:attribute name="type">
               <xsl:choose>
                   <xsl:when test="contains(lower-case(gmd:sourceCitation/gmd:CI_Citation/gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue), 'modeldigital')">
                       <xsl:text>service</xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:text>reuseInformation</xsl:text>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:attribute>
           <identifier>
               <xsl:attribute name="type">
                   <xsl:choose>
                       <xsl:when test="contains(lower-case(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code), 'doi')">
                           <xsl:text>doi</xsl:text>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>uri</xsl:text>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:attribute>
               <xsl:value-of select="gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
           </identifier>
           <relation>
               <xsl:attribute name="type">
                   <xsl:choose>
                       <xsl:when test="contains(lower-case(gmd:sourceCitation/gmd:CI_Citation/gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue), 'modeldigital')">
                           <xsl:text>produces</xsl:text>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>supplements</xsl:text>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:attribute>
           </relation>
           <xsl:if test="string-length(normalize-space(gmd:sourceCitation/gmd:CI_Citation/gmd:title)) > 0">
             <title>
                 <xsl:value-of select="normalize-space(gmd:sourceCitation/gmd:CI_Citation/gmd:title)"/>
             </title>
           </xsl:if>
        </relatedInfo>
     </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:childIdentifier" mode="registryObject_relatedInfo">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedInfo type="collection">
                <identifier type="uri">
                    <xsl:value-of
                        select="concat('http://', $global_baseURI, $global_path, $identifier)"
                    />
                </identifier>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
                <xsl:if test="string-length(normalize-space(@title)) > 0"/>
                <title>
                    <xsl:value-of select="normalize-space(@title)"/>
                </title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Rights Licence - From CreativeCommons -->
    <xsl:template match="gmd:MD_CreativeCommons" mode="registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(gmd:licenseLink/gmd:URL)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="contains(lower-case($licenseLink), lower-case(gml:remarks))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space(gml:name)) > 0">
                                <xsl:value-of select="normalize-space(gml:name)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <!--xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <licence>
                        <xsl:value-of select='normalize-space(.)'/>
                    </licence>
                </rights>
            </xsl:if>
        </xsl:for-each-->
    </xsl:template>

    <!-- RegistryObject - Rights RightsStatement - From CreativeCommons -->
    <xsl:template match="gmd:MD_CreativeCommons" mode="registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="gmd:attributionConstraints">
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- RegistryObject - Rights Licence - From CreativeCommons -->
    <xsl:template match="gmd:MD_Commons" mode="registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(gmd:licenseLink/gmd:URL)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="contains(lower-case($licenseLink), lower-case(gml:remarks))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space(gml:name)) > 0">
                                <xsl:value-of select="normalize-space(gml:name)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        
        <!--xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.)) > 0">
            <rights>
            <licence>
            <xsl:value-of select='normalize-space(.)'/>
            </licence>
            </rights>
            </xsl:if>
            </xsl:for-each-->
    </xsl:template>
    
    <!-- RegistryObject - Rights RightsStatement - From CreativeCommons -->
    <xsl:template match="gmd:MD_Commons" mode="registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="gmd:attributionConstraints">
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="gmd:MD_Constraints" mode="registryObject_rights_rights">
       <xsl:copy-of select="custom:rights(.)"/>
    </xsl:template>
    
    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="registryObject_rights_rights">
       <xsl:copy-of select="custom:rights(.)"/>
    </xsl:template>
    
    <xsl:function name="custom:rights">
        <xsl:param name="currentNode" as="node()"/>
        <xsl:for-each select="$currentNode/gmd:useLimitation">
            <xsl:variable name="useLimitation" select="normalize-space(.)"/>
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($useLimitation) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$useLimitation"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$currentNode/gmd:otherConstraints">
            <xsl:variable name="otherConstraints" select="normalize-space(.)"/>
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($otherConstraints) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($otherConstraints), 'copyright')">
                        <rights>
                            <rightsStatement>
                                <xsl:value-of select="$otherConstraints"/>
                            </rightsStatement>
                        </rights>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($otherConstraints), 'licence') or 
                        contains(lower-case($otherConstraints), 'license')">
                        <rights>
                            <licence>
                                <xsl:value-of select="$otherConstraints"/>
                            </licence>
                        </rights>
                    </xsl:when>
                    <xsl:otherwise>
                        <rights>
                            <rightsStatement>
                                <xsl:value-of select="$otherConstraints"/>
                            </rightsStatement>
                        </rights>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="contains(lower-case($otherConstraints), 'picccby')">
                <rights>
                    <licence><xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;a href="http://polarcommons.org/ethics-and-norms-of-data-sharing.php"&gt; &lt;img src="http://polarcommons.org/images/PIC_print_small.png" style="border-width:0; width:40px; height:40px;" alt="Polar Information Commons's PICCCBY license."/&gt;&lt;/a&gt;&lt;a rel="license" href="http://creativecommons.org/licenses/by/3.0/" rel="license"&gt; &lt;img alt="Creative Commons License" style="border-width:0; width: 88px; height: 31px;" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /&gt;&lt;/a&gt;]]&gt;</xsl:text>
                        <!--xsl:for-each select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
                            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                            <xsl:if test="contains($otherConstraints, gml:remarks)">
                            <xsl:message>Identifier <xsl:value-of select='gml:identifier'/></xsl:message>
                            <xsl:message>Remarks <xsl:value-of select='gml:remarks'/></xsl:message>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="gml:remarks"/>
                            </xsl:if>
                            </xsl:if>
                            </xsl:for-each>
                            <xsl:value-of select="$otherConstraints"/-->
                    </licence>
                </rights>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:function>
    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="gmd:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="originatingSource"/>
         
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
       <xsl:variable name="citedResponsibleParty_sequence" select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty" as="node()*"/>
        
       <xsl:variable name="principalInvestigator_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator']"/>
        
        <xsl:variable name="author_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']"/>
        
        
        <xsl:variable name="contentexpert_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert']"/>
        
        <xsl:variable name="coInvestigator_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator']"/>
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']"/>  
        
        <xsl:variable name="owner_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner']"/>  
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']"/>
        
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
           <xsl:for-each select="$principalInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:value-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
            
            <xsl:for-each select="$author_sequence">
                <xsl:choose>
                    <xsl:when test="string-length(gmd:individualName) = 0">
                        <xsl:if test="string-length(gmd:organisationName) > 0">
                            <xsl:value-of select="gmd:organisationName"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="gmd:individualName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$contentexpert_sequence">
                <xsl:choose>
                    <xsl:when test="string-length(gmd:individualName) = 0">
                        <xsl:if test="string-length(gmd:organisationName) > 0">
                            <xsl:value-of select="gmd:organisationName"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="gmd:individualName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$coInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:copy-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
           
           <xsl:for-each select="$citedResponsibleParty_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:copy-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
        
        <xsl:for-each select="$allContributorName_sequence">
            <xsl:message select="concat('Contributor name: ', .)"/>
        </xsl:for-each>
        
        <!-- We can only accept one DOI; howerver, first we will find all -->
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*" select="gmd:identifier/gmd:MD_Identifier/gmd:code[contains(lower-case(.), 'doi')]"/>
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::gmd:MD_Metadata/gmd:fileIdentifier)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <xsl:if test="string-length($identifierToUse) > 0">
                        <identifier>
                            <xsl:if test="string-length($typeToUse) > 0">
                                <xsl:attribute name="type">
                                    <xsl:value-of select='$typeToUse'/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select='$identifierToUse'/>
                        </identifier>
                    </xsl:if>
    
                    <title>
                        <xsl:value-of select="gmd:title"/>
                    </title>
                    
                    <xsl:variable name="current_CI_Citation" select="."/>
                    <xsl:variable name="CI_Date_sequence" as="node()*">
                        <xsl:variable name="type_sequence" as="xs:string*" select="'creation,publication,revision'"/>
                        <xsl:for-each select="tokenize($type_sequence, ',')">
                            <xsl:variable name="type" select="."/>
                            <xsl:for-each select="$current_CI_Citation/gmd:date/gmd:CI_Date">
                                <xsl:variable name="code" select="normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
                                    <xsl:if test="contains(lower-case($code), lower-case($type))">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                    
                    <xsl:variable name="dateType">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:variable name="codevalue" select="$CI_Date_sequence[1]/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                            <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:variable name="dateValue">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:if test="string-length($CI_Date_sequence[1]/gmd:date/gco:Date) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/gmd:date/gco:Date, 1, 4)"/>
                            </xsl:if>
                            <xsl:if test="string-length($CI_Date_sequence[1]/gmd:date/gco:DateTime) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/gmd:date/gco:DateTime, 1, 4)"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:variable>
                    
                     <xsl:choose>
                        <xsl:when test="(string-length($dateType) > 0) and (string-length($dateValue) > 0)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="$dateType"/>
                                </xsl:attribute>
                                <xsl:value-of select="$dateValue"/>
                            </date>
                        </xsl:when>
                        <xsl:when test="
                            (count(ancestor::gmd:MD_Metadata/gmd:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and
                            (string-length(ancestor::gmd:MD_Metadata/gmd:dateStamp/*[contains(lower-case(name()),'date')][1]) > 3)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:text>publicationDate</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="substring(ancestor::gmd:MD_Metadata/gmd:dateStamp/*[contains(lower-case(name()),'date')][1], 1, 4)"/>
                            </date>
                        </xsl:when>
                       
                    </xsl:choose>
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisherOrganisationName" as="xs:string">
                        <xsl:variable name="publisherOrganisationName_sequence" as="xs:string*">
                            <xsl:for-each select="$publisher_sequence">
                                <xsl:if test="string-length(gmd:organisationName) > 0">
                                    <xsl:copy-of select="gmd:organisationName"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="count($publisherOrganisationName_sequence) > 0">
                                <xsl:value-of select="$publisherOrganisationName_sequence[1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$originatingSource"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:choose>
                        <xsl:when test="count($allContributorName_sequence) > 0">
                            <xsl:for-each select="distinct-values($allContributorName_sequence)">
                                <xsl:choose>
                                    <xsl:when test="($publisherOrganisationName != .) or ((count($allContributorName_sequence) = 1))">
                                        <contributor>
                                            <namePart>
                                                <xsl:value-of select="."/>
                                            </namePart>
                                        </contributor>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    
                    <publisher>
                        <xsl:value-of select="$publisherOrganisationName"/>
                    </publisher>
                    
               </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>



    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="partyPerson">
        <xsl:param name="originatingSource"/>
          
        <registryObject group="{$global_group}">

        <!--
        <xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/>
        <xsl:message select="concat('Individual name: ', gmd:individualName)"/>
        <xsl:message select="concat('Organisation name: ', gmd:organisationName)"/>
        -->
        
        <key>
            <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
        </key>
       
        <originatingSource>
            <xsl:value-of select="$originatingSource"/>
        </originatingSource> 
         
        <party type="person">
             <name type="primary">
                 <namePart>
                     <xsl:value-of select="normalize-space(current-grouping-key())"/>
                 </namePart>
             </name>

             <!-- If we have are dealing with individual who has an organisation name:
                 - leave out the address (so that it is on the organisation only); and 
                 - relate the individual to the organisation -->

              <xsl:choose>
                 <xsl:when
                     test="string-length(normalize-space(gmd:organisationName)) > 0">
                     <!--  Individual has an organisation name, so relate the individual to the organisation, and omit the address 
                             (the address will be included within the organisation to which this individual is related) -->
                     <relatedObject>
                         <key>
                             <xsl:value-of
                                 select="concat($global_acronym,'/', translate(normalize-space(gmd:organisationName),' ',''))"
                             />
                         </key>
                         <relation type="isMemberOf"/>
                     </relatedObject>
                 </xsl:when>

                 <xsl:otherwise>
                     <!-- Individual does not have an organisation name, so physicalAddress must pertain this individual -->
                     <xsl:call-template name="physicalAddress"/>
                 </xsl:otherwise>
             </xsl:choose>
             
             <!-- Individual - Phone and email on the individual, regardless of whether there's an organisation name -->
             <xsl:call-template name="onlineResource"/>
             <xsl:call-template name="telephone"/>
             <xsl:call-template name="facsimile"/>
             <xsl:call-template name="email"/>
        </party>
        </registryObject>
    </xsl:template>
        
    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="partyGroup">
        <xsl:param name="originatingSource"/>
        
        <registryObject group="{$global_group}">
            
            <!--
            <xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/>
            <xsl:message select="concat('Individual name: ', gmd:individualName)"/>
            <xsl:message select="concat('Organisation name: ', gmd:organisationName)"/>
            -->
            <key>
                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
            
            <party type="group">
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(current-grouping-key())"/>
                    </namePart>
                </name>
                
              <!-- If we are dealing with an Organisation with no individual name, phone and email must pertain to this organisation -->
                <xsl:variable name="individualName" select="normalize-space(gmd:individualName)"/>
                <xsl:if test="string-length($individualName) = 0">
                    <xsl:call-template name="onlineResource"/>
                    <xsl:call-template name="telephone"/>
                    <xsl:call-template name="facsimile"/>
                    <xsl:call-template name="email"/>
                </xsl:if>
                
                <!-- We are dealing with an organisation, so always include the address -->
                <xsl:call-template name="physicalAddress"/>
            </party>
        </registryObject>
    </xsl:template>
                     
    <xsl:template name="physicalAddress">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)">

                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint[string-length(gco:CharacterString) > 0]">
                                     <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </xsl:for-each>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)) > 0">
                                      <addressPart type="suburbOrPlaceLocality">
                                          <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)"/>
                                      </addressPart>
                                 </xsl:if>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)) > 0">
                                     <addressPart type="stateOrTerritory">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)"/>
                                     </addressPart>
                                 </xsl:if>
                                     
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)) > 0">
                                     <addressPart type="postCode">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)"/>
                                     </addressPart>
                                 </xsl:if>
                                 
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)) > 0">
                                     <addressPart type="country">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)"/>
                                     </addressPart>
                                 </xsl:if>
                            </physical>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="telephone">
        <xsl:variable name="phone_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($phone_sequence)">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart type="telephoneNumber">
                            <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="facsimile">
        <xsl:variable name="facsimile_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($facsimile_sequence)">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart type="faxNumber">
                            <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="email">
        <xsl:variable name="email_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($email_sequence)">
            <location>
                <address>
                    <electronic type="email">
                        <value>
                            <xsl:value-of select="normalize-space(.)"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="onlineResource">
        <xsl:variable name="url_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($url_sequence)">
            <xsl:choose>
                <xsl:when test="contains(lower-case(.), 'orcid')">
                    <identifier type="orcid">
                        <xsl:value-of select="."/> 
                    </identifier>
                </xsl:when>
                <xsl:otherwise>
                    <location>
                        <address>
                            <electronic type="url">
                                <value>
                                    <xsl:value-of select="."/>
                                </value>
                            </electronic>
                        </address>
                    </location>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
   <xsl:function name="custom:registryObjectClass" as="xs:string">
        <xsl:param name="scopeCode_sequence" as="xs:string*"/>
       <xsl:choose>
            <xsl:when test="count($scopeCode_sequence) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'dataset')">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'collectionSession')">
                        <xsl:text>activity</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'series')">
                        <xsl:text>activity</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'software')">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'model')">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'service')">
                        <xsl:text>service</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>collection</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>collection</xsl:text>
            </xsl:otherwise>
       </xsl:choose>
   </xsl:function>
    
    <xsl:function name="custom:registryObjectType" as="xs:string*">
        <xsl:param name="scopeCode_sequence" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="count($scopeCode_sequence) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'dataset')">
                        <xsl:text>dataset</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'collectionSession')">
                        <xsl:text>project</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'series')">
                        <xsl:text>program</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'software')">
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'model')">
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'service')">
                        <xsl:text>report</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>dataset</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:isRole" as="xs:boolean">
        <xsl:param name="parent"/>
        <xsl:param name="role"/>
        <xsl:variable name="roleFound_sequence" as="xs:string*">
            <xsl:for-each-group select="$parent/gmd:role"
                    group-by="gmd:CI_RoleCode/@codeListValue">
                    <xsl:if test="(string-length($role) > 0) and contains(lower-case(current-grouping-key()), lower-case($role))">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($roleFound_sequence) > 0">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="custom:getMappedKey" as="xs:string">
        <xsl:param name="inputKey" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($inputKey), 'nationalcomputationalinfrastructure') or 
                            contains(lower-case($inputKey), 'nci')">
                <xsl:value-of select="$global_ActivityKeyNCI"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise> 
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>