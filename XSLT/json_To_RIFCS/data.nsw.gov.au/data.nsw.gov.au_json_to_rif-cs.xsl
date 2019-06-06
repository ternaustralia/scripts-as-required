<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"   
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="custom">
    <!-- stylesheet to convert data.nsw.gov.au xml (transformed from json with python script) to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_originatingSource" select="'http://data.nsw.gov.au'"/>
    <xsl:param name="global_baseURI" select="'http://data.nsw.gov.au/data/'"/>
    <xsl:param name="global_group" select="'data.nsw.gov.au'"/>
    <xsl:param name="global_contributor" select="'data.nsw.gov.au'"/>
    <xsl:param name="global_publisherName" select="'data.nsw.gov.au'"/>
    <xsl:param name="global_publisherPlace" select="'New South Wales'"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="//datasets/help"/>
    <xsl:template match="//datasets/success"/>

    <!-- =========================================== -->
    <!-- dataset (datasets) Template             -->
    <!-- =========================================== -->

    <xsl:template match="datasets">
            
         <registryObjects>
             <xsl:attribute name="xsi:schemaLocation">
                 <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
             </xsl:attribute>
    
             <xsl:apply-templates select="result" mode="constructObjects"/>
                 
         </registryObjects>
        
    </xsl:template>
    
    <xsl:template match="result" mode="constructObjects">
        <xsl:variable name="harvestSourceTitle_sequence" as="xs:string*" select="harvest_source_title"/>
        <xsl:variable name="organisationTitle_sequence" as="xs:string*" select="organization/title"/>
        <!-- Construct a record if organisation is not Commonwealth Datasets or if there is either no harvest source title, or it isn't "commonwealth datasets" -->
        <xsl:if test="(not(boolean(custom:sequenceContains($organisationTitle_sequence, 'Commonwealth Datasets'))) and 
            ((count($harvestSourceTitle_sequence) = 0) or not(boolean(custom:sequenceContains($harvestSourceTitle_sequence, 'Commonwealth Datasets')))))">
            <xsl:apply-templates select="." mode="collection"/>
            <xsl:apply-templates select="." mode="party"/>
            <!--xsl:apply-templates select="." mode="service"/-->
            
        </xsl:if>
    </xsl:template>
    

    <xsl:template match="result" mode="collection">

        <xsl:variable name="metadataURL">
            <xsl:variable name="name" select="normalize-space(name)"/>
            <xsl:if test="string-length($name)">
                <xsl:value-of select="concat($global_baseURI, 'dataset/', $name)"/>
            </xsl:if>
        </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_group"/>
            </xsl:attribute>
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
                    <xsl:choose>
                        <xsl:when test="string-length($collectionType)">
                            <xsl:value-of select="$collectionType"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>dataset</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
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

                <xsl:apply-templates select="id" mode="collection_identifier"/>

                <xsl:apply-templates select="name" mode="collection_identifier"/>

                <xsl:apply-templates select="title" mode="collection_name"/>

                <xsl:apply-templates select="name" mode="collection_location_name"/>

                <xsl:apply-templates select="url" mode="collection_location_url"/>

                <xsl:apply-templates select="organization" mode="collection_related_object"/>

                <!--xsl:apply-templates select="author" mode="collection_related_object"/-->

                <xsl:apply-templates select="tags" mode="collection_subject"/>

                <xsl:apply-templates select="notes" mode="collection_description_brief"/>

                <xsl:apply-templates select="." mode="collection_description_full"/>
                
                <xsl:apply-templates select="spatial_coverage" mode="collection_coverage_spatial"/>

                <xsl:apply-templates select="isopen" mode="collection_rights_accessRights"/>

                <xsl:call-template name="collection_license">
                    <xsl:with-param name="title" select="license_title"/>
                    <xsl:with-param name="id" select="license_id"/>
                    <xsl:with-param name="url" select="license_url"/>
                </xsl:call-template>

                <!--xsl:apply-templates select="." mode="collection_relatedInfo"/-->

                <!--xsl:apply-templates select="" 
                    mode="collection_relatedInfo"/-->

                <!--xsl:call-template name="collection_citation">
                    <xsl:with-param name="title" select="title"/>
                    <xsl:with-param name="id" select="id"/>
                    <xsl:with-param name="url" select="$metadataURL"/>
                    <xsl:with-param name="author" select="author"/>
                    <xsl:with-param name="organisation" select="organisation/title"/>
                    <xsl:with-param name="date" select="metadata_created"/>
                    </xsl:call-template-->
            </collection>

        </registryObject>
    </xsl:template>

    <!-- =========================================== -->
    <!-- Party RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="result" mode="party">

        <xsl:apply-templates select="organization"/>

        <!-- name of author differs from name of organisation, so construct an author record and relate it to the organization-->
        <!--xsl:variable name="authorName" select="author"/>
        <xsl:if test="not(contains(lower-case(organization/title), lower-case($authorName)))">
            <xsl:apply-templates select="." mode="party_author"/>
        </xsl:if-->
    </xsl:template>

    <!-- =========================================== -->
    <!-- Collection RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- Collection - Key Element  -->
    <xsl:template match="id" mode="collection_key">
        <xsl:if test="string-length(normalize-space(.))">
            <key>
                <xsl:value-of select="concat($global_group,'/', lower-case(normalize-space(.)))"/>
            </key>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Identifier Element  -->
    <xsl:template match="id" mode="collection_identifier">
        <xsl:if test="string-length(normalize-space(.))">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>local</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name" mode="collection_identifier">
        <xsl:if test="string-length(normalize-space(.))">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>uri</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="concat($global_baseURI, 'dataset/', normalize-space(.))"/>
            </identifier>
        </xsl:if>
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
                        <xsl:attribute name="target">
                            <xsl:text>landingPage</xsl:text>
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
                        <xsl:attribute name="target">
                            <xsl:text>landingPage</xsl:text>
                        </xsl:attribute>
                        <value>
                            <xsl:value-of select="$url"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Related Object (Organisation or Individual) Element -->
    <xsl:template match="organization" mode="collection_related_object">
        <xsl:if test="string-length(normalize-space(title))">
            <relatedObject>
                <key>
                    <xsl:value-of
                        select="concat($global_group,'/', translate(lower-case(normalize-space(title)),' ',''))"
                    />
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>owner</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>

            <!--xsl:apply-templates select="../." mode="collection_relatedInfo"/-->
        </xsl:if>
    </xsl:template>

    <!--xsl:template match="author" mode="collection_related_object">
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
    </xsl:template-->

    <!-- Collection - Subject Element -->
    <xsl:template match="tags" mode="collection_subject">
        <xsl:if test="string-length(normalize-space(display_name))">
            <subject>
                <xsl:attribute name="type">local</xsl:attribute>
                <xsl:value-of select="normalize-space(display_name)"/>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Decription (brief) Element -->
    <xsl:template match="notes" mode="collection_description_brief">
        <xsl:if test="string-length(normalize-space(.))">
            <description type="brief">
                <xsl:value-of select="custom:reformatHyperlinks(normalize-space(.))"/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Decription (full) Element -->
    <xsl:template match="result" mode="collection_description_full">
        <description type="full">
             <xsl:for-each select="resources">
                <xsl:if test="string-length(normalize-space(name)) > 0">
                    <xsl:value-of select="concat(normalize-space(name), '&lt;br/&gt;')"/>
                </xsl:if>
            </xsl:for-each>
        </description>
    </xsl:template>

    <xsl:template match="isopen" mode="collection_rights_accessRights">
        <xsl:if test="contains(lower-case(.), 'true')">
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
    </xsl:template>

    <xsl:template match="spatial_coverage" mode="collection_coverage_spatial">
        <xsl:variable name="spatial" select="normalize-space(.)"/>
        <xsl:variable name="coordinate_sequence" as="xs:string*">
            <xsl:if test="contains($spatial, 'coordinates')">
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

    <!-- Collection - Related Info Element - Services -->
    <xsl:template match="result" mode="collection_relatedInfo">
        <xsl:variable name="organizationTitle" select="organization/title"/>
        <!-- Related Services -->
        <xsl:for-each select="resources">
            <xsl:variable name="url" select="normalize-space(url)"/>
            <xsl:message select="concat('url: ', $url)"/>
            <xsl:if test="string-length($url)">
                <xsl:variable name="serviceUrl" select="custom:getServiceUrl(.)"/>
                <xsl:variable name="serviceName" select="custom:getServiceName($serviceUrl)"/>

                <xsl:choose>
                    <xsl:when test="string-length($serviceUrl) > 0">
                        <xsl:message select="concat('serviceUrl: ', $serviceUrl)"/>
                        <relatedInfo type="service">
                            <identifier type="uri">
                                <xsl:value-of select="$serviceUrl"/>
                            </identifier>
                            <relation type="supports">
                                <xsl:if test="string-length(name) > 0">
                                    <description>
                                        <xsl:value-of select="name"/>
                                    </description>
                                </xsl:if>
                                <xsl:if
                                    test="not(contains($url, '?')) or string-length(substring-after($url, '?')) > 0">
                                    <url>
                                        <xsl:choose>
                                            <xsl:when test="contains($url, '?')">
                                                <xsl:value-of select="substring-before($url, '?')"/> <!-- before trailing ? -->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$url"/>
                                    </xsl:otherwise>
                                        </xsl:choose>
                                    </url>
                                </xsl:if>
                            </relation>
                            <xsl:if
                                test="string-length($organizationTitle) > 0 or string-length($serviceName) > 0">
                                <title>
                                    <xsl:choose>
                                        <xsl:when test="string-length($serviceName)">
                                            <xsl:value-of
                                                select="concat($serviceName, ' for access to ', $organizationTitle, ' data')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat('Service for access to ', $organizationTitle, ' data')"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </title>
                            </xsl:if>
                        </relatedInfo>
                    </xsl:when>

