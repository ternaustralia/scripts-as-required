<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:custom="http://nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="ro">
    
    
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>  
    
    <xsl:template match="/">
        <xsl:text>header here</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template match="ro:registryObject"/>
    
       
    <xsl:template match="ro:registryObject[ro:collection]">
        
        <!--	column: title	(mandatory) -->
        <xsl:value-of select="ro:collection/ro:name[@type = 'primary']/ro:namePart"/>
        <xsl:text>|</xsl:text>
        
        <!--	column: fulltext_url	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: keywords	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: abstract	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_fname (mandatory) -->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'given'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_mname	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_lname (mandatory) -->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'family'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_suffix	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'title'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_email	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_institution	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author1_is_corporate	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_fname	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'given'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_mname	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_lname	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'family'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_suffix	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'title'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_email	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_institution	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author2_is_corporate	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_fname	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'given'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_mname	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_lname	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'family'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_suffix	-->
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'title'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_email	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_institution	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author3_is_corporate	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author4_fname	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author4_mname	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author4_lname	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author4_suffix	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author4_email	-->
        <xsl:text>|</xsl:text>
       
        <!--	column: author4_institution	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: author4_is_corporate	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: access	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: book_series	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: disciplines	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: chapter_title	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: comments	-->
        <xsl:text>|</xsl:text>
       
        <!--	column: conference_name	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: create_openurl	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: custom_citation	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: document_type	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: doi	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: editor1	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: editor2	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: editor3	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: embargo_date (mandatory) -->
        <xsl:text>|</xsl:text>
        
        <!--	column: extent	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: faculty	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: for	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: fpage	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: grantid	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: isbn	-->
        <xsl:text>|</xsl:text>
       
        <!--	column: issn	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: issnum	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: lpage	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: metadata_only	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: multimedia_url	-->
        <xsl:text>|</xsl:text>
       
        <!--	column: multimedia_format	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: orcid_id	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: performance_location	-->
        <xsl:text>|</xsl:text>
       
        <!--	column: publication_date (mandatory) -->
        <xsl:text>|</xsl:text>
        
        <!--	column: publisher	-->
        <xsl:text>|</xsl:text>
       
        <!--	column: publisher_location	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: rmid	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: source_fulltext_url	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: source_publication	-->
        <xsl:text>|</xsl:text>
        
        <!--	column: volnum	-->
        
        <!-- NewLine-->
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    <xsl:template name="relatedObjectValue" as="xs:string*">
        <xsl:param name="relatedObjectType" as="xs:string"/>
        <xsl:param name="attribute"  as="xs:string"/>
        <xsl:param name="sequence" as="xs:integer"/>
       
        <!--xsl:message select="concat('name() :', ro:collection/name())"/-->
        <xsl:variable name="relatedParty_sequence" select="ro:collection/ro:relatedObject[contains(ro:key, concat('acu.edu.au/', $relatedObjectType))]"/>
        <!--xsl:message select="concat('count($relatedParty_sequence) :', count($relatedParty_sequence))"/-->
        <xsl:if test="count($relatedParty_sequence) > ($sequence - 1)">
            <xsl:variable name="givenName_sequence" select="ancestor::ro:registryObjects/ro:registryObject[contains(ro:key,$relatedParty_sequence[$sequence])]/*[contains(local-name(), $relatedObjectType)]/ro:name/ro:namePart[@type = $attribute]"/>
            <xsl:for-each select="distinct-values($givenName_sequence)">
                <xsl:value-of select="."/>
                <xsl:if test="position() &lt; count($givenName_sequence)">
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>