<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message"
    xmlns:common="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
    xmlns:report="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/metadata/generic"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    <!-- stylesheet to convert data.gov.au xml (transformed from json with python script) to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_originatingSource" select="'Australian Bureau of Statistics (ABS)'"/>
    <xsl:param name="global_baseURI" select="'http://stat.abs.gov.au/'"/>
    <xsl:param name="global_acronym" select="'ABS'"/>
    <xsl:param name="global_group"
        select="'Australian Bureau of Statistics (ABS)'"/>
    <xsl:param name="global_contributor"
        select="'Australian Bureau of Statistics (ABS)'"/>
    <xsl:param name="global_publisherName"
        select="'Australian Bureau of Statistics (ABS)'"/>
    <xsl:param name="global_publisherPlace" select="'Australia'"/>
    <xsl:param name="global_productName"/>
  
    <!--xsl:template match="datasets/help"/-->
    <!--xsl:template match="datasets/success"/-->

    <!-- =========================================== -->
    <!-- dataset (datasets) Template             -->
    <!-- =========================================== -->

    <xsl:template match="soap:Envelope/soap:Body">
        <xsl:apply-templates select="*:GetDatasetMetadataResponse/*:GetDatasetMetadataResult/message:GenericMetadata" mode="collection"/>
         <!--registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
             <xsl:apply-templates select="*:GetDatasetMetadataResponse/*:GetDatasetMetadataResult/message:GenericMetadata" mode="collection"/>
         </registryObjects-->
    </xsl:template>
        
    <xsl:template match="*:GenericMetadata" mode="collection">
        <xsl:message select="'Hello world!'"/>
        <xsl:variable name="id" select="*:Header/*:Structure/*:Structure/*:Ref/@id"/>
        <xsl:message select="concat('id: ', $id)"/>
        
        <xsl:variable name="abstract" select="*:MetadataSet/*:Report/*:AttributeSet/*:ReportedAttribute[@id='DATA_COMP']/*:ReportedAttribute[@id='Abstract']/*:Text"/>
        <xsl:message select="concat('abstract: ', $abstract)"/>
        
        <xsl:variable name="abstractURL">
            <xsl:if test="string-length($abstract) > 0">
                <xsl:analyze-string select="$abstract" regex="http://[^\s]*">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>
        
        <xsl:message select="concat('abstractURL: ', $abstractURL)"/>
        
        <xsl:variable name="directSource" select="*:MetadataSet/*:Report/*:AttributeSet/*:ReportedAttribute[@id='SOURCE']/*:ReportedAttribute[@id = 'Direct source']/*:Text"/>
        <xsl:message select="concat('directSource: ', $directSource)"/>
        
        <xsl:variable name="directSourceURL">
            <xsl:if test="string-length($directSource) > 0">
                <xsl:analyze-string select="$directSource" regex="http://[^\s]*">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>
        
        <xsl:message select="concat('directSourceURL: ', $directSourceURL)"/>
        
        <xsl:variable name="qualityInformation" select="*:MetadataSet/*:Report/*:AttributeSet/*:ReportedAttribute[@id='OTHER_ASPECTS']/*:ReportedAttribute[@id = 'Quality comments']/*:Text"/>
        <xsl:variable name="qualityURL">
            <xsl:if test="string-length($qualityInformation) > 0">
                <xsl:analyze-string select="$qualityInformation" regex="http://[^\s]*">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>
        
        <xsl:message select="concat('qualityURL: ', $qualityURL)"/>
        
        <xsl:variable name="dataSources" select="*:MetadataSet/*:Report/*:AttributeSet/*:ReportedAttribute[@id='SOURCE']/*:ReportedAttribute[@id = 'Data source(s) used']/*:Text"/>
        <xsl:message select="concat('dataSources: ', $dataSources)"/>
        
            
        <xsl:variable name="furtherInformation_sequence" as="xs:string*" select="*:MetadataSet/*:Report/*:AttributeSet/*:ReportedAttribute/*:ReportedAttribute[@id != 'Abstract' and @id != 'Quality comments']/*:Text"/>
        
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_group"/>
            </xsl:attribute>
            <key>
                <xsl:value-of select="concat($global_acronym, '/', $id)"/>
            </key>
           <xsl:apply-templates select="id" mode="collection_key"/>

            <originatingSource>
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(organization/title)) > 0">
                        <xsl:value-of select="normalize-space(organization/title)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$global_originatingSource"/>
                    </xsl:otherwise>
                </xsl:choose>
            </originatingSource>

            <collection>

                <xsl:variable name="collectionType" select="normalize-space(type)"/>
                <xsl:attribute name="type">
                    <xsl:text>dataset</xsl:text>
                </xsl:attribute>

                <xsl:if test="string-length(normalize-space(metadata_created))">
                    <xsl:attribute name="dateAccessioned">
                        <xsl:value-of select="normalize-space(metadata_created)"/>
                    </xsl:attribute>
                </xsl:if>

                <xsl:if test="string-length(normalize-space(metadata_modified))">
                    <xsl:attribute name="dateModified">
                        <xsl:value-of select="normalize-space(metadata_modified)"/>
                    </xsl:attribute>
                </xsl:if>
                
                <identifier type="local">
                    <xsl:value-of select="$id"/>
                </identifier>
                
                <xsl:choose>
                    <xsl:when test="string-length($abstractURL) > 0">
                        <identifier type="uri">
                            <xsl:value-of select="$abstractURL"/>
                        </identifier>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="string-length($directSourceURL) > 0">
                            <identifier type="uri">
                                <xsl:value-of select="$directSourceURL"/>
                            </identifier>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                     <xsl:when test="string-length($abstractURL) > 0">
                        <location>
                             <address>
                                 <electronic type="url">
                                     <value><xsl:value-of select="$abstractURL"/></value>
                                 </electronic>
                             </address>
                         </location>
                     </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="string-length($directSourceURL) > 0">
                            <location>
                                <address>
                                    <electronic type="url">
                                        <value><xsl:value-of select="$directSourceURL"/></value>
                                    </electronic>
                                </address>
                            </location>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                            
                <xsl:if test="string-length($global_productName) > 0">
                    <name>
                        <xsl:attribute name="type">
                            <xsl:text>primary</xsl:text>
                        </xsl:attribute>
                        <namePart>
                            <xsl:value-of select="$global_productName"/>
                        </namePart>
                    </name>
                </xsl:if>
                
                <xsl:if test="count($abstract) > 0">
                    <description type="brief">
                        <xsl:for-each select="distinct-values($abstract)">
                            <xsl:if test="string-length(normalize-space(.)) > 0">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:if>
                        </xsl:for-each>
                    </description>
                </xsl:if>
                
                <xsl:if test="count($furtherInformation_sequence) > 0">
                    <description type="full">
                        <xsl:for-each select="distinct-values($furtherInformation_sequence)">
                             <xsl:if test="string-length(normalize-space(.)) > 0">
                                 <xsl:value-of select="normalize-space(.)"/>
                                 <xsl:text>&#xa;&#xa;</xsl:text>
                             </xsl:if>
                         </xsl:for-each>
                    </description>
                </xsl:if>
                
                <xsl:if test="string-length($qualityURL) > 0">
                    <relatedInfo type='dataQualityInformation'>
                        <identifier type="uri">
                            <xsl:value-of select="$qualityURL"/>
                        </identifier>
                        <relation type="isSupplementTo"/>
                    </relatedInfo>
                </xsl:if>
                              
            </collection>

        </registryObject>
    </xsl:template>

    

    <!-- Collection - Name Element  -->
    <xsl:template match="title" mode="collection_name">
        <xsl:if test="string-length(normalize-space(.))">
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

    <!-- Collection - Location Element  -->
    <xsl:template match="name" mode="collection_location_name">
        <xsl:variable name="name" select="normalize-space(.)"/>
        <xsl:if test="string-length($name)">
            <location>
                <address>
                    <electronic>
                        <xsl:attribute name="type">
                            <xsl:text>url</xsl:text>
                        </xsl:attribute>
                        <value>
                            <xsl:value-of select="concat($global_baseURI, 'dataset/', $name)"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:if>
    </xsl:template>

    <xsl:template match="url" mode="collection_location_url">
        <xsl:variable name="url" select="normalize-space(.)"/>
        <xsl:if test="string-length($url)">
            <location>
                <address>
                    <electronic>
                        <xsl:attribute name="type">
                            <xsl:text>url</xsl:text>
                        </xsl:attribute>
                        <value>
                            <xsl:value-of select="$url"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:if>
    </xsl:template>

    <xsl:template match="author" mode="collection_related_object">
        <xsl:if test="string-length(normalize-space(.))">
            <relatedObject>
                <key>
                    <xsl:value-of
                        select="concat($global_group,'/', translate(normalize-space(lower-case(normalize-space(.))),' ',''))"
                    />
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>author</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Subject Element -->
    <xsl:template match="tags" mode="collection_subject">
        <xsl:if test="string-length(normalize-space(display_name))">
            <subject>
                <xsl:attribute name="type">local</xsl:attribute>
                <xsl:value-of select="normalize-space(display_name)"/>
            </subject>
        </xsl:if>
    </xsl:template>

   <xsl:function name="custom:requiresSpecialTreatment" as="xs:boolean">
        <xsl:param name="key"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($key), 'citation')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="contains(lower-case($key), 'spatial')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- Collection - Decription (full) Element -->
    <xsl:template match="notes" mode="collection_description">
        <xsl:if test="string-length(normalize-space(.))">
            <description type="full">
                <xsl:value-of select="normalize-space(.)"/>
            </description>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Citation -->
    <xsl:template match="value" mode="collection_citation">
        <citationInfo>
            <fullCitation>
                <xsl:value-of select="."/>
            </fullCitation>
        </citationInfo>
    </xsl:template>

    <!-- Collection - Coverage Spatial -->
    <xsl:template match="value" mode="collection_coverage_spatial">
        <xsl:variable name="spatial" select="normalize-space(.)"/>
        <xsl:variable name="coordinate_sequence" as="xs:string*">
            <xsl:if test="contains($spatial, 'Polygon') and contains($spatial, 'coordinates')">
                <xsl:analyze-string select="$spatial" regex="\[([^\[]*?)\]">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="count($coordinate_sequence) = 0">
                <xsl:if test="string-length($spatial)">
                    <xsl:if
                        test="(string-length($spatial) > 0) and not(contains(lower-case($spatial), 'not specified'))">
                        <coverage>
                            <spatial>
                                <xsl:attribute name="type">
                                    <xsl:text>text</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$spatial"/>
                            </spatial>
                        </coverage>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <coverage>
                    <spatial>
                        <xsl:attribute name="type">
                            <xsl:text>gmlKmlPolyCoords</xsl:text>
                        </xsl:attribute>
                        <xsl:for-each select="$coordinate_sequence">
                            <xsl:value-of select="translate(., ' |[|]', '')"/>
                            <xsl:if test="position() != count($coordinate_sequence)">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </spatial>
                </coverage>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   <!-- Collection - Related Info Element -->
    <xsl:template match="resources" mode="collection_relatedInfo">
        <relatedInfo type="resource">
            <xsl:if test="string-length(normalize-space(url))">
                <identifier type="uri">
                    <xsl:value-of select="normalize-space(url)"/>
                </identifier>
            </xsl:if>
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>hasPart</xsl:text>
                </xsl:attribute>
            </relation>
            <xsl:variable name="format" select="normalize-space(format)"/>
            <xsl:variable name="name" select="normalize-space(name)"/>
            <title>
                <xsl:choose>
                    <xsl:when test="string-length($name)">
                        <xsl:choose>
                            <xsl:when test="string-length($format)">
                                <xsl:value-of select="concat($name, ' (',$format, ')')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="string-length($format)">
                            <xsl:value-of select="concat('(',$format, ')')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </title>
            <xsl:if test="string-length(normalize-space(description))">
                <notes>
                    <xsl:value-of select="normalize-space(description)"/>
                </notes>
            </xsl:if>
        </relatedInfo>

        <xsl:if test="contains(lower-case(webstore_url), 'active')">
            <relatedInfo type="resource">
                <xsl:variable name="id" select="normalize-space(id)"/>
                <xsl:if test="string-length($id)">
                    <identifier type="uri">
                        <xsl:value-of
                            select="concat($global_baseURI, 'api/3/action/datastore_search?resource_id=', $id)"
                        />
                    </identifier>
                </xsl:if>
                <xsl:variable name="format" select="'Tabular data in JSON'"/>
                <title>
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(name))">
                            <xsl:value-of select="concat(normalize-space(name), ' (',$format, ')')"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('(',$format, ')')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </title>
                <xsl:if test="string-length(normalize-space(description))">
                    <notes>
                        <xsl:value-of select="normalize-space(description)"/>
                    </notes>
                </xsl:if>
            </relatedInfo>
        </xsl:if>
    </xsl:template>

    <!-- Collection - CitationInfo Element -->
    <xsl:template name="collection_citation">
        <xsl:param name="title"/>
        <xsl:param name="id"/>
        <xsl:param name="url"/>
        <xsl:param name="author"/>
        <xsl:param name="organisation"/>
        <xsl:param name="date"/>

        <xsl:variable name="identifier" select="normalize-space($id)"/>
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when
                        test="string-length($identifier) and contains(lower-case($identifier), 'doi')">
                        <identifier>
                            <xsl:attribute name="type">
                                <xsl:text>doi</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$identifier"/>
                        </identifier>
                    </xsl:when>
                    <xsl:otherwise>
                        <identifier>
                            <xsl:attribute name="type">
                                <xsl:text>uri</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$url"/>
                        </identifier>
                    </xsl:otherwise>
                </xsl:choose>

                <title>
                    <xsl:value-of select="$title"/>
                </title>
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>publicationDate</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$date"/>
                </date>

                <contributor>
                    <namePart>
                        <xsl:value-of select="$author"/>
                    </namePart>
                </contributor>

                <xsl:if test="$author != $organisation">
                    <contributor>
                        <namePart>
                            <xsl:value-of select="$organisation"/>
                        </namePart>
                    </contributor>
                </xsl:if>

                <publisher>
                    <xsl:value-of select="$organisation"/>
                </publisher>

            </citationMetadata>
        </citationInfo>
    </xsl:template>


    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template match="organization">
        <xsl:variable name="title" select="normalize-space(title)"/>
        <xsl:if test="string-length($title) > 0">
            <registryObject group="{$global_group}">

                <key>
                    <xsl:value-of
                        select="concat($global_group, '/', translate(lower-case($title),' ',''))"/>
                </key>

                <originatingSource>
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(title)) > 0">
                            <xsl:value-of select="normalize-space(title)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$global_originatingSource"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </originatingSource>

                <party type="group">

                    <xsl:variable name="name" select="normalize-space(name)"/>
                    <xsl:if test="string-length($name)">
                        <identifier type="uri">
                            <xsl:value-of select="concat($global_baseURI,'organization/', $name)"/>
                        </identifier>
                    </xsl:if>

                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="$title"/>
                        </namePart>
                    </name>

                    <xsl:if test="string-length($name)">
                        <location>
                            <address>
                                <electronic>
                                    <xsl:attribute name="type">
                                        <xsl:text>url</xsl:text>
                                    </xsl:attribute>
                                    <value>
                                        <xsl:value-of select="concat($global_baseURI, 'organization/', $name)"/>
                                    </value>
                                </electronic>
                            </address>
                        </location>
                    </xsl:if>

                    <xsl:if test="string-length(normalize-space(description))">
                        <description>
                            <xsl:attribute name="type">
                                <xsl:text>full</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(description)"/>
                        </description>
                    </xsl:if>
                </party>
            </registryObject>
        </xsl:if>
    </xsl:template>

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template match="result" mode="party_author">
        <xsl:variable name="name" select="author"/>
        <xsl:if test="string-length($name) > 0">
            <registryObject group="{$global_group}">

                <key>
                    <xsl:value-of
                        select="concat($global_group, '/', translate(lower-case($name),' ',''))"/>
                </key>

                <originatingSource>
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space($name)) > 0">
                            <xsl:value-of select="normalize-space($name)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$global_originatingSource"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </originatingSource>

                <party type="group">
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="$name"/>
                        </namePart>
                    </name>

                    <xsl:if test="string-length(normalize-space(author_email))">
                        <location>
                            <address>
                                <electronic type="email">
                                    <value>
                                        <xsl:value-of select="normalize-space(author_email)"/>
                                    </value>
                                </electronic>
                            </address>
                        </location>
                    </xsl:if>

                    <xsl:variable name="orgName" select="organization/title"/>
                    <xsl:if test="boolean(string-length($orgName))">
                        <relatedObject>
                            <key>
                                <xsl:value-of
                                    select="concat($global_group,'/', translate(lower-case($name),' ',''))"
                                />
                            </key>
                            <relation>
                                <xsl:attribute name="type">
                                    <xsl:text>isMemberOf</xsl:text>
                                </xsl:attribute>
                            </relation>
                        </relatedObject>
                    </xsl:if>
                </party>
            </registryObject>
        </xsl:if>
    </xsl:template>

   <xsl:template name="collection_license">
        <xsl:param name="title"/>
        <xsl:param name="id"/>
        <xsl:param name="url"/>
        <xsl:if
            test="string-length($title) > 0 or string-length($id) > 0 or string-length($url) > 0">
            <rights>
                <licence>
                    <xsl:if test="string-length($id) > 0">
                        <xsl:attribute name="type">
                            <xsl:value-of select="upper-case($id)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string-length($url) > 0">
                        <xsl:attribute name="rightsUri">
                            <xsl:value-of select="$url"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string-length($title) > 0">
                        <xsl:value-of select="$title"/>
                    </xsl:if>
                </licence>
            </rights>
        </xsl:if>
    </xsl:template>

    <xsl:template name="getServiceName">
        <xsl:param name="url"/>
        <xsl:choose>
            <xsl:when test="contains($url, 'rest/services/')">
                <xsl:value-of select="concat(substring-after($url, 'rest/services/'), ' service')"/>
            </xsl:when>
            <xsl:when test="contains($url, $global_baseURI)">
                <xsl:value-of
                    select="concat(substring-after($url, $global_baseURI), ' ', $global_group, ' service')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tokenize($url, '/')">
                    <xsl:if test="position() = count(tokenize($url, '/'))">
                        <xsl:value-of select="concat(normalize-space(.), ' service')"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="splitText" as="xs:string*">
        <xsl:param name="string"/>
        <xsl:param name="separator" select="','"/>
        <xsl:choose>
            <xsl:when test="contains($string, $separator)">
                <xsl:if test="not(starts-with($string, $separator))">
                    <xsl:value-of select="substring-before($string, $separator)"/>
                </xsl:if>
                <xsl:call-template name="splitText">
                    <xsl:with-param name="string"
                        select="normalize-space(substring-after($string,$separator))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(normalize-space($string)) > 0">
                    <xsl:value-of select="$string"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
