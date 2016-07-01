<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    <!-- stylesheet to convert data.wa.gov.au xml (transformed from json with python script) to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_originatingSource" select="'http://catalogue.beta.data.wa.gov.au'"/>
    <xsl:param name="global_baseURI" select="'http://catalogue.beta.data.wa.gov.au/'"/>
    <xsl:param name="global_group" select="'data.wa.gov.au'"/>
   
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="datasets/help"/>
    <xsl:template match="datasets/success"/>

    <!-- =========================================== -->
    <!-- dataset (datasets) Template             -->
    <!-- =========================================== -->

    <xsl:template match="datasets">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="result" mode="collection"/>
            <xsl:apply-templates select="result" mode="party"/>
        </registryObjects>
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

                <xsl:apply-templates select="tags" mode="collection_subject"/>

                <xsl:apply-templates select="notes" mode="collection_description"/>

                <xsl:apply-templates select="spatial_coverage" mode="collection_coverage_spatial"/>

                <xsl:apply-templates select="isopen" mode="collection_rights_accessRights"/>

                <xsl:call-template name="collection_license">
                    <xsl:with-param name="title" select="license_title"/>
                    <xsl:with-param name="id" select="license_id"/>
                    <xsl:with-param name="url" select="license_url"/>
                </xsl:call-template>

            </collection>

        </registryObject>
    </xsl:template>

    <!-- =========================================== -->
    <!-- Party RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="result" mode="party">
        <xsl:apply-templates select="organization"/>
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

    <!-- Collection - Decription (brief) Element -->
    <xsl:template match="notes" mode="collection_description">
        <xsl:if test="string-length(normalize-space(.))">
            <description type="brief">
                <xsl:value-of select="normalize-space(.)"/>
            </description>
        </xsl:if>
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
                            <xsl:value-of select="normalize-space(description)"/>
                        </description>
                    </xsl:if>
                </party>
            </registryObject>
        </xsl:if>
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

   </xsl:stylesheet>
