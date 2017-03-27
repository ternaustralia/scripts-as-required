<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"     
    xmlns:todo="http://yettodo" 
    xmlns:local="http://local.to.here"
    xmlns:dataset="http://atira.dk/schemas/pure4/wsdl/template/dataset/current" 
    xmlns:core="http://atira.dk/schemas/pure4/model/core/current" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:organisation-template="http://atira.dk/schemas/pure4/model/template/abstractorganisation/current"
    xmlns:externalperson-template="http://atira.dk/schemas/pure4/model/template/abstractexternalperson/current" 
    xmlns:person-template="http://atira.dk/schemas/pure4/model/template/abstractperson/current"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="todo local dataset core xsi xs fn organisation-template person-template xsl">
    
    <xsl:import href="CustomFunctions.xsl"/> 
    
    <xsl:param name="global_originatingSource" select="'University of Western Australia'"/>
    <xsl:param name="global_baseURI" select="'research-repository.uwa.edu.au'"/>
    <xsl:param name="global_group" select="'University of Western Australia (Research Repository)'"/>
    <xsl:param name="global_publisherName" select="'University of Western Australia'"/>
    

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <!-- registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd"-->
          
            <xsl:apply-templates select="//core:result/core:content"/>
            
        <!-- /registryObjects-->
    </xsl:template>
   
    <xsl:template match="core:content">
        <!-- xsl:message select="concat('name(.): ', name(.))"/-->
        
        <!-- include dataset for now -->
        
        <xsl:if test="contains(core:type, 'dk.atira.pure.modules.datasets.external.model.dataset.DataSet')">
                <xsl:apply-templates select="." mode="collection">
                    <xsl:with-param name="type" select="'dataset'"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="party"/>
        </xsl:if>
    </xsl:template>
    