<xsl:otherwise>
                        <xsl:message select="concat('no service url obtainable from url: ', $url)"/>
                        <xsl:if test="contains(lower-case(webstore_url), 'active')">
                            <relatedInfo type="service">
                                <xsl:variable name="id" select="normalize-space(id)"/>
                                <xsl:if test="string-length($id)">
                                    <identifier type="uri">
                                        <xsl:value-of
                                            select="concat($global_baseURI, 'api/3/action/datastore_search')"
                                        />
                                    </identifier>
                                </xsl:if>
                                <xsl:variable name="format" select="'Tabular data in JSON'"/>
                                <xsl:variable name="description">
                                    <xsl:choose>
                                        <xsl:when test="string-length(normalize-space(name))">
                                            <xsl:value-of
                                                select="concat(normalize-space(name), ' (',$format, ')')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('(',$format, ')')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="string-length(normalize-space(description))">
                                        <xsl:value-of
                                            select="concat(' ', normalize-space(description))"/>
                                    </xsl:if>
                                </xsl:variable>
                                <relation type="supports">
                                    <xsl:if test="string-length(normalize-space($description)) > 0">
                                        <description>
                                            <xsl:value-of select="$description"/>
                                        </description>
                                    </xsl:if>
                                    <url>
                                        <xsl:value-of
                                            select="concat($global_baseURI, 'api/3/action/datastore_search?resource_id=', $id)"
                                        />
                                    </url>
                                </relation>
                                <xsl:if
                                    test="string-length($organizationTitle) > 0 or string-length($serviceName) > 0">
                                    <title>
                                        <xsl:choose>
                                            <xsl:when test="string-length($serviceName)">
                                                <xsl:value-of
                                                  select="concat($serviceName, ' for access to ', $organizationTitle, ' data')"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="concat('Service at ', $global_baseURI)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </title>
                                </xsl:if>
                            </relatedInfo>

                        </xsl:if>
                        <!--location>
                            <address>
                                <electronic type="url" target="directDownload">
                 <value>
                                        <xsl:value-of select="normalize-space(url)"/>
                 </value>
                                    <xsl:if test="string-length(name) > 0">
                     <title>
                         <xsl:value-of select="name"/>
                     </title>
                 </xsl:if>
                 <xsl:if test="string-length(normalize-space(description))">
                                        <notes>
                                            <xsl:value-of select="normalize-space(description)"/>
                 </notes>
                     </xsl:if>
                         <xsl:if test="string-length(mimetype) > 0">
                             <mediaType>
                         <xsl:value-of select="mimetype"/>
                         </mediaType>
                     </xsl:if>
                 <xsl:if test="string-length(size) > 0">
                     <byteSize>
                         <xsl:value-of select="size"/>
                     </byteSize>
                 </xsl:if>
            </electronic>
        </address>
                        </location-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
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

                    <xsl:if test="string-length(normalize-space(image_url))">
                        <description>
                            <xsl:attribute name="type">
                                <xsl:text>logo</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(image_url)"/>
                        </description>
                    </xsl:if>

                    <xsl:if test="string-length(normalize-space(description))">
                        <description>
                            <xsl:attribute name="type">
                                <xsl:text>brief</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="custom:reformatHyperlinks(normalize-space(description))"/>
                        </description>
                    </xsl:if>
                    <!--xsl:for-each select="../resources">
                        <xsl:message>resources</xsl:message>
                        <xsl:variable name="serviceUrl" select="custom:getServiceUrl(.)"/>
                        <xsl:variable name="serviceName" select="custom:getServiceName($serviceUrl)"/>
                        <xsl:if test="string-length($serviceUrl) > 0">
                            <xsl:message select="concat('resources serviceUrl: ', $serviceUrl)"/>
                            <relatedInfo type="service">
                                <identifier type="uri">
                                    <xsl:value-of select="$serviceUrl"/>
                                </identifier>
                                <relation type="isManagerOf"/>
                                <xsl:if
                                    test="string-length($title) > 0 or string-length($serviceName) > 0">
                                    <title>
                                        <xsl:choose>
                                            <xsl:when test="string-length($serviceName)">
                                                <xsl:value-of
                                                  select="concat($serviceName, ' for access to ', $title, ' data')"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="concat('Service for access to ', $title, ' data')"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </title>
                                </xsl:if>
                            </relatedInfo>
                        </xsl:if>
                    </xsl:for-each-->

                </party>
            </registryObject>
        </xsl:if>
    </xsl:template>

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <!--xsl:template match="datasets/result" mode="party_author">
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
    </xsl:template-->

    <!-- ====================================== -->
    <!-- Service RegistryObject - Template -->
    <!-- ====================================== -->

    <!-- Service Registry Object -->
    <xsl:template match="result" mode="service">
        <xsl:variable name="organizationTitle" select="normalize-space(organization/title)"/>
        <xsl:variable name="organizationName" select="normalize-space(organization/name)"/>
        <xsl:variable name="organizationDescription"
            select="normalize-space(organization/description)"/>
        <xsl:variable name="serviceURI_sequence" as="xs:string*">
            <xsl:call-template name="getServiceURI_sequence">
                <xsl:with-param name="parent" select="."/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:for-each select="distinct-values($serviceURI_sequence)">
            <xsl:variable name="serviceURI" select="normalize-space(.)"/>
            <xsl:if test="string-length($serviceURI)">

                <registryObject group="{$global_group}">

                    <key>
                        <xsl:value-of select="$serviceURI"/>
                    </key>

                    <originatingSource>
                        <xsl:value-of select="$global_originatingSource"/>
                    </originatingSource>

                    <service type="webservice">

                        <identifier type="uri">
                            <xsl:value-of select="$serviceURI"/>
                        </identifier>

                        <xsl:variable name="serviceName" select="custom:getServiceName($serviceURI)"/>

                        <name type="primary">
                            <namePart>
                                <xsl:choose>
                                    <xsl:when test="string-length($serviceName)">
                                        <xsl:value-of
                                            select="concat($serviceName, ' for access to ', $organizationTitle, ' data')"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="concat('Service for access to ', $organizationTitle, ' data')"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </namePart>
                        </name>

                        <xsl:if test="string-length($organizationDescription)">
                            <description>
                                <xsl:attribute name="type">
                                    <xsl:text>brief</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="concat('Service for access to ', $organizationTitle, ' data - ',  $organizationDescription)"
                                />
                            </description>
                        </xsl:if>


                        <location>
                            <address>
                                <electronic>
                                    <xsl:attribute name="type">
                                        <xsl:text>url</xsl:text>
                                    </xsl:attribute>
                                    <value>
                                        <xsl:value-of select="$serviceURI"/>
                                    </value>
                                </electronic>
                            </address>
                        </location>

                        <xsl:if test="string-length($organizationName)">
                            <relatedInfo type="party">
                                <identifier type="uri">
                                    <xsl:value-of
                                        select="concat($global_baseURI,'organization/', $organizationName)"
                                    />
                                </identifier>
                            </relatedInfo>
                        </xsl:if>
                    </service>
                </registryObject>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Modules -->
    <xsl:template name="getServiceURI_sequence" as="xs:string*">
        <xsl:param name="parent"/>
        <xsl:for-each select="$parent/resources">
            <xsl:variable name="url" select="normalize-space(url)"/>
            <xsl:message select="concat('url: ', $url)"/>
            <xsl:if test="string-length($url)">
                <!--xsl:choose-->
                    <!-- Indicates parameters -->
                        <!--xsl:when test="contains($url, '?')"> 
                        <xsl:variable name="baseURL" select="substring-before($url, '?')"/>
                        <xsl:choose>
                            <xsl:when test="substring($baseURL, string-length($baseURL), 1) = '/'">
                                <xsl:value-of
                                    select="substring($baseURL, 1, string-length($baseURL)-1)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$baseURL"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when-->
                        <!--xsl:otherwise-->
                            <xsl:if test="contains(lower-case(normalize-space(resource_type)), 'api')">
                            <xsl:variable name="serviceUrl">
                                <xsl:choose>
                                    <xsl:when test="contains($url, '?')">
                                        <!-- Indicates parameters -->
                                        <xsl:variable name="baseURL"
                                            select="substring-before($url, '?')"/>
                                        <!-- obtain base url before '?' and parameters -->
                                        <xsl:choose>
                                            <xsl:when
                                                test="substring($baseURL, string-length($baseURL), 1) = '/'">
                                                <!-- remove trailing backslash if there is one -->
                                                <xsl:value-of
                                                  select="substring($baseURL, 1, string-length($baseURL)-1)"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$baseURL"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- retrieve url before file name and extension if there is one-->
                                        <xsl:value-of                                            select="string-join(tokenize($url,'/')[position()!=last()],'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:message select="concat('serviceUrl: ', $serviceUrl)"/>
                            <xsl:value-of select="$serviceUrl"/>
                        </xsl:if>
                    <!--/xsl:otherwise-->
                <!--/xsl:choose-->
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="collection_license">
        <xsl:param name="title"/>
        <xsl:param name="id"/>
        <xsl:param name="url"/>
        <rights>
            <licence>
                <xsl:attribute name="type">
                    <xsl:value-of select="upper-case($id)"/>
                </xsl:attribute>
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="$url"/>
                </xsl:attribute>
                <xsl:value-of select="$title"/>
            </licence>
        </rights>
    </xsl:template>

    <xsl:function name="custom:getServiceName">
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
    </xsl:function>
    
    <xsl:function name="custom:sequenceContains">
        <xsl:param name="sequence"/>
        <xsl:param name="string"/>
        <xsl:for-each select="distinct-values($sequence)">
            <xsl:if test="contains(., $string)">
                <xsl:copy-of select="true()"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Change input from:
            [link-text](http://link)
         to:
            <a href="http://link">link-text</a>  
    -->
    <xsl:function name="custom:reformatHyperlinks">
        <xsl:param name="input"/>
        <xsl:analyze-string regex="(\[[^\]]*\])(\([^\)]*\))" select="$input">
            <xsl:matching-substring>
                <xsl:variable name="text" select="regex-group(1)"/>
                <xsl:variable name="link" select="regex-group(2)"/>
                <xsl:if test="(string-length($text) > 0) and (string-length($link) > 0)">
                    <xsl:value-of select="concat('&lt;a href=&quot;', substring($link, 2, string-length($link)-2), '&quot;&gt;', substring($text, 2, string-length($text)-2), '&lt;/a&gt;')"/>
                </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy-of select="."/>  
            </xsl:non-matching-substring> 
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="custom:getServiceUrl">
        <xsl:param name="resources"/>
        <xsl:variable name="url" select="$resources/url"/>
        <xsl:message select="concat('getServiceUrl url: ', $url)"/>
        <!--xsl:choose-->
            <!-- Indicates parameters -->
                <!--xsl:when test="contains($url, '?')">
                <xsl:variable name="baseURL" select="substring-before($url, '?')"/>
                <xsl:choose>
                    <xsl:when test="substring($baseURL, string-length($baseURL), 1) = '/'">
                        <xsl:value-of select="substring($baseURL, 1, string-length($baseURL)-1)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$baseURL"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when-->
                <!--xsl:otherwise-->
                    <xsl:if
                    test="contains(lower-case(normalize-space($resources/resource_type)), 'api')">
                    <xsl:choose>
                        <xsl:when test="contains($url, '?')">
                            <!-- Indicates parameters -->
                            <xsl:variable name="baseURL" select="substring-before($url, '?')"/>
                            <!-- obtain base url before '?' and parameters -->
                            <xsl:choose>
                                <xsl:when
                                    test="substring($baseURL, string-length($baseURL), 1) = '/'">
                                    <!-- remove trailing backslash if there is one -->
                                    <xsl:value-of
                                        select="substring($baseURL, 1, string-length($baseURL)-1)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$baseURL"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- retrieve url before file name and extension if there is one-->
                            <xsl:value-of
                                select="string-join(tokenize($url,'/')[position()!=last()],'/')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            <!--/xsl:otherwise-->
        <!--/xsl:choose-->
    </xsl:function>
</xsl:stylesheet>
