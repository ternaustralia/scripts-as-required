<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:custom="http://nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="ro">
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()[ancestor::field and not(self::text())]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="/">
       
        <xsl:text>title</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>fulltext_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>keywords</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>abstract</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_fname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_mname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_lname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_suffix</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_email</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_institution</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author1_is_corporate</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_fname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_mname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_lname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_suffix</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_email</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_institution</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author2_is_corporate</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_fname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_mname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_lname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_suffix</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_email</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_institution</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author3_is_corporate</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_fname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_mname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_lname</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_suffix</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_email</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_institution</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>author4_is_corporate</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>access</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>book_series</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>disciplines</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>chapter_title</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>comments</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>conference_name</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>create_openurl</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>custom_citation</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>document_type</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>doi</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>editor1</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>editor2</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>editor3</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>embargo_date</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>extent</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>faculty</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>for</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>fpage</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>grantid</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>isbn</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>issn</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>issnum</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>lpage</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>metadata_only</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>multimedia_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>multimedia_format</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>orcid_id</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>performance_location</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>publication_date</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>publisher</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>publisher_location</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>rmid</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>source_fulltext_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>source_publication</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>volnum</xsl:text>
    
        <xsl:message select="concat('result: ', count(//ro:registryObject[ro:collection]))"></xsl:message>
        
        
        <xsl:apply-templates select="//ro:registryObject[ro:collection]"/>
    
    </xsl:template>
    
    
    <xsl:template match="ro:registryObject[ro:collection]">
       
        <xsl:text>&#xa;</xsl:text>
        <!--	column: title	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="ro:collection/ro:name[@type = 'primary']/ro:namePart"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: fulltext_url	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: keywords	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:variable name="total" select="count(ro:collection/ro:subject[@type = 'local'])" as="xs:integer"/>
        <xsl:for-each select="ro:collection/ro:subject[@type = 'local']">
            <xsl:value-of select="."/>
            <xsl:if test="position() &lt; $total">
                <xsl:value-of select="$valueSeparator"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: abstract	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:variable name="abstract">
            <xsl:choose>
                <xsl:when test="string-length(ro:collection/ro:description[@type = 'full']) > 0">
                    <xsl:value-of select="ro:collection/ro:description[@type = 'full']"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:description[@type = 'brief']) > 0">
                    <xsl:value-of select="ro:collection/ro:description[@type = 'brief']"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:description[@type = 'notes']) > 0">
                    <xsl:value-of select="ro:collection/ro:description[@type = 'notes']"/>   
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$abstract" disable-output-escaping="yes"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_fname (mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'given'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_mname	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_lname (mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'family'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_suffix	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'title'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_email	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_institution	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'superior'"/>
            <xsl:with-param name="sequence" select="1"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author1_is_corporate	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_fname	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'given'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_mname	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_lname	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'family'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_suffix	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'title'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_email	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_institution	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'superior'"/>
            <xsl:with-param name="sequence" select="2"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author2_is_corporate	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_fname	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'given'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_mname	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_lname	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'family'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_suffix	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'title'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_email	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_institution	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="relatedObjectValue">
            <xsl:with-param name="relatedObjectType" select="'party'"/>
            <xsl:with-param name="attribute" select="'superior'"/>
            <xsl:with-param name="sequence" select="3"/>
        </xsl:call-template>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author3_is_corporate	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author4_fname	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author4_mname	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author4_lname	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author4_suffix	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author4_email	-->
        <xsl:value-of select="$columnSeparator"/>
       
        <!--	column: author4_institution	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: author4_is_corporate	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: access	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="ro:collection/ro:rights/ro:accessRights"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: book_series	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: disciplines	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: chapter_title	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: comments	-->
        <xsl:value-of select="$columnSeparator"/>
       
        <!--	column: conference_name	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: create_openur	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: custom_citation	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: document_type	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: doi	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="ro:collection/ro:identifier[@type = 'doi']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: editor1	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: editor2	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: editor3	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: embargo_date (mandatory) -->
        <xsl:text>0</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: extent	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: faculty	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: for	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:variable name="total" select="count(ro:collection/ro:subject[@type = 'anzsrc-for'])" as="xs:integer"/>
        <xsl:for-each select="ro:collection/ro:subject[@type = 'anzsrc-for']">
            <xsl:value-of select="."/>
            <xsl:if test="position() &lt; $total">
                <xsl:value-of select="$valueSeparator"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: fpage	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: grantid	-->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="ro:collection/ro:relatedObject[contains(ro:key, 'purl.org/au-research/grants')]/ro:key"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: isbn	-->
        <xsl:value-of select="$columnSeparator"/>
       
        <!--	column: issn	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: issnum	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: lpage	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: metadata_only	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: multimedia_url	-->
        <xsl:value-of select="$columnSeparator"/>
       
        <!--	column: multimedia_format	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: orcid_id	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: performance_location	-->
        <xsl:value-of select="$columnSeparator"/>
       
        <!--	column: publication_date (mandatory) -->
        <xsl:variable name="publicationDate">
            <xsl:choose>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'issued')]/ro:date[contains(lower-case(@type),'from')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'issued')]/ro:date[contains(lower-case(@type),'from')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'issued')]/ro:date[contains(lower-case(@type),'to')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'issued')]/ro:date[contains(lower-case(@type),'to')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:citationInfo/ro:citationMetadata/ro:date[@type='publicationDate']) > 0">
                    <xsl:value-of select="ro:collection/ro:citationInfo/ro:citationMetadata/ro:date[@type='publicationDate']"/>
                </xsl:when>
                <xsl:when test="string-length(ro:collection/@dateAccessioned) > 0">
                    <xsl:value-of select="ro:collection/@dateAccessioned"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'accepted')]/ro:date[contains(lower-case(@type),'from')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'accepted')]/ro:date[contains(lower-case(@type),'from')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'accepted')]/ro:date[contains(lower-case(@type),'to')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'accepted')]/ro:date[contains(lower-case(@type),'to')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'submitted')]/ro:date[contains(lower-case(@type),'from')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'submitted')]/ro:date[contains(lower-case(@type),'from')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'submitted')]/ro:date[contains(lower-case(@type),'to')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'submitted')]/ro:date[contains(lower-case(@type),'to')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'created')][1]/ro:date[contains(lower-case(@type),'from')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'created')]/ro:date[contains(lower-case(@type),'from')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'created')]/ro:date[contains(lower-case(@type),'to')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'created')]/ro:date[contains(lower-case(@type),'to')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'available')]/ro:date[contains(lower-case(@type),'from')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'available')]/ro:date[contains(lower-case(@type),'from')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'available')]/ro:date[contains(lower-case(@type),'to')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'available')]/ro:date[contains(lower-case(@type),'to')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'valid')]/ro:date[contains(lower-case(@type),'from')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'valid')]/ro:date[contains(lower-case(@type),'from')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/ro:dates[contains(lower-case(@type), 'valid')]/ro:date[contains(lower-case(@type),'to')]) > 0">
                    <xsl:value-of select="ro:collection/ro:dates[contains(lower-case(@type), 'valid')]/ro:date[contains(lower-case(@type),'to')]"/>   
                </xsl:when>
                <xsl:when test="string-length(ro:collection/@dateModified) > 0">
                    <xsl:value-of select="ro:collection/@dateModified"/>   
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="publicationDateNoTime">
            <xsl:if test="string-length($publicationDate) > 0">
                <xsl:choose>
                    <xsl:when test="contains($publicationDate, 'T')">
                        <xsl:value-of select="substring-before($publicationDate, 'T')"/> 
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$publicationDate"/>   
                    </xsl:otherwise>
                </xsl:choose>     
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($publicationDateNoTime) = 7">
                <!-- year and month without day not accepted so stripping month where we don't have day rather than making up a day (ok??) -->
                <xsl:value-of select="substring($publicationDateNoTime, 1, 4)"/>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$publicationDateNoTime"/>  
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: publisher	-->
        <xsl:value-of select="ro:collection/ro:citationInfo/ro:citationMetadata/ro:publisher"/>
        <xsl:value-of select="$columnSeparator"/>
       
        <!--	column: publisher_location	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: rmid	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: source_fulltext_url	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: source_publication	-->
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: volnum	-->
        
        <!-- NewLine-->
        
    </xsl:template>
    
    <xsl:template name="relatedObjectValue" as="xs:string*">
        <xsl:param name="relatedObjectType" as="xs:string"/>
        <xsl:param name="attribute"  as="xs:string"/>
        <xsl:param name="sequence" as="xs:integer"/>
       
        <!--xsl:message select="concat('name() :', ro:collection/name())"/-->
        <xsl:variable name="relatedKeyForType_sequence" select="ro:collection/ro:relatedObject[contains(ro:key, concat('acu.edu.au/', $relatedObjectType))]"/>
        <!--xsl:message select="concat('count($relatedParty_sequence) :', count($relatedParty_sequence))"/-->
        <xsl:if test="count($relatedKeyForType_sequence) > ($sequence - 1)">
            <xsl:variable name="value_sequence" select="ancestor::ro:registryObjects/ro:registryObject[ro:key = $relatedKeyForType_sequence[$sequence]]/*[contains(local-name(), $relatedObjectType)]/ro:name[@type = 'primary']/ro:namePart[@type = $attribute]"/>
            <xsl:for-each select="distinct-values($value_sequence)">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>