<xsl:template match="core:content" mode="collection">
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="class" select="'collection'"/>
        
        <!-- xsl:message select="concat('mapped type: ', $type)"/-->
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="concat(normalize-space(core:family), ':', normalize-space(@uuid))"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type" select="$type"/>
             
                <xsl:apply-templates select="core:modified[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="core:created[string-length(.) > 0]" mode="collection_date_created"/>
                
                <xsl:apply-templates select="@uuid[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="*:doi/core:doi[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="*:doi/core:doi[string-length(.) > 0]" mode="collection_location"/>
                
                <xsl:if test="string-length(*:doi/core:doi) = 0">
                    <xsl:apply-templates select="*[1]/@todo:about[(string-length(.) > 0)]" mode="collection_location"/>
                </xsl:if>
                
                <xsl:apply-templates select="*:title[string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="*:managedBy" mode="collection_relatedInfo"/-->
                
                <xsl:apply-templates select="*:managedBy[(string-length(@uuid) > 0) and (string-length(core:family) > 0)]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="*:organisations/*:organisation[(string-length(@uuid) > 0) and (string-length(core:family) > 0)]" mode="collection_relatedObject"/>
        
                <xsl:apply-templates select="*:externalOrganisations" mode="collection_description_notes"/>
                        
                <!-- xsl:apply-templates select="*:persons/*:dataSetPersonAssociation[(string-length(person-template:person/@uuid) > 0) and (string-length(person-template:person/core:family) > 0)]" mode="collection_relatedInfo"/-->
                
                <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation[(string-length(person-template:person/@uuid) > 0) and (string-length(person-template:person/core:family) > 0)]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation[(string-length(person-template:externalPerson/@uuid) > 0) and (string-length(person-template:externalPerson/core:family) > 0)]" mode="collection_relatedObject_external"/>
                
                <xsl:apply-templates select="*:keywordGroups/*:keywordGroup/*:keyword/*:userDefinedKeyword/*:freeKeyword[string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="*:keywordGroups/*:keywordGroup/*:keyword[string-length(*:target/*:term) > 0]" mode="collection_subject"/>
               
                <xsl:apply-templates select="*:descriptions/*:classificationDefinedField/*:value[string-length(.) > 0]" mode="collection_description_full"/>
                
                <xsl:apply-templates select="*:links/*:link" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="*:associatedContent/*:relatedContent" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="." mode="collection_coverage_temporal"/>
                
                <xsl:apply-templates select="*:geographicalCoverage[string-length(.) > 0]" mode="collection_coverage_spatial_text"/>
             
                <xsl:apply-templates select="*:geoLocation/*:point[string-length(.) > 0]" mode="collection_coverage_spatial_point"/>
                
                <xsl:apply-templates select="*:geoLocation/*:polygon[string-length(.) > 0]" mode="collection_coverage_spatial_polygon"/>
                
                <xsl:apply-templates select="*:documents" mode="collection_rights_licence"/>
                
                <xsl:apply-templates select="." mode="collection_rights"/>
                
                <xsl:apply-templates select="." mode="collection_citationInfo"/>
                
                <xsl:apply-templates select="." mode="collection_dates"/>  
                 
            </xsl:element>
        </registryObject>
    </xsl:template>
   
    <xsl:template match="core:modified" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="."/>
    </xsl:template>
   
    <xsl:template match="core:created" mode="collection_date_created">
        <xsl:attribute name="dateAccessioned" select="."/>
    </xsl:template>
    
    <xsl:template match="@uuid" mode="collection_identifier">
        <identifier type="global">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="core:doi" mode="collection_identifier">
        <identifier type="doi">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', normalize-space(.))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
     <xsl:template match="core:doi" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', normalize-space(.))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="*:title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
    <xsl:template match="@todo:about" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="person-template:personRole" mode="relation">
        <xsl:variable name="uriValue_sequence" select="tokenize(core:uri, '/')" as="xs:string*"/>
        <xsl:if test="count($uriValue_sequence) > 0">
            <xsl:variable name="role" select="$uriValue_sequence[count($uriValue_sequence)]"/>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="contains(lower-case($role), 'creator')">
                                <xsl:text>hasCollector</xsl:text>
                            </xsl:when>
                             <xsl:when test="contains(lower-case($role), 'rightsholder')">
                                <xsl:text>isOwnedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($role), 'collector')">
                                <xsl:text>hasCollector</xsl:text>
                            </xsl:when>
                             <xsl:otherwise>
                                <xsl:value-of select="$role"/>
                            </xsl:otherwise>      
                        </xsl:choose>
                    </xsl:attribute>
                </relation>
       </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:dataSetPersonAssociation" mode="collection_relatedObject">
        <xsl:variable name="personName" select="concat(normalize-space(person-template:person/person-template:name/core:firstName), ' ', normalize-space(person-template:person/person-template:name/core:lastName))"/>
        <!-- xsl:message select="concat('personName for relatedObject: ', $personName)"/-->
        <xsl:if test="string-length($personName) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat(normalize-space(person-template:person/core:family), ':', normalize-space(person-template:person/@uuid))"/>
                   <!-- xsl:value-of select="local:formatKey($personName)"/--> 
                </key>
                <xsl:apply-templates select="person-template:personRole" mode="relation"/>
            </relatedObject>
        </xsl:if>   
    </xsl:template>
    
    <xsl:template match="*:dataSetPersonAssociation" mode="collection_relatedObject_external">
        <xsl:variable name="personName" select="concat(normalize-space(person-template:externalPerson/externalperson-template:name/core:firstName), ' ', normalize-space(person-template:externalPerson/externalperson-template:name/core:lastName))"/>
        <!-- xsl:message select="concat('personName for relatedObject: ', $personName)"/-->
        <xsl:if test="string-length($personName) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat(normalize-space(person-template:externalPerson/core:family), ':', normalize-space(person-template:externalPerson/@uuid))"/>
                   <!-- xsl:value-of select="local:formatKey($personName)"/--> 
                </key>
                <xsl:apply-templates select="person-template:personRole" mode="relation"/>
            </relatedObject>
        </xsl:if>   
    </xsl:template>
    
    
    <xsl:template match="*:organisation" mode="collection_relatedObject">
        <xsl:if test="string-length(@uuid) > 0">
            <relatedObject>
                <key>
                   <xsl:value-of select="concat(normalize-space(core:family), ':', normalize-space(@uuid))"/> 
                </key>
                <relation type="isAssociatedWith"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:managedBy" mode="collection_relatedObject">
        <xsl:if test="string-length(@uuid) > 0">
            <relatedObject>
                <key>
                   <xsl:value-of select="concat(normalize-space(core:family), ':', normalize-space(@uuid))"/> 
                </key>
                <relation type="isManagedBy"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:freeKeyword" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="*:keyword" mode="collection_subject">
        <subject>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(lower-case(*:target/*:uri), 'fieldofresearch')">
                        <xsl:text>anzsrc-for</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="fn:matches(*:target/*:term, '[\d]+')">
                    <xsl:analyze-string select="*:target/*:term" regex="[\d]+">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(0)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="*:target/*:term"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </subject>
    </xsl:template>
    
    <xsl:template match="*:value" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="*:link" mode="collection_relatedInfo">
        <relatedInfo type="website">
            <xsl:if test="string-length(*:url) > 0">
                <identifier type="url">
                    <xsl:value-of select="*:url"/>
                </identifier>
            </xsl:if>
            <xsl:if test="string-length(*:description) > 0">
                <title>
                    <xsl:value-of select="*:description"/>
                </title>
            </xsl:if>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="*:relatedContent" mode="collection_relatedInfo">
        <relatedInfo>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(lower-case(*:typeClassification), 'dataset')">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case(*:typeClassification), 'article') or contains(lower-case(*:typeClassification), 'publication')">
                        <xsl:text>publication</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains(lower-case(*:typeClassification), 'dataset') or (string-length(*:portalUrl) = 0)">
                    <identifier type="global">
                        <xsl:value-of select="@uuid"/>
                    </identifier>
                </xsl:when>
                <xsl:otherwise>
                    <identifier type="url">
                        <xsl:value-of select="*:portalUrl"/>
                    </identifier>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="string-length(*:title) > 0">
                <title>
                    <xsl:value-of select="*:title"/>
                </title>
            </xsl:if>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="core:content" mode="collection_coverage_temporal">
        <coverage>
            <temporal>
                <xsl:if test="string-length(*:temporalCoverageStartDate) > 0">
                    <date type="dateFrom" dateFormat="W3CDTF">
                        <xsl:value-of select="local:formatDate(*:temporalCoverageStartDate)"/>
                    </date>
                </xsl:if>
                <xsl:if test="string-length(*:temporalCoverageEndDate) > 0">
                    <date type="dateTo" dateFormat="W3CDTF">
                        <xsl:value-of select="local:formatDate(*:temporalCoverageEndDate)"/>
                    </date>
                </xsl:if>
            </temporal>
        </coverage>
    </xsl:template>
    
    <xsl:template match="*:geographicalCoverage" mode="collection_coverage_spatial_text">
        <coverage>
            <spatial type="text">
                <xsl:value-of select="normalize-space(.)"/>
            </spatial>
        </coverage>
    </xsl:template>
    
    
    <xsl:template match="*:point" mode="collection_coverage_spatial_point">
        <!-- xsl:message select="concat('processing point coordinates input: ', normalize-space(.))"/-->
        <xsl:variable name="coordsAsProvided" select="local:convertCoordinatesLatLongToLongLat(normalize-space(.))" as="xs:string"/>
        <!-- xsl:message select="concat('processing point coordinates determined: ', $coordsAsProvided)"/-->
        <xsl:if test="string-length($coordsAsProvided) > 0">
            <coverage>
                <spatial type="gmlKmlPolyCoords">
                    <xsl:value-of select="$coordsAsProvided"/>
                </spatial>
            </coverage>
            <coverage>    
                <spatial type="text">
                    <xsl:value-of select="$coordsAsProvided"/>
                </spatial>
            </coverage>
        </xsl:if>
        
     </xsl:template>
   
    <xsl:template match="*:polygon" mode="collection_coverage_spatial_polygon">
        <!-- xsl:message select="'processing polygon coordinates'"/-->
        <xsl:variable name="coordsAsProvided" select="local:convertCoordinatesLatLongToLongLat(normalize-space(.))"/>
        
        <xsl:if test="string-length($coordsAsProvided) > 0">
            <coverage>
                <spatial type="gmlKmlPolyCoords">
                    <xsl:value-of select="$coordsAsProvided"/>
                </spatial>
            </coverage>
            <coverage>    
                <spatial type="text">
                    <xsl:value-of select="$coordsAsProvided"/>
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>
  
    <xsl:template match="*:documents" mode="collection_rights_licence">
        <xsl:variable name="fileLicense_sequence" select="*:document/*:documentLicense/core:uri[string-length(.) > 0]"/>
        <xsl:choose>
            <xsl:when test="(count($fileLicense_sequence) > 0) and (custom:sequenceContainsSameValuesCaseInsensitive($fileLicense_sequence))">
                    <rights>
                        <xsl:message select="concat('license to apply: ', substring-after($fileLicense_sequence[1], '/dk/atira/pure/dataset/documentlicenses/'))"/>   
                        <licence type="{substring-after($fileLicense_sequence[1], '/dk/atira/pure/dataset/documentlicenses/')}"/>
                    </rights>
             </xsl:when>
             <xsl:otherwise>
                    <rights>
                        <licence>
                            <xsl:text>Licences for items within this collection vary. See individual items for the licences that apply to them.</xsl:text>
                        </licence>
                    </rights>
             </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="core:content" mode="collection_dates">
        <xsl:for-each select="*:dateMadeAvailable">
            <dates type="issued">
                <date type="dateFrom" dateFormat="W3CDTF">
                    <xsl:value-of select="local:formatDate(.)"/>
                </date>
            </dates>
        </xsl:for-each>
        
        <dates type="created">
            <xsl:for-each select="*:dateOfDataProduction">
                <date type="dateFrom" dateFormat="W3CDTF">
                    <xsl:value-of select="local:formatDate(.)"/>
                </date>
            </xsl:for-each>
            <xsl:for-each select="*:endDateOfDataProduction">
                <date type="dateTo" dateFormat="W3CDTF">
                    <xsl:value-of select="local:formatDate(.)"/>
                </date>
            </xsl:for-each>
        </dates>
        
    </xsl:template> 
    
    <xsl:template match="*:content" mode="collection_rights">
    
        <xsl:variable name="openAccessPermission" select="*:openAccessPermission/*:term"/>
        <!-- xsl:message select="concat('openAccessPermission: ', *:openAccessPermission/*:term)"/-->
        
        <xsl:variable name="visibility" select="*:limitedVisibility/*:visibility"/>
        <!-- xsl:message select="concat('visibility: ', *:limitedVisibility/*:visibility)"/-->
        
        <rights>
            <accessRights>   
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="contains(lower-case($openAccessPermission), 'open') and 
                            (contains(lower-case($visibility), 'public') or (string-length(normalize-space($visibility)) = 0))">
                            <xsl:text>open</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(lower-case($openAccessPermission), 'open')"> <!--  and all visibilities other than included above -->
                            <xsl:text>conditional</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(lower-case($openAccessPermission), 'embargoed')"> 
                            <xsl:text>conditional</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(lower-case($openAccessPermission), 'restricted')"> 
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(lower-case($openAccessPermission), 'closed')"> 
                            <xsl:text>restricted</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute> 
            </accessRights>
        </rights>
        
        <rights>
            <rightsStatement>
                <xsl:if test="string-length(*:legalConditions/*:legalCondition/*:typeClassification/*:term) > 0">
                    <xsl:value-of select="*:legalConditions/*:legalCondition/*:typeClassification/*:term"/>
                </xsl:if>    
                
                <xsl:if test="(string-length(*:legalConditions/*:legalCondition/*:typeClassification/*:term) > 0) and (string-length(*:description) > 0)">
                    <xsl:text> - </xsl:text>
                </xsl:if>    
                
                <xsl:if test="string-length(*:legalConditions/*:legalCondition/*:description) > 0">
                    <xsl:value-of select="*:legalConditions/*:legalCondition/*:description"/>
                </xsl:if>   
            </rightsStatement>
        </rights> 
    
    </xsl:template>
    
    
    <xsl:template match="core:content" mode="collection_citationInfo">
        <citationInfo>
            <citationMetadata>
                <xsl:apply-templates select="*:doi/core:doi" mode="citation_identifier"/>
                
                <xsl:apply-templates select="*:title[string-length(.) > 0]" mode="citation_title"/>
                
                <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation[(string-length(person-template:person/@uuid) > 0) and (string-length(person-template:person/core:family) > 0) and (contains(substring-after(normalize-space(person-template:personRole/core:uri), '/dk/atira/pure/dataset/roles/dataset/'), 'creator'))]" mode="citation_contributor"/>
           
                <xsl:apply-templates select="*:publisher[string-length(*:name) > 0]" mode="citation_publisher"/>
                
                <xsl:apply-templates select="*:dateMadeAvailable[string-length(core:year) > 0]" mode="citation_publication_date"/>
            </citationMetadata>
        </citationInfo>
    </xsl:template>
  
    <xsl:template match="core:doi" mode="citation_identifier">
        <identifier type="doi">
            <xsl:value-of select="."/>
        </identifier>   
    </xsl:template>
    
    <xsl:template match="*:title[string-length(.) > 0]" mode="citation_title">
        <title>
            <xsl:value-of select="normalize-space(.)"/>
        </title>
    </xsl:template>
  
    <xsl:template match="*:dataSetPersonAssociation" mode="citation_contributor">
        <contributor>
            <namePart type="given">
                <xsl:value-of select="normalize-space(person-template:person/person-template:name/core:firstName)"/>
            </namePart>    
            <namePart type="family">
                <xsl:value-of select="normalize-space(person-template:person/person-template:name/core:lastName)"/>
            </namePart>    
        </contributor>
    </xsl:template>
    
    <xsl:template match="*:publisher" mode="citation_publisher">
        <publisher>
            <xsl:value-of select="normalize-space(*:name)"/>
        </publisher>
    </xsl:template>
    
    <xsl:template match="*:dateMadeAvailable" mode="citation_publication_date">
        <date type="publicationDate">
            <xsl:value-of select="normalize-space(core:year)"/>
        </date> 
    </xsl:template>
        
    <xsl:template match="core:content" mode="party">
    
        <xsl:apply-templates select="*:managedBy[(string-length(@uuid) > 0) and (string-length(core:family) > 0)]" mode="party_managing_organisation"/>
        <xsl:apply-templates select="*:organisations/*:organisation[(string-length(@uuid) > 0) and (string-length(core:family) > 0)]" mode="party_organisation"/>
        <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation[(string-length(person-template:person/@uuid) > 0) and (string-length(person-template:person/core:family) > 0)]" mode="party_people"/>
        <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation[(string-length(person-template:externalPerson/@uuid) > 0) and (string-length(person-template:externalPerson/core:family) > 0)]" mode="party_external_people"/>
                
    
    </xsl:template>
    
     <xsl:template match="*:dataSetPersonAssociation" mode="party_people">
           
            <xsl:variable name="personName" select="concat(normalize-space(person-template:person/person-template:name/core:firstName), ' ', normalize-space(person-template:person/person-template:name/core:lastName))"/>
            <xsl:message select="concat('personName (party_people): ', $personName    )"/>
        
            <xsl:if test="(string-length($personName) > 0)">
            
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="concat(normalize-space(person-template:person/core:family), ':', normalize-space(person-template:person/@uuid))"/> 
                           <!-- xsl:value-of select="local:formatKey($personName)"/--> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                            <xsl:if test="string-length(person-template:person/@uuid) > 0">
                                <identifier type="global">
                                    <xsl:value-of select="person-template:person/@uuid"/>
                                </identifier>
                            </xsl:if>
                             <name type="primary">
                                 <namePart type="given">
                                    <xsl:value-of select="normalize-space(person-template:person/person-template:name/core:firstName)"/>
                                 </namePart>    
                                 <namePart type="family">
                                    <xsl:value-of select="normalize-space(person-template:person/person-template:name/core:lastName)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
                   
                </xsl:if>
            
        </xsl:template>
        
        <xsl:template match="*:dataSetPersonAssociation" mode="party_external_people">
           
            <xsl:variable name="personName" select="concat(normalize-space(person-template:externalPerson/externalperson-template:name/core:firstName), ' ', normalize-space(person-template:externalPerson/externalperson-template:name/core:lastName))"/>
            <xsl:message select="concat('personName (party_external_people): ', $personName    )"/>
        
            <xsl:if test="(string-length($personName) > 0)">
            
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="concat(normalize-space(person-template:externalPerson/core:family), ':', normalize-space(person-template:externalPerson/@uuid))"/> 
                           <!-- xsl:value-of select="local:formatKey($personName)"/--> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                            <xsl:if test="string-length(person-template:externalPerson/@uuid) > 0">
                                <identifier type="global">
                                    <xsl:value-of select="person-template:externalPerson/@uuid"/>
                                </identifier>
                            </xsl:if>
                             <name type="primary">
                                 <namePart type="given">
                                    <xsl:value-of select="normalize-space(person-template:externalPerson/externalperson-template:name/core:firstName)"/>
                                 </namePart>    
                                 <namePart type="family">
                                    <xsl:value-of select="normalize-space(person-template:externalPerson/externalperson-template:name/core:lastName)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
                   
                </xsl:if>
            
        </xsl:template>
        
        
        <xsl:template match="*:externalOrganisations" mode="collection_description_notes">
        
            <description type="notes">
                <xsl:text>&lt;b&gt;External Organisations&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
                <xsl:for-each select="*:externalOrganisation[(string-length(@uuid) > 0) and (string-length(*:name) > 0)]">
                    <xsl:if test="position() > 1">
                        <xsl:text>; </xsl:text>
                    </xsl:if>    
                    <xsl:value-of select="normalize-space(*:name)"/>
                </xsl:for-each>
            </description>
        </xsl:template>
        
        
        
        <xsl:template match="*:managedBy" mode="party_managing_organisation">
           
            
                     <registryObject group="{$global_group}">
                        <key>
                           <xsl:value-of select="concat(normalize-space(core:family), ':', normalize-space(@uuid))"/> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'group'"/>
                             
                            <xsl:if test="string-length(@uuid) > 0">
                                <identifier type="global">
                                    <xsl:value-of select="@uuid"/>
                                </identifier>
                            </xsl:if>
                             <name type="primary">
                                 <namePart>
                                    <xsl:value-of select="normalize-space(organisation-template:name)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
        </xsl:template>
        
        <xsl:template match="*:organisation" mode="party_organisation">
           
                     <registryObject group="{$global_group}">
                        <key>
                           <xsl:value-of select="concat(normalize-space(core:family), ':', normalize-space(@uuid))"/> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'group'"/>
                             
                            <xsl:if test="string-length(@uuid) > 0">
                                <identifier type="global">
                                    <xsl:value-of select="@uuid"/>
                                </identifier>
                            </xsl:if>
                             <name type="primary">
                                 <namePart>
                                    <xsl:value-of select="normalize-space(organisation-template:name)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
         </xsl:template>
             
     <xsl:function name="local:formatDate">
        <xsl:param name="currentNode" as="node()"/>
        
        <xsl:variable name="datePart_sequence" as="xs:string*">
            <xsl:copy-of select="normalize-space($currentNode/*:year)"/>
            <xsl:copy-of select="format-number($currentNode/*:month, '00')"/>
            <xsl:copy-of select="format-number($currentNode/*:day, '00')"/>
        </xsl:variable>
        <xsl:value-of  select="string-join($datePart_sequence, '-')"/>   
    </xsl:function>
    
    <xsl:function name="local:getEvenCoordSequence" as="xs:string*">
        <xsl:param name="coordinates" as="xs:string"/>
        
        <xsl:for-each select="local:getAllCoordsSequence($coordinates)">
            <xsl:if test="(position() mod 2) = 0">
                <xsl:value-of select="."/>    
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="local:getOddCoordSequence" as="xs:string*">
        <xsl:param name="coordinates" as="xs:string"/>
        
        <xsl:for-each select="local:getAllCoordsSequence($coordinates)">
            <xsl:if test="(position() mod 2) > 0">
                <xsl:value-of select="."/>    
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
     <xsl:function name="local:getAllCoordsSequence" as="xs:string*">
        <xsl:param name="coordinates" as="xs:string"/>
        
        <!-- xsl:message select="concat('coordinates ', $coordinates)"/-->
        
        <!--  (?![\s|^|,])[\d\.-]+ -->
        <!--  [\d\.-]+  -->
        <xsl:variable name="coordinate_sequence" as="xs:string*">
            <xsl:analyze-string select="$coordinates" regex="[-]*[\d]+[\.]*[\d]*">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(0)"/>
                    <!-- xsl:message select="concat('match: ', regex-group(0))"/-->
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
       <xsl:copy-of select="$coordinate_sequence"/>
    </xsl:function>
       
    <xsl:function name="local:convertCoordinatesLatLongToLongLat" as="xs:string">
        <xsl:param name="coordinates" as="xs:string"/>
        
        <xsl:variable name="latCoords_sequence" select="local:getOddCoordSequence($coordinates)" as="xs:string*"/>
        <xsl:variable name="longCoords_sequence" select="local:getEvenCoordSequence($coordinates)" as="xs:string*"/>
        
        <!-- xsl:message select="concat('longCoords ', string-join(for $i in $longCoords_sequence return $i, ' '))"/-->
        <!-- xsl:message select="concat('latCoords ', string-join(for $i in $latCoords_sequence return $i, ' '))"/-->
        
        <xsl:value-of select="local:formatCoordinatesFromSequences($longCoords_sequence, $latCoords_sequence)"/>
    </xsl:function>
    
    <xsl:function name="local:formatCoordinatesFromString" as="xs:string">
        <xsl:param name="coordinates" as="xs:string"/>
        
        <xsl:variable name="latCoords_sequence" select="local:getOddCoordSequence($coordinates)" as="xs:string*"/>
        <xsl:variable name="longCoords_sequence" select="local:getEvenCoordSequence($coordinates)" as="xs:string*"/>
        
        <!-- xsl:message select="concat('longCoords ', string-join(for $i in $longCoords_sequence return $i, ' '))"/-->
        <!-- xsl:message select="concat('latCoords ', string-join(for $i in $latCoords_sequence return $i, ' '))"/-->
        
        <xsl:value-of select="local:formatCoordinatesFromSequences($longCoords_sequence, $latCoords_sequence)"/>
    </xsl:function>
    
    <xsl:function name="local:formatCoordinatesFromSequences" as="xs:string">
        <xsl:param name="longCoords_sequence" as="xs:string*"/>
        <xsl:param name="latCoords_sequence" as="xs:string*"/>
         
        <!-- xsl:message select="concat('longCoords ', string-join(for $i in $longCoords_sequence return $i, ' '))"/-->
        <!-- xsl:message select="concat('latCoords ', string-join(for $i in $latCoords_sequence return $i, ' '))"/-->
        
        <xsl:variable name="coordinatePair_sequence" as="xs:string*">
            <xsl:for-each select="$longCoords_sequence">
                <xsl:if test="count($latCoords_sequence) > position()-1">
                    <xsl:variable name="index" select="position()" as="xs:integer"/>
                    <xsl:value-of select="concat(., ',', normalize-space($latCoords_sequence[$index]))"/>
                </xsl:if>
            </xsl:for-each> 
        </xsl:variable>
        
        <xsl:choose>    
            <xsl:when test="count($coordinatePair_sequence) > 0"> 
                <xsl:value-of select="string-join(for $i in $coordinatePair_sequence return $i, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>

</xsl:stylesheet>