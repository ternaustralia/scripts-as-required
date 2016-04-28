<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0" 
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0" 
    xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0" 
    xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0" 
    xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0" 
    xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0" 
    xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0" 
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0" 
    xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0" 
    xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0" 
    xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0" 
    xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0" 
    xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0" 
    xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0" 
    xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0" 
    xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0" 
    xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0" 
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0" 
    xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0" 
    xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0" 
    xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/1.0" 
    xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0" 
    xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/1.0" 
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0" 
    xmlns:gml="http://www.opengis.net/gml/3.2" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="oai">
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements='*'/>
    <xsl:param name="global_originatingSource" select="'Geoscience Australia'"/>
    <xsl:param name="global_acronym" select="'GA'"/>
    <xsl:param name="global_baseURI" select="'http://ecat.ga.gov.au/'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/search#!'"/>
    <xsl:param name="global_group" select="'Geoscience Australia'"/>
    <xsl:param name="global_publisherName" select="'Geoscience Australia'"/>
    <xsl:param name="global_publisherPlace" select="'Canberra'"/>
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
            <xsl:apply-templates select="//mdb:MD_Metadata"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="node()"/>

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="mdb:MD_Metadata">
        
       <xsl:variable name="originatingSource">
           
           <xsl:variable name="originator_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'originator'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'originator'] |
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'originator'] |
               mdb:contact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'originator']"/>
           
           <xsl:variable name="resourceProvider_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               mdb:contact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider']"/>
           
           <xsl:variable name="owner_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
               mdb:contact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner']"/>
           
            <xsl:variable name="custodian_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian'] |
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian'] |
               mdb:contact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'custodian']"/>
          
           <xsl:variable name="pointOfContact_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'pointOfContact'] |
               mdb:contact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'pointOfContact']"/>
           
           
           <xsl:variable name="contact_sequence" as="node()*" select="
              mdb:contact/cit:CI_Responsibility"/>
           
            
           
            <xsl:choose>
                <xsl:when test="(count($originator_sequence) > 0) and string-length($originator_sequence[1]/cit:party/cit:CI_Organisation/cit:name) > 0">
                     <xsl:value-of select="$originator_sequence[1]/cit:party/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($resourceProvider_sequence) > 0) and string-length($resourceProvider_sequence[1]/cit:party/cit:CI_Organisation/cit:name) > 0">
                    <xsl:value-of select="$resourceProvider_sequence[1]/cit:party/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($owner_sequence) > 0) and string-length($owner_sequence[1]/cit:party/cit:CI_Organisation/cit:name) > 0">
                     <xsl:value-of select="$owner_sequence[1]/cit:party/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($custodian_sequence) > 0) and string-length($custodian_sequence[1]/cit:party/cit:CI_Organisation/cit:name) > 0">
                    <xsl:value-of select="$custodian_sequence[1]/cit:party/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($pointOfContact_sequence) > 0) and string-length($pointOfContact_sequence[1]/cit:party/cit:CI_Organisation/cit:name) > 0">
                    <xsl:value-of select="$pointOfContact_sequence[1]/cit:party/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($contact_sequence) > 0) and string-length($contact_sequence[1]/cit:party/cit:CI_Organisation/cit:name) > 0">
                     <xsl:value-of select="$contact_sequence[1]/cit:party/cit:CI_Organisation/cit:name"/>
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
            
            <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code[string-length(.) > 0]" mode="registryObject_key"/>
        
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
                
                
            <xsl:element name="{custom:getRegistryObjectTypeSubType(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue)[1]}">
    
                <xsl:attribute name="type" select="custom:getRegistryObjectTypeSubType(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue)[2]"/>
                        
                <xsl:if test="custom:getRegistryObjectTypeSubType(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue)[1] = 'collection'">
                    <xsl:if test="string-length(mdb:dateInfo/cit:CI_Date/cit:date[following-sibling::cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']) > 0">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="mdb:dateInfo/cit:CI_Date/cit:date[following-sibling::cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']"/>
                            </xsl:attribute>  
                        </xsl:if>
                </xsl:if>
                
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code[contains(following-sibling::mcc:codeSpace, 'ga-dataSetURI') and (string-length(.) > 0)]" mode="registryObject_identifier"/>
                <!-- ToDo - ensure that this will be to metadata landing page?  -->    
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code[contains(following-sibling::mcc:codeSpace, 'ga-dataSetURI') and (string-length(.) > 0)]" mode="registryObject_location"/>
                <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code" mode="registryObject_identifier_global"/>
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code[contains(following-sibling::mcc:codeSpace, 'ga-dataSetURI') and (string-length(.) > 0)]" mode="registryObject_relatedInfo_data_via_service"/>
                    
                <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                </xsl:apply-templates>
                
                <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                </xsl:apply-templates>
                    
                </xsl:element>
            </registryObject>

            <xsl:apply-templates></xsl:apply-templates>

            
    </xsl:template>
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="originatingSource"/>
        
        <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:title[string-length(.) > 0]" mode="registryObject_name"/>
        
        <xsl:for-each
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Individual/cit:name))) > 0] |
            mri:pointOfContact/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Individual/cit:name))) > 0]">
            <xsl:apply-templates select="." mode="registryObject_related_object"/>
        </xsl:for-each>
        
        <xsl:for-each
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[((string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name))) > 0)] |
            ancestor::mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[((string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name))) > 0)] |
            mri:pointOfContact/cit:CI_Responsibility[((string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name))) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility[((string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name))) > 0)]">
            <xsl:apply-templates select="." mode="registryObject_related_object"/>
        </xsl:for-each>
        
        <xsl:apply-templates
            select="mri:topicCategory/mri:MD_TopicCategoryCode"
            mode="registryObject_subject"/>
        
        <xsl:apply-templates
            select="mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
            select="mri:abstract"
            mode="registryObject_description_brief"/>
        
        <xsl:apply-templates select="mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial"/>
        <xsl:apply-templates select="mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_BoundingPolygon" mode="registryObject_coverage_spatial"/>
       
        <xsl:apply-templates
            select="mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
         
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'license']"
            mode="registryObject_rights_license"/>
       
       <xsl:apply-templates
           select="mri:resourceConstraints/mco:MD_LegalConstraints[count(mco:accessConstraints) > 0]"
           mode="registryObject_rights_access"/>
        
        
        <xsl:apply-templates select="ancestor::mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorTransferOptions" mode="registryObject_rights_access"/>
        
       <xsl:if test="custom:getRegistryObjectTypeSubType(ancestor::mdb:MD_Metadata/mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue)[1] = 'collection'">
            <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="originatingSource" select="$originatingSource"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
            
   </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
        <xsl:param name="originatingSource"/>
        <xsl:for-each
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Individual/cit:name))) > 0] |
            mri:pointOfContact/cit:CI_Responsibility[string-length(normalize-space(cit:party/cit:CI_Individual/cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility[string-length(normalize-space(cit:party/cit:CI_Individual/cit:name)) > 0]">
            <xsl:call-template name="partyPerson">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:call-template>
        </xsl:for-each>
        
        <xsl:for-each
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name))) > 0] |
            ancestor::mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[(string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name))) > 0] |
            mri:pointOfContact/cit:CI_Responsibility[string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility[string-length(normalize-space(cit:party/cit:CI_Organisation/cit:name)) > 0]">
            <xsl:call-template name="partyGroup">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    
    

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code" mode="registryObject_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
        </key>
    </xsl:template>

    <xsl:template match="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code" mode="registryObject_identifier_global">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <identifier type="global">
                <xsl:value-of select="."/>
            </identifier>
        </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="mcc:code" mode="registryObject_identifier">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <identifier>
                <xsl:attribute name="type" select="custom:getIdentifierType"/>
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_location">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                     <xsl:attribute name="target">
                        <xsl:text>landingPage</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    

    <!-- RegistryObject - Name Element  -->
    <xsl:template
        match="mri:citation/cit:CI_Citation/cit:title"
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
    <xsl:template match="cit:date" mode="registryObject_dates">
        <xsl:variable name="dateValue" select="normalize-space(cit:CI_Date/cit:date/gco:DateTime)"/>
        <xsl:variable name="dateCode"
            select="normalize-space(cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue)"/>
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
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="cit:CI_Responsibility" mode="registryObject_related_object">
        <xsl:variable name="role" select="cit:role/cit:CI_RoleCode/@codeListValue"/>
        <xsl:for-each select="cit:party">
             <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(*/cit:name),' ',''))"/>
                </key>
                <relation>
                    <xsl:attribute name="type" select="$role"/>
                </relation>
             </relatedObject>
        </xsl:for-each>
            
        <xsl:for-each select="cit:individual/cit:CI_Individual">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
                </key>
                <relation>
                    <xsl:attribute name="type" select="$role"/>
                </relation>
            </relatedObject>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mri:MD_TopicCategoryCode" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mri:keyword" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="mri:abstract" mode="registryObject_description_brief">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="brief">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
   <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gex:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial">
        
        <xsl:if test="string-length(normalize-space(gex:northBoundLatitude/gco:Decimal)) > 0"/>
        <xsl:if
             test="
                (string-length(normalize-space(gex:northBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gex:southBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gex:westBoundLongitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gex:eastBoundLongitude/gco:Decimal)) > 0)">
                 <xsl:variable name="spatialString">
                     <xsl:value-of
                         select="normalize-space(concat('northlimit=',gex:northBoundLatitude/gco:Decimal,'; southlimit=',gex:southBoundLatitude/gco:Decimal,'; westlimit=',gex:westBoundLongitude/gco:Decimal,'; eastLimit=',gex:eastBoundLongitude/gco:Decimal))"/>
                     
                     <xsl:if
                         test="
                         (string-length(normalize-space(gex:EX_VerticalExtent/gex:maximumValue/gco:Real)) > 0) and
                         (string-length(normalize-space(gex:EX_VerticalExtent/gex:minimumValue/gco:Real)) > 0)">
                         <xsl:value-of
                             select="normalize-space(concat('; uplimit=',gex:EX_VerticalExtent/gex:maximumValue/gco:Real,'; downlimit=',gex:EX_VerticalExtent/gex:minimumValue/gco:Real))"
                         />
                     </xsl:if>
                     <xsl:text>; projection=GDA94</xsl:text>
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

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gex:EX_TemporalExtent" mode="registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gex:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0) or
            (string-length(normalize-space(gex:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gex:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gex:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gex:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gex:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mcc:code" mode="registryObject_relatedInfo_data_via_service">
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
    
    
   <!-- RegistryObject - Rights License -->
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license">
        <xsl:value-of select="mco:otherConstraints"/>
    </xsl:template>
    
    <!-- RegistryObject - Rights Statement Access -->
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_access">
        
    </xsl:template>
    
    <xsl:template match="mrd:distributorTransferOptions" mode="registryObject_rights_access">
        <xsl:for-each select="mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue">
            <xsl:if test="contains(lower-case(.), 'download')">
                <rights>
                    <accessRights type="open"/>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    
    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="originatingSource"/>
        
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
       <xsl:variable name="citedResponsibleParty_sequence" select="cit:citedResponsibleParty/cit:CI_Responsibility" as="node()*"/>
       <xsl:message select="concat('Count citedResponsibleParty_sequence: ', count($citedResponsibleParty_sequence))"/>
       <xsl:message select="concat('Count distributing responsibilities: ', count(../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility))"/>
       <xsl:message select="concat('Count point of contact responsibilities: ', count( ../../mri:pointOfContact/cit:CI_Responsibility))"/>
        
       <xsl:variable name="principalInvestigator_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'principalInvestigator']"/>
        
        <xsl:variable name="author_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']"/>
        
        <xsl:variable name="contentexpert_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'contentexpert']"/>
        
        <xsl:variable name="coInvestigator_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coInvestigator']"/>
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']"/>  
        
        <xsl:variable name="owner_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'owner']"/>  
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']"/>
        
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
           <xsl:for-each select="$principalInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(cit:party/cit:CI_Individual/cit:name) = 0">
                       <xsl:choose>
                            <xsl:when test="string-length(cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name) > 0">
                               <xsl:value-of select="cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="string-length(cit:party/cit:CI_Organisation/cit:name) > 0">
                                    <xsl:value-of select="cit:party/cit:CI_Organisation/cit:name"/>
                                </xsl:if>
                            </xsl:otherwise>
                       </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="cit:party/cit:CI_Individual/cit:name"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
            
            <xsl:for-each select="$author_sequence">
                <xsl:choose>
                    <xsl:when test="string-length(cit:party/cit:CI_Individual/cit:name) = 0">
                        <xsl:choose>
                            <xsl:when test="string-length(cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name) > 0">
                                <xsl:value-of select="cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="string-length(cit:party/cit:CI_Organisation/cit:name) > 0">
                                    <xsl:value-of select="cit:party/cit:CI_Organisation/cit:name"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="cit:party/cit:CI_Individual/cit:name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$contentexpert_sequence">
                <xsl:choose>
                    <xsl:when test="string-length(cit:party/cit:CI_Individual/cit:name) = 0">
                        <xsl:choose>
                            <xsl:when test="string-length(cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name) > 0">
                                <xsl:value-of select="cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="string-length(cit:party/cit:CI_Organisation/cit:name) > 0">
                                    <xsl:value-of select="cit:party/cit:CI_Organisation/cit:name"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="cit:party/cit:CI_Individual/cit:name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$coInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(cit:party/cit:CI_Individual/cit:name) = 0">
                       <xsl:choose>
                           <xsl:when test="string-length(cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name) > 0">
                               <xsl:value-of select="cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name"/>
                           </xsl:when>
                           <xsl:otherwise>
                               <xsl:if test="string-length(cit:party/cit:CI_Organisation/cit:name) > 0">
                                   <xsl:value-of select="cit:party/cit:CI_Organisation/cit:name"/>
                               </xsl:if>
                           </xsl:otherwise>
                       </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="cit:party/cit:CI_Individual/cit:name"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
           
           <xsl:for-each select="$citedResponsibleParty_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(cit:party/cit:CI_Individual/cit:name) = 0">
                       <xsl:choose>
                           <xsl:when test="string-length(cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name) > 0">
                               <xsl:value-of select="cit:party/cit:CI_Organisation/cit:individual/CI_Individual/cit:name"/>
                           </xsl:when>
                           <xsl:otherwise>
                               <xsl:if test="string-length(cit:party/cit:CI_Organisation/cit:name) > 0">
                                   <xsl:value-of select="cit:party/cit:CI_Organisation/cit:name"/>
                               </xsl:if>
                           </xsl:otherwise>
                       </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="cit:party/cit:CI_Individual/cit:name"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
        
        <xsl:for-each select="$allContributorName_sequence">
            <xsl:message select="concat('Contributor name: ', .)"/>
        </xsl:for-each>
        
        <!-- We can only accept one DOI; howerver, first we will find all -->
        
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*" select="cit:identifier/mcc:MD_Identifier/mcc:code[contains(lower-case(.), 'doi')]"/>
        <xsl:variable name = "dataSetUri_sequence" as="xs:string*" select="cit:identifier/mcc:MD_Identifier/mcc:code[contains(following-sibling::mcc:codeSpace, 'ga-dataSetURI')]"/>
        <xsl:variable name = "otherId_sequence" as="xs:string*" select="cit:identifier/mcc:MD_Identifier/mcc:code[not(contains(following-sibling::mcc:codeSpace, 'ga-dataSetURI'))]"/>
        
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:when test="count($dataSetUri_sequence) and (string-length($dataSetUri_sequence[1]) > 0)">
                    <xsl:value-of select="$dataSetUri_sequence[1]"/>   
                </xsl:when>
                
                <xsl:when test="count($otherId_sequence) and (string-length($otherId_sequence[1]) > 0)">
                    <xsl:value-of select="$otherId_sequence[1]"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::mdb:MD_Metadata/mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
          
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <xsl:if test="string-length($identifierToUse) > 0">
                        <identifier>
                            <xsl:attribute name="type" select="custom:getIdentifierType($identifierToUse)"/>
                            <xsl:value-of select='$identifierToUse'/>
                        </identifier>
                    </xsl:if>
    
                    <title>
                        <xsl:value-of select="cit:title"/>
                    </title>
                    
                    <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                    
                    <xsl:for-each select="cit:date/cit:CI_Date">
                        <xsl:variable name="dateType">
                            <xsl:if test="count($CI_Date_sequence) > 0">
                                <xsl:variable name="codevalue" select="$CI_Date_sequence[1]/cit:dateType/cit:CI_DateTypeCode/@codeListValue"/>
                                <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                            </xsl:if>
                        </xsl:variable>
                        
                        <xsl:variable name="dateValue">
                            <xsl:if test="count($CI_Date_sequence)">
                                <xsl:if test="string-length($CI_Date_sequence[1]/cit:date/gco:DateTime) > 3">
                                    <xsl:value-of select="substring($CI_Date_sequence[1]/cit:date/gco:DateTime, 1, 4)"/>
                                </xsl:if>
                                <xsl:if test="string-length($CI_Date_sequence[1]/cit:date/gco:DateTime) > 3">
                                    <xsl:value-of select="substring($CI_Date_sequence[1]/cit:date/gco:DateTime, 1, 4)"/>
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
                             <xsl:when test="string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date/cit:date[following-sibling::cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']) > 3">
                                <date>
                                    <xsl:attribute name="type">
                                        <xsl:text>publicationDate</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="substring(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date/cit:date[following-sibling::cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication'], 1, 4)"/>
                                </date>
                            </xsl:when>
                           
                         </xsl:choose>
                        <c.
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisherOrganisationName" as="xs:string">
                        <xsl:variable name="publisherOrganisationName_sequence" as="xs:string*">
                            <xsl:for-each select="$publisher_sequence">
                                <xsl:if test="string-length(cit:party/cit:CI_Organisation/cit:name) > 0">
                                    <xsl:copy-of select="cit:party/cit:CI_Organisation/cit:name"/>
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
        
        <xsl:for-each select="cit:party">
          
            <registryObject group="{$global_group}">
    
              <key>
                  <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:CI_Individual/cit:name),' ',''))"/>
              </key>
             
              <originatingSource>
                  <xsl:value-of select="$originatingSource"/>
              </originatingSource> 
               
                <party type="person">
                    
                    <xsl:apply-templates select="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    
                    <name type="primary">
                         <namePart>
                             <xsl:value-of select="normalize-space(cit:CI_Individual/cit:name)"/>
                         </namePart>
                    </name>
                    
                    <xsl:apply-templates select="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address"/>
                    <xsl:apply-templates select="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone"/>
        
                </party>
            </registryObject>
        </xsl:for-each>
    </xsl:template>
        
    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="partyGroup">
        <xsl:param name="originatingSource"/>
        
        <xsl:for-each select="cit:party">
        
            <registryObject group="{$global_group}">
                
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:CI_Organisation/cit:name),' ',''))"/>
                </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="group">
                    <xsl:apply-templates select="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:CI_Organisation/cit:name)"/>
                        </namePart>
                    </name>
                    
                    <xsl:apply-templates select="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address"/>
                    <xsl:apply-templates select="cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone"/>
                     
                    <xsl:if test="(count(cit:CI_Organisation/cit:individual) > 0) and (string-length(cit:CI_Organisation/cit:individual/CI_Individual/cit:name) > 0)">
                        <!-- Organisation has an individual -->
                        <relatedObject>
                            <key>
                                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:CI_Organisation/cit:individual/CI_Individual/cit:name),' ',''))"/>
                            </key>
                            <relation type="hasMember"/>
                        </relatedObject>
                    </xsl:if>
                    
                </party>
            </registryObject>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource">
        <xsl:if test="string-length(cit:linkage) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="custom:getIdentifierType(cit:linkage)"/>       
                </xsl:attribute>
                <xsl:value-of select="cit:linkage"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
                     
    <xsl:template match="cit:CI_Address">
       <location>
        <address>
            <physical type="streetAddress">
               
                <xsl:for-each select="cit:deliveryPoint">
                     <addressPart type="addressLine">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                </xsl:for-each>
                
                 <xsl:for-each select="cit:city">
                      <addressPart type="suburbOrPlaceLocality">
                          <xsl:value-of select="normalize-space(.)"/>
                      </addressPart>
                </xsl:for-each>
                
                 <xsl:for-each select="cit:administrativeArea">
                     <addressPart type="stateOrTerritory">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                 </xsl:for-each>
                    
                 <xsl:for-each select="cit:postalCode">
                     <addressPart type="postCode">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                 </xsl:for-each>
                 
                  <xsl:for-each select="cit:country">
                     <addressPart type="country">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                </xsl:for-each>
            </physical>
            <xsl:for-each select="cit:electronicMailAddress[string-length(.) > 0]">
                 <electronic type="email">
                    <value>
                        <xsl:value-of select="normalize-space(.)"/>
                    </value>
                 </electronic>
            </xsl:for-each>
        </address>
    </location>
