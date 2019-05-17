<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
    exclude-result-prefixes="xs">
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    <xsl:template match="node()|@*">
        <xsl:message select="concat('Name: ', name(.), ' - Parent: ', name(parent::*))"/>
        
        <xsl:if test="name(.) = 'registryObject'">
            <xsl:message select="concat('num dois: ', count(collection/identifier[@type='doi']))"/>
        </xsl:if>
        <xsl:if test="not(name(.) = 'registryObject') or count(collection/identifier[@type='doi']) > 0">
            <xsl:choose>
                <xsl:when test="(name(.) = 'value') and (name(parent::*) = 'electronic')">
                    <value>
                        <xsl:value-of select="ancestor::collection/identifier[@type='doi']"/>
                    </value>
                </xsl:when>
                <xsl:when test="not(name(.) = 'identifier') or not(contains(., 'epublications.bond.edu.au'))">
                        
                        <xsl:if test="(name(.) = 'name') and (count(ancestor::collection/description) = 0)">
                            <description type="brief">
                                <xsl:value-of select="."/>
                            </description>
                        </xsl:if>
                       
                        <xsl:copy>
                            <xsl:apply-templates select="node()|@*"/>
                        </xsl:copy>
                </xsl:when>
            </xsl:choose>
          
                
        </xsl:if>
    </xsl:template>
 
</xsl:stylesheet>
