<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:custom="http://custom.nowhere.yet"
    exclude-result-prefixes="custom">
    
    <xsl:function name="custom:sequenceContains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="str" as="xs:string"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="contains(lower-case(.), lower-case($str))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:strContainsSequenceSubset" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:param name="sequence" as="xs:string*"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="contains(lower-case($str), lower-case(.))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>

    <xsl:function name="custom:sequenceContainsExact" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="str" as="xs:string"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="(lower-case(.) = lower-case($str))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
     <xsl:function name="custom:convertLongitude">
        <xsl:param name="input" as="xs:decimal"/>
        <!--Convert Longitude 0-360 to -180 to 180 or 180W-180E -->
        <xsl:value-of select="(($input+180) mod 360)-180"/>
    </xsl:function>
    
    <xsl:function name="custom:getIdentifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi.org')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'http')">
                <xsl:text>uri</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'uuid')">
                <xsl:text>global</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>local</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
    
    <xsl:function name="custom:getDomainFromURL" as="xs:string">
        <xsl:param name="url"/>
        <!--xsl:value-of select="substring-before(':', (substring-before('/', (substring-after('://', $url)))))"/-->
        <xsl:choose>
            <xsl:when test="contains($url, '://')">
                <xsl:variable name="prefix" select="substring-before($url, '://')"/>
                <xsl:variable name="remaining" select="substring-after($url, '://')"/>
                <xsl:variable name="domainAndPerhapsPort">
                    <xsl:choose>
                        <xsl:when test="contains($remaining, '/')">
                            <xsl:value-of select="substring-before($remaining, '/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$remaining"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($domainAndPerhapsPort, ':')">
                        <xsl:value-of select="concat($prefix, '://', substring-before($domainAndPerhapsPort, ':'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($prefix, '://', $domainAndPerhapsPort)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('http://', $url)"/>
            </xsl:otherwise>
        </xsl:choose>
        <!--xsl:value-of select="substring-before(substring-before((substring-after($url, '://')), '/'), ':')"/-->
    </xsl:function>
    
    <xsl:function name="custom:convertCoordinatesLatLongToLongLat" as="xs:string">
        <xsl:param name="coordinates" as="xs:string"/>
        <!--  (?![\s|^|,])[\d\.-]+-->
        <xsl:variable name="coordinateSequence" as="xs:string*">
            <xsl:analyze-string select="$coordinates" regex="[\d\.-]+">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(0)"/>
                    <xsl:message select="concat('match: ', regex-group(0))"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:variable name="latCoords" as="xs:string*">
            <xsl:for-each select="$coordinateSequence">
                <xsl:if test="(position() mod 2) > 0">
                    <xsl:value-of select="."/>    
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="longCoords" as="xs:string*">
            <xsl:for-each select="$coordinateSequence">
                <xsl:if test="(position() mod 2) = 0">
                    <xsl:value-of select="."/>    
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:message select="concat('longCoords ', string-join(for $i in $longCoords return $i, ' '))"/>
        <xsl:message select="concat('latCoords ', string-join(for $i in $latCoords return $i, ' '))"/>
        
        <xsl:variable name="coordinatePair_sequence" as="xs:string*">
            <xsl:for-each select="$longCoords">
                <xsl:if test="count($latCoords) > position()">
                    <xsl:variable name="index" select="position()" as="xs:integer"/>
                    <xsl:value-of select="concat(., ',', normalize-space($latCoords[$index]))"/>
                </xsl:if>
            </xsl:for-each> 
        </xsl:variable>
        
        <xsl:choose>    
            <xsl:when test="count($coordinatePair_sequence) > 0"> 
                <xsl:message select="concat('finalstring ', string-join(for $i in $coordinatePair_sequence return $i, ' '))"/>
                <xsl:value-of select="string-join(for $i in $coordinatePair_sequence return $i, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:formatName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="contains($name, ', ')">
                <xsl:value-of select="concat(normalize-space(substring-after(substring-before($name, '.'), ',')), ' ', normalize-space(substring-before($name, ',')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:registryObjectKeyFromString" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
        <xsl:variable name="buffer" select="string-join(for $n in fn:string-to-codepoints($input) return string($n), '')"/>
        <xsl:choose>
            <xsl:when test="string-length($buffer) &gt; 50">
                <xsl:value-of select="substring($buffer, string-length($buffer)-50, 50)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$buffer"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
