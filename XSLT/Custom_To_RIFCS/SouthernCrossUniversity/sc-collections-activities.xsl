<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:custom="http://custom.nowhere.yet"
    version="2.0" exclude-result-prefixes="dc">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record" mode="collection"/>
        </registryObjects>
    </xsl:template>

   
    <xsl:template match="oai:record" mode="collection">
        <xsl:variable name="key" select="oai:header/oai:identifier"/>
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="oai:metadata/oai_dc:dc/dc:type"/>
        <xsl:variable name="group" select="'Southern Cross University'"/>
        <xsl:variable name="originatingSource" select="'Southern Cross University'"/>
        
        <xsl:if test="string-length($key) > 0">
            <registryObject>
                <xsl:attribute name="group" select="$group"/>
                <key>
                    <xsl:value-of select="$key"/>
                </key>
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource>
                <xsl:element name="{$class}">
    
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="$type = 'Data'">
                                <xsl:text>dataset</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$type"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
    
                    <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="collection"/>
                    <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="party"/>
    
                </xsl:element>
            </registryObject>
        </xsl:if>
    </xsl:template>



    <xsl:template match="oai_dc:dc" mode="collection">
        
        <!-- identifier -->
        <xsl:for-each select="dc:identifier">
            <xsl:variable name="identifierAllContent" select="."/>
            <xsl:variable name="identifierExtracted_sequence" as="xs:string*">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($identifierAllContent), 'http')">
                        <xsl:analyze-string select="normalize-space($identifierAllContent)"
                            regex="http:[^&quot;]*">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(0)"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$identifierAllContent"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:message select="concat('identifierAllContent: ', $identifierAllContent)"></xsl:message>\
            <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                <xsl:message select="concat('identifierExtracted: ', .)"></xsl:message>
            </xsl:for-each>
            <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                <xsl:variable name="identifierType" select="custom:identifierType(.)"></xsl:variable>
                <xsl:if test="string-length(.) > 0">
                     <identifier type="{$identifierType}">
                         <xsl:value-of select="."/>
                     </identifier>
                </xsl:if>
            </xsl:for-each>
            
        </xsl:for-each>
        
        <xsl:if test="string-length(dc:title) > 0">
            <name type="full">
                <namePart>
                    <xsl:value-of select="dc:title"/>
                </namePart>
            </name>
        </xsl:if>
        
        <xsl:if test="string-length(dc:description.abstract) > 0">
            <description type="full">
                <xsl:value-of select="dc:description.abstract"/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="custom:identifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>uri</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    

    <xsl:template match="node() | text() | @*"/>

</xsl:stylesheet>
