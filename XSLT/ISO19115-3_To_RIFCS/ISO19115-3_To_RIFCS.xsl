<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
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
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gml="http://www.opengis.net/gml/3.2" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:gaFunc="http://gafunc.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="csw gaFunc oai lan mrc xlink srv mrd geonet mas mri mcc mrl xs mco mrs xsi mda msr mdb mds mdq cat mdt mac cit mex gco gcx mmi gmx gex mpc gml custom">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements='*'/>
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="false()" as="xs:boolean"/>
    
    <!-- Override the following by constructing a stylesheet with the params below populated appropriately, then import this stylesheet.  Run the stylesheet with the params, on your source XML -->
    <xsl:param name="global_PID_Codespace" select="''"/>
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_path" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    <xsl:param name="global_spatialProjection" select="''"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    
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
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'originator'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'originator'] |
               mdb:contact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'originator']"/>
           
           <xsl:variable name="resourceProvider_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider'] |
               mdb:contact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'resourceProvider']"/>
           
           <xsl:variable name="owner_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'owner'] |
               mdb:contact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'owner']"/>
           
            <xsl:variable name="custodian_sequence" as="node()*" select="
               mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'custodian'] |
               mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'custodian'] |
               mdb:contact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'custodian']"/>
          
           <xsl:variable name="contact_sequence" as="node()*" select="
              mdb:contact/cit:CI_Responsibility/cit:party"/>
           
            <xsl:choose>
                <xsl:when test="(count($originator_sequence) > 0) and string-length($originator_sequence[1]/cit:CI_Organisation/cit:name) > 0">
                     <xsl:value-of select="$originator_sequence[1]/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($resourceProvider_sequence) > 0) and string-length($resourceProvider_sequence[1]/cit:CI_Organisation/cit:name) > 0">
                    <xsl:value-of select="$resourceProvider_sequence[1]/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($owner_sequence) > 0) and string-length($owner_sequence[1]/cit:CI_Organisation/cit:name) > 0">
                     <xsl:value-of select="$owner_sequence[1]/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($custodian_sequence) > 0) and string-length($custodian_sequence[1]/cit:CI_Organisation/cit:name) > 0">
                    <xsl:value-of select="$custodian_sequence[1]/cit:CI_Organisation/cit:name"/>
                </xsl:when>
                <xsl:when test="(count($contact_sequence) > 0) and string-length($contact_sequence[1]/cit:CI_Organisation/cit:name) > 0">
                     <xsl:value-of select="$contact_sequence[1]/cit:CI_Organisation/cit:name"/>
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
            
            <xsl:if test="$global_debugExceptions">
                <xsl:choose>
                    <xsl:when test="count(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue) > 1">
                        <xsl:message select="'Exception: more than one value in mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue'"/>
                    </xsl:when>
                    <xsl:when test="count(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue) = 0">
                        <xsl:message select="'Exception: no value in mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            
            <xsl:variable name="registryObjectTypeSubType_sequence" as="xs:string*">
                <xsl:variable name="scopeCode" select="mdb:metadataScope[1]/mdb:MD_MetadataScope[1]/mdb:resourceScope[1]/mcc:MD_ScopeCode[1]/@codeListValue[1]"/>
                <xsl:choose>
                    <xsl:when test="string-length($scopeCode) > 0">
                        <xsl:choose>
                            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'service'">
                                <xsl:text>service</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="string-length(mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType) > 0">
                                        <xsl:value-of select="normalize-space(mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>software</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
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
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>collection</xsl:text>
                        <xsl:text>dataset</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
                
            <xsl:element name="{$registryObjectTypeSubType_sequence[1]}">
    
                <xsl:attribute name="type" select="$registryObjectTypeSubType_sequence[2]"/>
                        
                <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                    <xsl:if test="string-length(mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date) > 0">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date"/>
                            </xsl:attribute>  
                        </xsl:if>
                </xsl:if>
                
                <xsl:choose>
                    <xsl:when test="count(mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:name), mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code)]/cit:linkage[contains(., 'doi')]) > 0">
                        <xsl:apply-templates 
                        select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:name), mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code)]/cit:linkage[contains(., 'doi')][1]"
                        mode="registryObject_identifier_doi"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates 
                            select="mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:description), 'dataset doi') and contains(lower-case(cit:name), 'digital object identifier')]/cit:linkage[contains(., 'doi')][1]"
                            mode="registryObject_identifier_doi"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                
                <xsl:apply-templates select="mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[not(contains(lower-case(mcc:codeSpace), 'dataseturi'))]/mcc:code[not(contains(lower-case(.), 'doi')) and not(contains(lower-case(.), 'product')) and not(contains(lower-case(.), 'resource'))]" mode="registryObject_identifier"/>
                   
                <xsl:if test="$registryObjectTypeSubType_sequence[1] != 'service'">
                    <xsl:apply-templates select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[not(contains(lower-case(cit:name), mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code) and contains(cit:linkage, 'doi'))]" 
                        mode="registryObject_relatedInfo"/>
                </xsl:if>
                
                <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code"
                    mode="registryObject_identifier_global"/>
                
                <xsl:choose>
                    <xsl:when test="string-length(mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), $global_PID_Codespace)]/mcc:code) > 0">
                        <xsl:apply-templates select="mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), $global_PID_Codespace)]/mcc:code"
                            mode="registryObject_identifier_PID"/>
                        
                        <xsl:apply-templates select="mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), $global_PID_Codespace)]/mcc:code"
                            mode="registryObject_location_PID"/>
                     </xsl:when>    
                    <xsl:when test="string-length(mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage) > 0">
                        <xsl:apply-templates select="mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage" mode="registryObject_identifier_metadata_URL"/>
                        <xsl:apply-templates select="mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage" mode="registryObject_location_metadata_URL"/>
                        
                        <!--xsl:apply-templates select="mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage[contains(., 'internal.ecat')]" mode="registryObject_identifier_metadata_URL_replace"/-->
                    </xsl:when>
                         
                    <xsl:otherwise>
                        <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code"
                                mode="registryObject_location_uuid"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates
                    select="mdb:resourceLineage/mrl:LI_Lineage/mrl:statement[string-length(.) > 0]"
                    mode="registryObject_description_lineage"/>
                
                <xsl:apply-templates
                    select="mdb:identificationInfo/mri:MD_DataIdentification/mri:credit[string-length(.) > 0]"
                    mode="registryObject_description_notes"/>
                
                <xsl:apply-templates
                    select="mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose[string-length(.) > 0]"
                    mode="registryObject_description_notes"/>
                  
                <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                    <xsl:with-param name="originatingSource" select="$originatingSource"/>
                    <xsl:with-param name="registryObjectTypeSubType_sequence" select="$registryObjectTypeSubType_sequence"/>
                </xsl:apply-templates>
            </xsl:element>
                
        </registryObject>
        
        <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
            <xsl:with-param name="originatingSource" select="$originatingSource"/>
        </xsl:apply-templates>

    </xsl:template>
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="originatingSource"/>
        <xsl:param name="registryObjectTypeSubType_sequence"/>
        
        <xsl:apply-templates select="srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/cit:CI_OnlineResource/cit:linkage" mode="registryObject_identifier_service_URL"/>
        
        <xsl:apply-templates select="srv:operatesOn[string-length(@uuidref) > 0]" mode="registryObject_relatedObject_isSupportedBy"/>
        
        <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:title[string-length(.) > 0]" mode="registryObject_name"/>
        
        
         <xsl:for-each-group
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Individual/cit:name))) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Individual/cit:name))) > 0]" group-by="cit:CI_Individual/cit:name">
            <xsl:apply-templates select="." mode="registryObject_related_object"/>
        </xsl:for-each-group>
        
        <xsl:for-each-group
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Organisation/cit:name)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Organisation/cit:name)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Organisation/cit:name)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Organisation/cit:name)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party[(string-length(normalize-space(cit:CI_Organisation/cit:name)) > 0)]" group-by="cit:CI_Organisation/cit:name">
            <xsl:apply-templates select="." mode="registryObject_related_object"/>
        </xsl:for-each-group>
        
        <xsl:apply-templates
            select="mri:topicCategory/mri:MD_TopicCategoryCode[string-length(.) > 0]"
            mode="registryObject_subject"/>
        
        <xsl:apply-templates
            select="mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword[string-length(.) > 0]"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
             select="mri:abstract[string-length(.) > 0]"
            mode="registryObject_description_brief"/>
        
        <xsl:apply-templates select="mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial"/>
        <xsl:apply-templates select="mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_BoundingPolygon" mode="registryObject_coverage_spatial"/>
       
        <xsl:apply-templates
            select="mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
         
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(count(mco:reference/cit:CI_Citation) = 0) and (mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'license') and (string-length(mco:otherConstraints) > 0)]"
            mode="registryObject_rights_license_otherConstraint"/>
       
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(string-length(mco:reference/cit:CI_Citation/cit:title) > 0) and (mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'license')]"
            mode="registryObject_rights_license_citation"/>
        
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[count(mco:useConstraints) > 0]"
           mode="registryObject_rights_access"/>
        
        
        <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:date/cit:CI_Date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
                <xsl:with-param name="registryObjectTypeSubType_sequence" select="$registryObjectTypeSubType_sequence"/>
            </xsl:apply-templates>
        </xsl:if>
            
   </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
        <xsl:param name="originatingSource"/>
  
        <xsl:for-each
            select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0] |
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Individual[string-length(normalize-space(cit:name)) > 0]">
            <xsl:apply-templates select="." mode="party_person">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:for-each>
    
        <xsl:for-each
            select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]  |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]">
        <xsl:apply-templates select="." mode="party_group">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="mcc:code" mode="registryObject_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
        </key>
    </xsl:template>
    
  <xsl:template match="cit:linkage" mode="registryObject_identifier_doi">
        <identifier type="doi">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_identifier_global">
        <identifier type="global">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <!-- RegistryObject - Identifier Element  -->
    
    <xsl:template match="cit:linkage" mode="registryObject_identifier_service_URL">
        <identifier type="uri">
            <xsl:choose>
                <xsl:when test="contains(.,'?')">
                    <xsl:value-of select="substring-before(., '?')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>    
                </xsl:otherwise>
            </xsl:choose>
        </identifier>
    </xsl:template>
    
    <xsl:template match="cit:linkage" mode="registryObject_identifier_metadata_URL">
        <identifier type="uri">
            <xsl:value-of select="."/>    
        </identifier>
    </xsl:template>
    
    <!--xsl:template match="cit:linkage" mode="registryObject_identifier_metadata_URL_replace">
        <identifier type="uri">
            <xsl:value-of select="replace(., 'internal.ecat', 'ecat')"/>    
        </identifier>
    </xsl:template-->
    
    <xsl:template match="mcc:code" mode="registryObject_identifier_PID">
        <identifier type = "purl">
                <xsl:value-of select="concat('http://', $global_baseURI_PID, $global_path_PID, .)"/>
        </identifier>
    </xsl:template>
   
    <xsl:template match="mcc:code" mode="registryObject_identifier">
        <identifier>
            <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="string-length(following-sibling::mcc:codeSpace) > 0">
                            <xsl:value-of select="following-sibling::mcc:codeSpace"/>
                        </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="custom:getIdentifierType(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="cit:linkage" mode="registryObject_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_location_PID">
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
                        <xsl:value-of select="concat('http://', $global_baseURI_PID, $global_path_PID, .)"/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    <xsl:template match="cit:linkage" mode="registryObject_location_metadata_URL">
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
    
    <xsl:template match="mcc:code" mode="registryObject_location_uuid">
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
                        <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    

    <!-- RegistryObject - Name Element  -->
    <xsl:template match="mri:citation/cit:CI_Citation/cit:title" mode="registryObject_name">
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
    <xsl:template match="cit:CI_Date" mode="registryObject_dates">
        
        <xsl:variable name="dateValue_sequence" select="normalize-space(cit:date/gco:DateTime)" as="xs:string*"/>
        <xsl:variable name="dateCode_sequence" select="normalize-space(cit:dateType/cit:CI_DateTypeCode/@codeListValue)" as="xs:string*"/>
        
        <xsl:if test="$global_debugExceptions">
            <xsl:if test="count($dateValue_sequence) = 0">
                <xsl:message select="'Exception - No value in cit:date/gco:DateTime'"/>
            </xsl:if>
            <xsl:if test="count($dateValue_sequence) > 1">
                <xsl:message select="'Exception - More than one value in cit:date/gco:DateTime'"/>
            </xsl:if>
            <xsl:if test="count($dateCode_sequence) = 0">
                <xsl:message select="'Exception - No value in cit:dateType/cit:CI_DateTypeCode/@codeListValue'"/>
            </xsl:if>
            <xsl:if test="count($dateCode_sequence) > 1">
                <xsl:message select="'Exception - More than one value in cit:dateType/cit:CI_DateTypeCode/@codeListValue'"/>
            </xsl:if>
        </xsl:if>
        
        <xsl:if test="(count($dateValue_sequence) > 0) and (string-length($dateValue_sequence[1]) > 0)">
            <dates>
                
                    <xsl:if test="count($dateCode_sequence) > 0 and (string-length($dateCode_sequence[1]) > 0)">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'creation')">
                                    <xsl:text>created</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'publication')">
                                    <xsl:text>issued</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'revision')">
                                    <xsl:text>modified</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>dateFrom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="dateFormat">
                        <xsl:text>W3CDTF</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="translate($dateValue_sequence[1], '-', '')"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="cit:party" mode="registryObject_related_object">
        <xsl:variable name="role" select="preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue"/>
        <xsl:if test="$global_debug">
            <xsl:message select="concat('role : ', $role)"/>
        </xsl:if>
              <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
                </key>
                    <xsl:for-each select="distinct-values(current-group()/preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue)">
                        <relation>
                            <xsl:attribute name="type" select="."/>
                        </relation>
                     </xsl:for-each>
             </relatedObject>
            
            <xsl:for-each select="current-group()/*/cit:individual/cit:CI_Individual">
                <xsl:if test="string-length(normalize-space(cit:name)) > 0">
                    <relatedObject>
                        <key>
                            <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
                        </key>
                        <relation>
                            <xsl:attribute name="type" select="$role"/>
                        </relation>
                    </relatedObject>
                </xsl:if>
            </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mri:MD_TopicCategoryCode" mode="registryObject_subject">
        <subject type="local">
            <xsl:value-of select="."></xsl:value-of>
        </subject>
    </xsl:template>
    
    

    <xsl:template match="mri:keyword" mode="registryObject_subject">
        <subject>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(following-sibling::mri:thesaurusName/cit:CI_Citation/cit:title, 'ANZSRC')">
                        <xsl:text>anzsrc-for</xsl:text>    
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="normalize-space(.)"></xsl:value-of>
        </subject>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="mri:abstract" mode="registryObject_description_brief">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="brief">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element - lineage -->
    <xsl:template match="mrl:statement" mode="registryObject_description_lineage">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="lineage">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mri:credit" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:text>&lt;b&gt;Credit&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mri:purpose" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:text>&lt;b&gt;Purpose&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
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
                     <xsl:if test="string-length($global_spatialProjection) > 0">
                        <xsl:value-of select="concat('; projection=', $global_spatialProjection)"/>
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

    <xsl:template match="srv:operatesOn" mode="registryObject_relatedObject_isSupportedBy">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', normalize-space(@uuidref))"/>
                </key>
                <relation type="isSupportedBy"/>
            </relatedObject>
    </xsl:template>
    
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="cit:CI_OnlineResource" mode="registryObject_relatedInfo">         
        
        <xsl:choose>
            <xsl:when test="contains(cit:protocol, 'OGC:') or contains(lower-case(cit:linkage), 'thredds') or contains(lower-case(cit:linkage), '.nc') or contains(lower-case(cit:linkage), '?')">
                <xsl:apply-templates select="." mode="relatedInfo_service"/>
            </xsl:when>
            <xsl:when test="not(contains(lower-case(cit:description), 'point-of-truth'))">
                <xsl:apply-templates select="." mode="relatedInfo_relatedInformation"/>
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource" mode="relatedInfo_service">       
        
        <xsl:variable name="identifierValue" select="normalize-space(cit:linkage)"/>
        
        <relatedInfo>
            <xsl:attribute name="type" select="'service'"/>   
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>supports</xsl:text>
                </xsl:attribute>
                <xsl:if test="(contains($identifierValue, '?')) or (contains($identifierValue, '.nc'))">
                    <url>
                        <xsl:value-of select="$identifierValue"/>
                    </url>
                </xsl:if>
            </relation>
            
            <xsl:apply-templates select="." mode="relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource" mode="relatedInfo_relatedInformation">       
        
        <relatedInfo>
            <xsl:attribute name="type" select="'relatedInformation'"/>   
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>hasAssociationWith</xsl:text>
                </xsl:attribute>
            </relation>
            
            <xsl:apply-templates select="." mode="relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
    
    <xsl:template match="cit:CI_OnlineResource" mode="relatedInfo_all">     
        
        <xsl:variable name="identifierValue" select="normalize-space(cit:linkage)"/>
        
        <identifier>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($identifierValue), 'doi')">
                        <xsl:text>doi</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>url</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains($identifierValue, '?')">
                    <xsl:value-of select="substring-before(., '?')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$identifierValue"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </identifier>
        
        <xsl:choose>
            <!-- Use description as title if we have it... -->
            <xsl:when test="string-length(normalize-space(cit:description)) > 0">
                <title>
                    <xsl:value-of select="normalize-space(cit:description)"/>
                    
                    <!-- ...and then name in brackets following -->
                    <xsl:if
                        test="string-length(normalize-space(cit:name)) > 0">
                        <xsl:value-of select="concat(' (', cit:name, ')')"/>
                    </xsl:if>
                </title>
            </xsl:when>
            <!-- No description, so use name as title if we have it -->
            <xsl:otherwise>
                <xsl:if
                    test="string-length(normalize-space(cit:name)) > 0">
                    <title>
                        <xsl:value-of select="concat('(', cit:name, ')')"/>
                    </title>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_otherConstraint">
        
        <xsl:variable name="licenceText" select="mco:otherConstraints"/>
        <xsl:call-template name="populateLicence">
            <xsl:with-param name="licenceText" select="$licenceText"/>
        </xsl:call-template>
     </xsl:template>
    
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_citation">
        
        <xsl:variable name="licenceText" select="mco:reference/cit:CI_Citation/cit:title"/>
        <xsl:call-template name="populateLicence">
            <xsl:with-param name="licenceText" select="$licenceText"/>
        </xsl:call-template>
        
    </xsl:template>
    
   <!-- RegistryObject - Rights License -->
    <xsl:template name="populateLicence">
        <xsl:param name="licenceText"/>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('count $licenseCodelist : ', count($licenseCodelist))"/>
        </xsl:if>
        
                    
                    <xsl:variable name="inputTransformed" select="normalize-space(replace(replace(replace($licenceText, 'icence', 'icense', 'i'), '[\d.]+', ''), '-', ''))"/>
                    <xsl:variable name="codeDefinition_sequence" select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition[normalize-space(replace(replace(gml:name, '\{n\}', ' '), '-', '')) = $inputTransformed]" as="node()*"/>
                    
                    
                     <xsl:if test="$global_debug">
                         <xsl:message select="concat('count $codeDefinition_sequence : ', count($codeDefinition_sequence))"/>
                     </xsl:if>
                     
                    <xsl:choose>
                        <xsl:when test="count($codeDefinition_sequence) > 0">
                             <xsl:for-each select="$codeDefinition_sequence">
                                 <xsl:variable name="codeDefinition" select="." as="node()"/>
                                  <xsl:variable name="licenceVersion" as="xs:string*">
                                     <xsl:analyze-string select="normalize-space($licenceText)"
                                         regex="[\d.]+">
                                         <xsl:matching-substring>
                                             <xsl:value-of select="regex-group(0)"/>
                                         </xsl:matching-substring>
                                     </xsl:analyze-string>
                                  </xsl:variable>
                                 
                                 <xsl:variable name="licenceURI">
                                      <xsl:choose>
                                          <xsl:when test="(number($licenceVersion) > 3) and contains(gml:remarks, '/au')">
                                                  <xsl:value-of select="substring-before(replace($codeDefinition/gml:remarks, '\{n\}', $licenceVersion), '/au')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="replace($codeDefinition/gml:remarks, '\{n\}', $licenceVersion)"/>
                                            </xsl:otherwise>
                                      </xsl:choose>
                                  </xsl:variable>
                     
                                  <xsl:if test="$global_debug">
                                     <xsl:message select="concat('licenceURI : ', $licenceURI)"/>
                                  </xsl:if>
                                  
                                 <xsl:variable name="type" select="gml:identifier"/>
                                 
                                 <rights>
                                     <licence>
                                         
                                         <xsl:if test="string-length($licenceURI) and count($licenceVersion) > 0">
                                              <xsl:attribute name="rightsUri">
                                                  <xsl:value-of select="$licenceURI"/>
                                              </xsl:attribute>
                                         </xsl:if>
                                         
                                         <xsl:if test="string-length($type) > 0">
                                              <xsl:attribute name="type">
                                                  <xsl:value-of select="$type"/>
                                              </xsl:attribute>
                                         </xsl:if>
                                         
                                         <xsl:value-of select="$licenceText"/>
                                     </licence>
                                  </rights>
                                 
                                 <xsl:call-template name="populateAccessRights">
                                     <xsl:with-param name="licenceType" select="$type"/>
                                 </xsl:call-template>
                                 
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <rights>
                                <licence>
                                    <xsl:value-of select="$licenceText"/>
                                </licence>
                            </rights>
                            
                            <xsl:call-template name="populateAccessRights"/> <!-- with no param -->
                            
                        </xsl:otherwise>
                    </xsl:choose>
     </xsl:template>
    
    <xsl:template name="populateAccessRights">
        <xsl:param name="licenceType"/>
        <rights>
            <accessRights>
                <xsl:choose>
                    <xsl:when test="lower-case($licenceType) = 'cc-by'">
                        <xsl:attribute name="type">
                            <xsl:text>open</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:text>conditional</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
            </accessRights>
        </rights>
    </xsl:template>
    
    
    <!-- RegistryObject - Rights Statement Access -->
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_access">
    <!-- todo -->
    </xsl:template>
    
    <xsl:template match="mrd:MD_DigitalTransferOptions" mode="registryObject_rights_access">
        <rights>
            <accessRights type="open"/>
        </rights>
    </xsl:template>
    
    
    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="originatingSource"/>
        <xsl:param name="registryObjectTypeSubType_sequence"/>
        
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
       <xsl:variable name="allContributorParty_sequence" as="node()*" select="cit:citedResponsibleParty/cit:CI_Responsibility/cit:party "/>  
        
       <xsl:variable name="allContributorName_sequence" as="xs:string*">
           <xsl:for-each select="$allContributorParty_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(cit:CI_Individual/cit:name) = 0">
                       <xsl:choose>
                           <xsl:when test="count(cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name) > 0">
                               <xsl:for-each select="cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name">
                                   <xsl:value-of select="."/>
                               </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="string-length(cit:CI_Organisation/cit:name) > 0">
                                    <xsl:value-of select="cit:CI_Organisation/cit:name"/>
                                </xsl:if>
                            </xsl:otherwise>
                       </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="cit:CI_Individual/cit:name"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
            
        <xsl:if test="$global_debug">
            <xsl:for-each select="$allContributorName_sequence">
                <xsl:message select="concat('Contributor name: ', .)"/>
            </xsl:for-each>
        </xsl:if>
        
  
        
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <identifier>
                        <xsl:choose>
                                <xsl:when 
                                    test="count(ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:name), mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code)]/cit:linkage[contains(., 'doi')]) > 0">
                                    <xsl:attribute name="type" select="'doi'"/>
                                    <xsl:value-of select="
                                        ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:name), mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code)]/cit:linkage[contains(., 'doi')][1]"/>
                                </xsl:when>
                                <xsl:when 
                                    test="count(ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(cit:description, 'Dataset DOI') and contains(cit:name, 'Digital Object Identifier')]/cit:linkage[contains(., 'doi')]) > 0">
                                    <xsl:attribute name="type" select="'doi'"/>
                                    <xsl:value-of select="
                                        ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[contains(lower-case(cit:description), 'dataset doi') and contains(lower-case(cit:name), 'digital object identifier')]/cit:linkage[contains(., 'doi')][1]"/>
                                </xsl:when>
                                <xsl:when 
                                    test="count(ancestor::mdb:MD_Metadata/mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'ecatid')]/mcc:code) and (string-length(ancestor::mdb:MD_Metadata/mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'ecatid')][1]/mcc:code[1]) > 0)">
                                    <xsl:attribute name="type" select="'uri'"/>
                                    <xsl:value-of select="concat('http://', $global_baseURI_PID, $global_path_PID, ancestor::mdb:MD_Metadata/mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'ecatid')][1]//mcc:code[1])"/>   
                                </xsl:when>
                                <xsl:when 
                                    test="count(cit:identifier[not(contains(mcc:MD_Identifier/mcc:codeSpace, 'ga-dataSetURI'))]/mcc:MD_Identifier/mcc:code) and (string-length(cit:identifier[not(contains(mcc:MD_Identifier/mcc:codeSpace, 'ga-dataSetURI'))][1]/mcc:MD_Identifier/mcc:code[1]) > 0)">
                                    <xsl:attribute name="type" select="'uri'"/>
                                    <xsl:value-of select="cit:identifier[not(contains(mcc:MD_Identifier/mcc:codeSpace, 'ga-dataSetURI'))][1]/mcc:MD_Identifier/mcc:code[1]"/>   
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="type" select="'uri'"/>
                                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::mdb:MD_Metadata/mdb:metadataIdentifier[1]/mcc:MD_Identifier[1]/mcc:code[1])"/>
                                </xsl:otherwise>
                        </xsl:choose>
                    </identifier>
             
                    <title>
                        <xsl:value-of select="cit:title"/>
                    </title>
                    
                    <xsl:if test="$global_debugExceptions">
                        <xsl:choose>
                            <xsl:when test="count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 1">
                                <xsl:message select="'Exception: more than one publication date in citation block'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    
                   <date>
                        <xsl:attribute name="type">
                            <xsl:text>publicationDate</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 0) and
                                      (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 0) and
                                    (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 0) and
                                    (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            </xsl:choose>
                    </date>
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisher_sequence" as="node()*" select="
                        cit:citedResponsibleParty/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'] |
                        ancestor::mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party[preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']"/>  
                    
                    <xsl:variable name="publisherOrganisationName" as="xs:string">
                        <xsl:variable name="publisherOrganisationName_sequence" as="xs:string*">
                            <xsl:for-each select="$publisher_sequence">
                                <xsl:if test="string-length(cit:CI_Organisation/cit:name) > 0">
                                    <xsl:copy-of select="cit:CI_Organisation/cit:name"/>
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
                    
                    <xsl:if test="$global_debug">
                        <xsl:message select="concat('Publisher name: ', $publisherOrganisationName)"/>
                    </xsl:if>
                    
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

    <xsl:template match="cit:CI_Individual" mode="party_person">
        <xsl:param name="originatingSource"/>
        
        <registryObject group="{$global_group}">
            
            <key>
                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
            
            <party type="person">
                <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(cit:name)"/>
                    </namePart>
                </name>
                
                <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
                <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/>
            </party>
        </registryObject>
    </xsl:template>
        
    <xsl:template match="cit:CI_Organisation" mode="party_group">
            <xsl:param name="originatingSource"/>
            
           <registryObject group="{$global_group}">
            
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
               </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="group">
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:name)"/>
                        </namePart>
                    </name>
                    
                    <xsl:choose>
                        <xsl:when test="(count(cit:individual/cit:CI_Individual) > 0)"> 
                            <!--  individual position name, so relate this individual to this organisation... -->
                            <xsl:for-each select="cit:individual/cit:CI_Individual">
                                <xsl:if test="(string-length(cit:name) > 0)">
                                  <relatedObject>
                                      <key>
                                          <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
                                      </key>
                                      <relation type="hasMember"/>
                                  </relatedObject>
                                </xsl:if>  
                             </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--  no individual position name, so use this address for this organisation -->
                            <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
                            <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/>
                        </xsl:otherwise>
                   </xsl:choose>
                    
                </party>
        </registryObject>
        <!--xsl:if test="(count(cit:individual/cit:CI_Individual) > 0) and (string-length(cit:individual/cit:CI_Individual/cit:positionName) > 0)"> 
            <xsl:apply-templates select="." mode="party_position">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:if-->
     </xsl:template>     
     
     <!--xsl:template match="cit:CI_Organisation" mode="party_position">
            <xsl:param name="originatingSource"/>
            
           <registryObject group="{$global_group}">
            
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:individual/cit:CI_Individual/cit:positionName),' ',''))"/>
               </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="person">
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:individual/cit:CI_Individual/cit:positionName)"/>
                        </namePart>
                    </name>
                    
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone"/>
                    
                </party>
        </registryObject>
     </xsl:template-->
    
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
        <xsl:for-each select=".[cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'facsimile']/cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:attribute name="type">
                                <xsl:text>faxNumber</xsl:text>
                            </xsl:attribute>
                           <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
        
        <xsl:for-each select=".[cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'voice']/cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:attribute name="type">
                                <xsl:text>telephoneNumber</xsl:text>
                            </xsl:attribute>
                           <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
   
    
</xsl:stylesheet>