</xsl:template>


    <xsl:template match="cit:CI_Telephone">
        <xsl:for-each select="cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:choose>
                                <xsl:when test="following-sibling::cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'facsimile'">
                                    <xsl:attribute name="type">
                                        <xsl:text>faxNumber</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                     <xsl:attribute name="type">
                                        <xsl:text>telephoneNumber</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="custom:getIdentifierType" as="xs:string">
        <xsl:param name="identifier"/>
            <xsl:choose>
                <xsl:when test="contains(lower-case($identifier), 'orcid')">
                    <xsl:text>orcid</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($identifier), 'purl')">
                    <xsl:text>purl</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($identifier), 'doi')">
                    <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($identifier), 'scopus')">
                    <xsl:text>scopus</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function>
    
   <xsl:function name="custom:getRegistryObjectTypeSubType" as="xs:string*">
        <xsl:param name="scopeCode"/>
        <xsl:choose>
            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'service'">
                <xsl:text>service</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="substring(lower-case($scopeCode), 0, 9) = 'software'">
                <xsl:text>collection</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="substring(lower-case($scopeCode), 0, 21) = 'nongeographicdataset'">
                <xsl:text>collection</xsl:text>
                <xsl:text>publication</xsl:text>
            </xsl:when>
            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'dataset'">
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>