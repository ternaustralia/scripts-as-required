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
    
    <xsl:param name="global_originatingSource" select="'Australian Ocean Data Network'"/> <!-- Only used as originating source if organisation name cannot be determined from Point Of Contact -->
    <xsl:param name="global_baseURI" select="'catalogue.aodn.org.au'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/metadata.show?uuid='"/>
    <xsl:variable name="anzsrcCodelist" select="document('anzsrc-codelist.xml')"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="default"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="*:MD_Metadata" mode="default">
        <xsl:param name="source"/>
        
        <xsl:variable name="originatingSource">
           
           <xsl:variable name="originator_sequence" as="node()*" select="
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[(*:role/*:CI_RoleCode/@codeListValue = 'originator')] |
               *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'originator'] |
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'originator'] |
               *:contact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'originator']"/>
           
           <xsl:variable name="resourceProvider_sequence" as="node()*" select="
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               *:contact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'resourceProvider']"/>
           
           <xsl:variable name="owner_sequence" as="node()*" select="
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner'] |
               *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner'] |
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner'] |
               *:contact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner']"/>
           
            <xsl:variable name="custodian_sequence" as="node()*" select="
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'custodian'] |
               *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'custodian'] |
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'custodian'] |
               *:contact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'custodian']"/>
          
           <xsl:variable name="pointOfContact_sequence" as="node()*" select="
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               *:identificationInfo/*[contains(lower-case(name()),'identification')]/*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               *:contact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'pointOfContact']"/>
           
           
           <xsl:variable name="contact_sequence" as="node()*" select="
              *:contact/*:CI_ResponsibleParty"/>
           
            
           
            <xsl:choose>
                <xsl:when test="(count($originator_sequence) > 0) and string-length($originator_sequence[1]/*:organisationName) > 0">
                     <xsl:value-of select="$originator_sequence[1]/*:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($resourceProvider_sequence) > 0) and string-length($resourceProvider_sequence[1]/*:organisationName) > 0">
                    <xsl:value-of select="$resourceProvider_sequence[1]/*:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($owner_sequence) > 0) and string-length($owner_sequence[1]/*:organisationName) > 0">
                     <xsl:value-of select="$owner_sequence[1]/*:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($custodian_sequence) > 0) and string-length($custodian_sequence[1]/*:organisationName) > 0">
                    <xsl:value-of select="$custodian_sequence[1]/*:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($pointOfContact_sequence) > 0) and string-length($pointOfContact_sequence[1]/*:organisationName) > 0">
                    <xsl:value-of select="$pointOfContact_sequence[1]/*:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($contact_sequence) > 0) and string-length($contact_sequence[1]/*:organisationName) > 0">
                     <xsl:value-of select="$contact_sequence[1]/*:organisationName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_originatingSource"/>    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$source"/>    
            </xsl:attribute>
            
            <xsl:apply-templates select="*:fileIdentifier" mode="registryObject_key">
                <xsl:with-param name="source" select="$source"/>
            </xsl:apply-templates>
        
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
                
                
            <xsl:element name="{custom:registryObjectClass(*:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)}">
    
                <xsl:attribute name="type" select="custom:registryObjectType(*:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)"/>
                        
                <xsl:if test="custom:registryObjectClass(*:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
                        <xsl:if test="
                            (count(*:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and 
                            (string-length(*:dateStamp/*[contains(lower-case(name()),'date')][1]) > 0)">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="*:dateStamp/*[contains(lower-case(name()),'date')][1]"/>
                            </xsl:attribute>  
                        </xsl:if>
                            
                </xsl:if>
                
                <xsl:apply-templates select="*:distributionInfo" mode="registryObject_links"/>
                
                <xsl:apply-templates select="*:fileIdentifier" mode="registryObject_location_metadata">
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            
                <xsl:apply-templates select="*:parentIdentifier" mode="registryObject_related_object">
                     <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
                 
                <xsl:apply-templates select="*:dataSetURI" mode="registryObject_relatedInfo_data_via_service"/>
                
                <xsl:apply-templates select="*:children/*:childIdentifier" mode="registryObject_related_object">
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
                 
                   
                
                <xsl:apply-templates select="*:children/*:childIdentifier"
                    mode="registryObject_related_object">
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
                 
                <xsl:apply-templates select="*:dataQualityInfo/*:DQ_DataQuality/*:lineage/*:LI_Lineage/*:source/*:LI_Source[string-length(*:sourceCitation/*:CI_Citation/*:identifier/*:MD_Identifier/*:code) > 0]"
                     mode="registryObject_relatedInfo"/>
                 
                <xsl:apply-templates select="*:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
                
                <xsl:apply-templates select="*:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
                    
                </xsl:element>
            </registryObject>

            <xsl:apply-templates></xsl:apply-templates>

            
    </xsl:template>
    
    <xsl:template match="*:distributionInfo" mode="registryObject_links">
        <xsl:message select="concat('template match: ', name(.))"/>
        <xsl:apply-templates select="*:MD_Distribution/*:transferOptions" mode="registryObject_links"/>
    </xsl:template>
    
    <xsl:template match="*:transferOptions"  mode="registryObject_links">
        <xsl:message select="concat('template match: ', name(.))"/>
        <xsl:apply-templates select="*:MD_DigitalTransferOptions" mode="registryObject_identifier"/>
        <xsl:apply-templates select="*:MD_DigitalTransferOptions" mode="registryObject_relatedInfo"/>
    </xsl:template>
    
   <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="originatingSource"/>
        <xsl:param name="source"/>
        
        <xsl:apply-templates
            select="*:citation/*:CI_Citation/*:title"
            mode="registryObject_name"/>
        
        <xsl:for-each-group
            select="*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0] |
            ancestor::*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0] |
            *:pointOfContact/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0] |
            ancestor::*:MD_Metadata/*:contact/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0]"
            group-by="*:individualName">
            <xsl:apply-templates select="." mode="registryObject_related_object">
                <xsl:with-param name="source" select="$source"/>
            </xsl:apply-templates>
        </xsl:for-each-group>
        
        <xsl:for-each-group
            select="*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0) and ((string-length(normalize-space(*:individualName))) = 0)] |
            ancestor::*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0) and ((string-length(normalize-space(*:individualName))) = 0)] |
            *:pointOfContact/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0) and ((string-length(normalize-space(*:individualName))) = 0)] |
            ancestor::*:MD_Metadata/*:contact/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0) and ((string-length(normalize-space(*:individualName))) = 0)]" 
            group-by="*:organisationName">
            <xsl:apply-templates select="." mode="registryObject_related_object">
                <xsl:with-param name="source" select="$source"/>
            </xsl:apply-templates>
        </xsl:for-each-group>
        
        <xsl:apply-templates
            select="*:topicCategory/*:MD_TopicCategoryCode"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
            select="*:descriptiveKeywords/*:MD_Keywords/*:keyword"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
            select="*:abstract"
            mode="registryObject_description_full"/>
        
        <xsl:apply-templates
            select="*:purpose"
            mode="registryObject_description_notes"/>
        
        <xsl:apply-templates
            select="*:credit"
            mode="registryObject_description_notes"/>
        
       <xsl:apply-templates select="*:extent/*:EX_Extent/*:geographicElement/*:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial"/>
       <xsl:apply-templates select="*:extent/*:EX_Extent/*:geographicElement/*:EX_BoundingPolygon" mode="registryObject_coverage_spatial"/>
       
        <xsl:apply-templates
            select="*:extent/*:EX_Extent/*:temporalElement/*:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
        
        <xsl:apply-templates
            select="*:extent/*:EX_Extent/*:temporalElement/*:EX_TemporalExtent"
            mode="registryObject_coverage_temporal_period"/>
        
        
        <xsl:apply-templates
            select="*:resourceConstraints/*:MD_CreativeCommons[exists(*:licenseLink)]"
            mode="registryObject_rights_licence_creative"/>
        
        <xsl:apply-templates
            select="*:resourceConstraints/*:MD_CreativeCommons"
            mode="registryObject_rights_rightsStatement_creative"/>
        
        <xsl:apply-templates
            select="*:resourceConstraints/*:MD_Commons[exists(*:licenseLink)]"
            mode="registryObject_rights_licence_creative"/>
        
        <xsl:apply-templates
            select="*:resourceConstraints/*:MD_Commons"
            mode="registryObject_rights_rightsStatement_creative"/>
        
        <xsl:apply-templates
            select="*:resourceConstraints/*:MD_LegalConstraints"
            mode="registryObject_rights_rights"/>
        
        <xsl:apply-templates
            select="*:resourceConstraints/*:MD_Constraints"
            mode="registryObject_rights_rights"/>
        
        <xsl:if test="custom:registryObjectClass(ancestor::*:MD_Metadata/*:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
            
            <xsl:apply-templates
                select="*:citation/*:CI_Citation/*:date"
                mode="registryObject_dates"/>
            
            
            <xsl:apply-templates select="*:citation/*:CI_Citation"
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
        <xsl:param name="source"/>
        <xsl:for-each-group
            select="*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0] |
            ancestor::*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0] |
            *:pointOfContact/*:CI_ResponsibleParty[string-length(normalize-space(*:individualName)) > 0] |
            ancestor::*:MD_Metadata/*:contact/*:CI_ResponsibleParty[string-length(normalize-space(*:individualName)) > 0]"
            group-by="*:individualName">
            <xsl:call-template name="partyPersonDefault">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
                <xsl:with-param name="source" select="$source"/>
            </xsl:call-template>
        </xsl:for-each-group>
        
        <xsl:for-each-group
            select="*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[(string-length(normalize-space(*:organisationName))) > 0] |
            ancestor::*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[(string-length(normalize-space(*:organisationName))) > 0] |
            *:pointOfContact/*:CI_ResponsibleParty[string-length(normalize-space(*:organisationName)) > 0] |
            ancestor::*:MD_Metadata/*:contact/*:CI_ResponsibleParty[string-length(normalize-space(*:organisationName)) > 0]"
            group-by="*:organisationName">
            <xsl:call-template name="partyGroupDefault">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
                <xsl:with-param name="source" select="$source"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="*:fileIdentifier" mode="registryObject_key">
        <xsl:param name="source"/>
        <key>
            <xsl:value-of select="concat($source, '/', normalize-space(.))"/>
        </key>
    </xsl:template>

    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="*:MD_DigitalTransferOptions" mode="registryObject_identifier">
        <xsl:message select="concat('template match: ', name(.))"/>
        <xsl:for-each select="*:onLine/*:CI_OnlineResource">
            <xsl:if test="contains(lower-case(*:protocol), 'metadata-url')">
                <xsl:if test="string-length(normalize-space(*:linkage/*:URL)) > 0">
                    <identifier>
                        <xsl:attribute name="type">
                            <xsl:text>uri</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(*:linkage/*:URL)"/>
                    </identifier>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- RegistryObject - Name Element  -->
    <xsl:template
        match="*:citation/*:CI_Citation/*:title"
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
        match="*:citation/*:CI_Citation/*:date"
        mode="registryObject_dates">
        <xsl:message select="concat('registryObject_dates ', name(.))"/>
        <xsl:variable name="dateValue">
            <xsl:if test="string-length(normalize-space(*:CI_Date/*:date/gco:Date)) > 0">
                <xsl:value-of select="normalize-space(*:CI_Date/*:date/gco:Date)"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(*:CI_Date/*:date/gco:DateTime)) > 0">
                <xsl:value-of select="normalize-space(*:CI_Date/*:date/gco:DateTime)"/>
            </xsl:if>
        </xsl:variable> 
        <xsl:variable name="dateCode"
            select="normalize-space(*:CI_Date/*:dateType/*:CI_DateTypeCode/@codeListValue)"/>
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
    <xsl:template match="*:parentIdentifier" mode="registryObject_related_object">
        <xsl:param name="source"/>
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($source, '/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>isPartOf</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
   <xsl:template match="*:fileIdentifier" mode="registryObject_location_metadata">
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
    <xsl:template match="*:CI_ResponsibleParty" mode="registryObject_related_object">
        <xsl:param name="source"/>
         <relatedObject>
            <key>
               <xsl:value-of select="concat($source, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            <xsl:for-each-group select="current-group()/*:role"
                group-by="*:CI_RoleCode/@codeListValue">
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
    <xsl:template match="*:childIdentifier" mode="registryObject_related_object">
        <xsl:param name="source"/>
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($source, '/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*:keyword" mode="registryObject_subject">
        <xsl:variable name="idType">
            <xsl:choose>
                <xsl:when test="contains(gmx:Anchor/@xlink:href, 'anzsrc-for')">
                    <xsl:text>anzsrc-for</xsl:text>
                </xsl:when>
                <xsl:when test="contains(gmx:Anchor/@xlink:href, 'anzsrc-toa')">
                    <xsl:text>anzsrc-toa</xsl:text>
                </xsl:when>
                <xsl:when test="contains(gmx:Anchor/@xlink:href, 'anzsrc-toa')">
                    <xsl:text>anzsrc-for</xsl:text>
                </xsl:when>
                <xsl:when test="contains(gmx:Anchor/@xlink:href, 'anzsrc-seo')">
                    <xsl:text>anzsrc-seo</xsl:text>
                </xsl:when>
                <xsl:when test="contains(gmx:Anchor/@xlink:href, 'gcmd')">
                    <xsl:text>gcmd</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>local</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="termIdentifier" select="substring-after(gmx:Anchor/@xlink:href, 'id=')"/>
        
        <xsl:variable name="id" select="tokenize($termIdentifier, '/')[last()]"/>
        
        <xsl:choose>
            <xsl:when test="contains($idType, 'anzsrc')">
                <xsl:if test="string-length($id) > 0">
                    <subject type="{$idType}" termIdentifier="{$termIdentifier}">
                        <xsl:value-of select="$id"/>
                    </subject>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(.) > 0">
                    <subject type="{$idType}">
                        <xsl:if test="string-length($termIdentifier) > 0">
                            <xsl:attribute name="termIdentifier">
                                <xsl:value-of select="$termIdentifier"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </subject>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
   <xsl:template match="*:MD_TopicCategoryCode" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Decription Element -->
    <xsl:template match="*:abstract" mode="registryObject_description_full">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="full">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="*:purpose" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="*:credit" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="*:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial">
        
        <xsl:variable name="crsCode" select="ancestor::*:MD_Metadata/*:referenceSystemInfo/*:MD_ReferenceSystem/*:referenceSystemIdentifier/*:RS_Identifier/*:code[contains(lower-case(following-sibling::*:codeSpace), 'crs')]"/>
        <xsl:if test="string-length(normalize-space(*:northBoundLatitude/gco:Decimal)) > 0"/>
        <xsl:if
             test="
                (string-length(normalize-space(*:northBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(*:southBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(*:westBoundLongitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(*:eastBoundLongitude/gco:Decimal)) > 0)">
                 <xsl:variable name="spatialString">
                     <xsl:value-of
                         select="normalize-space(concat('northlimit=',*:northBoundLatitude/gco:Decimal,'; southlimit=',*:southBoundLatitude/gco:Decimal,'; westlimit=',*:westBoundLongitude/gco:Decimal,'; eastLimit=',*:eastBoundLongitude/gco:Decimal))"/>
                     
                     <xsl:if
                         test="
                         (string-length(normalize-space(*:EX_VerticalExtent/*:maximumValue/gco:Real)) > 0) and
                         (string-length(normalize-space(*:EX_VerticalExtent/*:minimumValue/gco:Real)) > 0)">
                         <xsl:value-of
                             select="normalize-space(concat('; uplimit=',*:EX_VerticalExtent/*:maximumValue/gco:Real,'; downlimit=',*:EX_VerticalExtent/*:minimumValue/gco:Real))"
                         />
                     </xsl:if>
                      <xsl:if test="string-length(normalize-space($crsCode)) > 0">
                         <xsl:value-of select="concat('; projection=', $crsCode)"/>
                      </xsl:if>
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
    <xsl:template match="*:EX_BoundingPolygon" mode="registryObject_coverage_spatial">
        <xsl:if
            test="string-length(normalize-space(*:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates)) > 0">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>gmlKmlPolyCoords</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of
                        select="replace(normalize-space(*:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates), ',0', '')"
                    />
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="*:EX_TemporalExtent" mode="registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(*:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0) or
                  (string-length(normalize-space(*:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(*:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(*:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(*:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(*:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="*:EX_TemporalExtent" mode="registryObject_coverage_temporal_period">
        <xsl:if
            test="(string-length(normalize-space(*:extent/gml:TimePeriod/gml:beginPosition)) > 0) or
                  (string-length(normalize-space(*:extent/gml:TimePeriod/gml:endPosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(*:extent/gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(*:extent/gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(*:extent/gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(*:extent/gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="*:MD_DigitalTransferOptions" mode="registryObject_relatedInfo">
        <xsl:for-each select="*:onLine/*:CI_OnlineResource">

            <xsl:variable name="protocol" select="normalize-space(*:protocol)"/>
            <xsl:if test="(string-length($protocol) > 0) and not(contains(lower-case($protocol), 'metadata-url'))">

                <xsl:variable name="identifierValue" select="normalize-space(*:linkage/*:URL)"/>
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
                            <xsl:when test="string-length(normalize-space(*:name)) > 0">
                                <title>
                                    <xsl:value-of select="normalize-space(*:name)"/>
                                </title>
                                <!-- ...and then description as notes -->
                                <xsl:if
                                    test="string-length(normalize-space(*:description)) > 0">
                                    <notes>
                                        <xsl:value-of
                                            select="normalize-space(*:description)"/>
                                    </notes>
                                </xsl:if>
                            </xsl:when>
                            <!-- No name, so use description as title if we have it -->
                            <xsl:otherwise>
                                <xsl:if
                                    test="string-length(normalize-space(*:description)) > 0">
                                    <title>
                                        <xsl:value-of
                                            select="normalize-space(*:description)"/>
                                    </title>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </relatedInfo>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*:dataSetURI" mode="registryObject_relatedInfo_data_via_service">
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
    
    
    <xsl:template match="*:dataQualityInfo/*:DQ_DataQuality/*:lineage/*:LI_Lineage/*:source/*:LI_Source" mode="registryObject_relatedInfo">
     <xsl:if test="string-length(*:sourceCitation/*:CI_Citation/*:identifier/*:MD_Identifier/*:code) > 0">
        <relatedInfo>
           <xsl:attribute name="type">
               <xsl:choose>
                   <xsl:when test="contains(lower-case(*:sourceCitation/*:CI_Citation/*:presentationForm/*:CI_PresentationFormCode/@codeListValue), 'modeldigital')">
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
                       <xsl:when test="contains(lower-case(*:sourceCitation/*:CI_Citation/*:identifier/*:MD_Identifier/*:code), 'doi')">
                           <xsl:text>doi</xsl:text>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>uri</xsl:text>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:attribute>
               <xsl:value-of select="*:sourceCitation/*:CI_Citation/*:identifier/*:MD_Identifier/*:code"/>
           </identifier>
           <relation>
               <xsl:attribute name="type">
                   <xsl:choose>
                       <xsl:when test="contains(lower-case(*:sourceCitation/*:CI_Citation/*:presentationForm/*:CI_PresentationFormCode/@codeListValue), 'modeldigital')">
                           <xsl:text>produces</xsl:text>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>supplements</xsl:text>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:attribute>
           </relation>
           <xsl:if test="string-length(normalize-space(*:sourceCitation/*:CI_Citation/*:title)) > 0">
             <title>
                 <xsl:value-of select="normalize-space(*:sourceCitation/*:CI_Citation/*:title)"/>
             </title>
           </xsl:if>
        </relatedInfo>
     </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="*:childIdentifier" mode="registryObject_relatedInfo">
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
    <xsl:template match="*:MD_CreativeCommons" mode="registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(*:licenseLink/*:URL)"/>
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

        <!--xsl:for-each select="*:otherConstraints">
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
    <xsl:template match="*:MD_CreativeCommons" mode="registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="*:attributionConstraints">
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
    <xsl:template match="*:MD_Commons" mode="registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(*:licenseLink/*:URL)"/>
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
        
        <!--xsl:for-each select="*:otherConstraints">
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
    <xsl:template match="*:MD_Commons" mode="registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="*:attributionConstraints">
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
    <xsl:template match="*:MD_Constraints" mode="registryObject_rights_rights">
       <xsl:copy-of select="custom:rights(.)"/>
    </xsl:template>
    
    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="*:MD_LegalConstraints" mode="registryObject_rights_rights">
       <xsl:copy-of select="custom:rights(.)"/>
    </xsl:template>
    
    <xsl:function name="custom:rights">
        <xsl:param name="currentNode" as="node()"/>
        <xsl:for-each select="$currentNode/*:useLimitation">
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
        <xsl:for-each select="$currentNode/*:otherConstraints">
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
    <xsl:template match="*:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="originatingSource"/>
         
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
       <xsl:variable name="citedResponsibleParty_sequence" select="*:citedResponsibleParty/*:CI_ResponsibleParty" as="node()*"/>
        
       <xsl:variable name="principalInvestigator_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'principalInvestigator']"/>
        
        <xsl:variable name="author_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'author'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'author'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'author']"/>
        
        
        <xsl:variable name="contentexpert_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'contentexpert']"/>
        
        <xsl:variable name="coInvestigator_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'coInvestigator']"/>
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'publisher']"/>  
        
        <xsl:variable name="owner_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'owner']"/>  
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            *:citedResponsibleParty/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../*:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../*:pointOfContact/*:CI_ResponsibleParty[*:role/*:CI_RoleCode/@codeListValue = 'publisher']"/>
        
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
           <xsl:for-each select="$principalInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(*:individualName) = 0">
                       <xsl:if test="string-length(*:organisationName) > 0">
                           <xsl:value-of select="*:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="*:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
            
            <xsl:for-each select="$author_sequence">
                <xsl:choose>
                    <xsl:when test="string-length(*:individualName) = 0">
                        <xsl:if test="string-length(*:organisationName) > 0">
                            <xsl:value-of select="*:organisationName"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="*:individualName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$contentexpert_sequence">
                <xsl:choose>
                    <xsl:when test="string-length(*:individualName) = 0">
                        <xsl:if test="string-length(*:organisationName) > 0">
                            <xsl:value-of select="*:organisationName"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="*:individualName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$coInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(*:individualName) = 0">
                       <xsl:if test="string-length(*:organisationName) > 0">
                           <xsl:copy-of select="*:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="*:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
           
           <xsl:for-each select="$citedResponsibleParty_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(*:individualName) = 0">
                       <xsl:if test="string-length(*:organisationName) > 0">
                           <xsl:copy-of select="*:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="*:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
        
        <xsl:for-each select="$allContributorName_sequence">
            <xsl:message select="concat('Contributor name: ', .)"/>
        </xsl:for-each>
        
        <!-- We can only accept one DOI; howerver, first we will find all -->
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*" select="*:identifier/*:MD_Identifier/*:code[contains(lower-case(.), 'doi')]"/>
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::*:MD_Metadata/*:fileIdentifier)"/>
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
                        <xsl:value-of select="*:title"/>
                    </title>
                    
                    <xsl:variable name="current_CI_Citation" select="."/>
                    <xsl:variable name="CI_Date_sequence" as="node()*">
                        <xsl:variable name="type_sequence" as="xs:string*" select="'creation,publication,revision'"/>
                        <xsl:for-each select="tokenize($type_sequence, ',')">
                            <xsl:variable name="type" select="."/>
                            <xsl:for-each select="$current_CI_Citation/*:date/*:CI_Date">
                                <xsl:variable name="code" select="normalize-space(*:dateType/*:CI_DateTypeCode/@codeListValue)"/>
                                    <xsl:if test="contains(lower-case($code), lower-case($type))">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = '*:CI_DateTypeCode']"/>
                    
                    <xsl:variable name="dateType">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:variable name="codevalue" select="$CI_Date_sequence[1]/*:dateType/*:CI_DateTypeCode/@codeListValue"/>
                            <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:variable name="dateValue">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:if test="string-length($CI_Date_sequence[1]/*:date/gco:Date) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/*:date/gco:Date, 1, 4)"/>
                            </xsl:if>
                            <xsl:if test="string-length($CI_Date_sequence[1]/*:date/gco:DateTime) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/*:date/gco:DateTime, 1, 4)"/>
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
                            (count(ancestor::*:MD_Metadata/*:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and
                            (string-length(ancestor::*:MD_Metadata/*:dateStamp/*[contains(lower-case(name()),'date')][1]) > 3)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:text>publicationDate</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="substring(ancestor::*:MD_Metadata/*:dateStamp/*[contains(lower-case(name()),'date')][1], 1, 4)"/>
                            </date>
                        </xsl:when>
                       
                    </xsl:choose>
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisherOrganisationName" as="xs:string">
                        <xsl:variable name="publisherOrganisationName_sequence" as="xs:string*">
                            <xsl:for-each select="$publisher_sequence">
                                <xsl:if test="string-length(*:organisationName) > 0">
                                    <xsl:copy-of select="*:organisationName"/>
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
    <xsl:template name="partyPersonDefault">
        <xsl:param name="originatingSource"/>
        <xsl:param name="source"/>
          
        <registryObject group="{$source}">

        <!--
        <xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/>
        <xsl:message select="concat('Individual name: ', *:individualName)"/>
        <xsl:message select="concat('Organisation name: ', *:organisationName)"/>
        -->
        
        <key>
            <xsl:value-of select="concat($source, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
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
                     test="string-length(normalize-space(*:organisationName)) > 0">
                     <!--  Individual has an organisation name, so relate the individual to the organisation, and omit the address 
                             (the address will be included within the organisation to which this individual is related) -->
                     <relatedObject>
                         <key>
                             <xsl:value-of
                                 select="concat($source, '/', translate(normalize-space(*:organisationName),' ',''))"
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
    <xsl:template name="partyGroupDefault">
        <xsl:param name="originatingSource"/>
        <xsl:param name="source"/>
        
        <registryObject group="{$source}">
            
            <!--
            <xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/>
            <xsl:message select="concat('Individual name: ', *:individualName)"/>
            <xsl:message select="concat('Organisation name: ', *:organisationName)"/>
            -->
            <key>
                <xsl:value-of select="concat($source, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
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
                <xsl:variable name="individualName" select="normalize-space(*:individualName)"/>
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
                select="count(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/child::*)">

                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:deliveryPoint[string-length(gco:CharacterString) > 0]">
                                     <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </xsl:for-each>
                                
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:city)) > 0">
                                      <addressPart type="suburbOrPlaceLocality">
                                          <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:city)"/>
                                      </addressPart>
                                 </xsl:if>
                                
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:administrativeArea)) > 0">
                                     <addressPart type="stateOrTerritory">
                                         <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:administrativeArea)"/>
                                     </addressPart>
                                 </xsl:if>
                                     
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:postalCode)) > 0">
                                     <addressPart type="postCode">
                                         <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:postalCode)"/>
                                     </addressPart>
                                 </xsl:if>
                                 
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:country)) > 0">
                                     <addressPart type="country">
                                         <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:country)"/>
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
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:phone/*:CI_Telephone/*:voice">
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
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:phone/*:CI_Telephone/*:facsimile">
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
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:electronicMailAddress">
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
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:onlineResource/*:CI_OnlineResource/*:linkage/*:URL">
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
    
    <xsl:function name="custom:sequence_contains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="substring" as="xs:string"/>
        
        <xsl:variable name="matches_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:if test="contains(lower-case(normalize-space(.)), lower-case($substring))">
                        <xsl:copy-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($matches_sequence) > 0">
                <xsl:copy-of select="true()"/>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
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
</xsl:stylesheet>