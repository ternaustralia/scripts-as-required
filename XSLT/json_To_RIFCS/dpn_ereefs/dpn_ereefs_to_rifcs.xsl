<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:localFunc="http://www.localfunc.net"
    xmlns:local="http://local.to.here"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <!-- stylesheet to convert http://data.ereefs.info xml (transformed from json with python script) to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_originatingSource" select="'http://data.ereefs.info'"/>
    <xsl:param name="global_baseURL" select="'http://http://data.ereefs.info/data/'"/>
    <xsl:param name="global_group" select="'eReefs Research'"/>
    <xsl:param name="global_contributor" select="'http://data.ereefs.info'"/>
    <xsl:param name="global_publisherName" select="'http://data.ereefs.info'"/>
    <xsl:param name="global_publisherPlace" select="'ereefs'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
     <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:for-each select="//datasets">
                
                    <xsl:apply-templates select="." mode="collection"/>
            </xsl:for-each>
             
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="datasets" mode="collection">
       
        <xsl:variable name="datasetId" select="local:getDistinctValue(dataset_id)"/>
        <xsl:message select="concat('datasetId param: ', $datasetId)"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="custom:registryObjectKeyFromString($datasetId)"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource> 
                
            <collection>
                <xsl:attribute name="type" select="'dataset'"/>
                <identifier type="uri">
                    <xsl:value-of select="$datasetId"/>
                </identifier>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="local:getDistinctValue(dpn_info/dataset)"/>
                    </namePart>
                </name>
                
               <description type="full">
                    <xsl:variable name="total" select="count(distinct-values(description))" as="xs:integer"/>
                    <xsl:for-each select="distinct-values(description)">
                        
                        <xsl:value-of select="."/>
                        <xsl:if test="(position() &lt; $total)">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </description>
                
                <rights>
                    <rightsStatement>
                        <xsl:variable name="total" select="count(distinct-values(rights))" as="xs:integer"/>
                        <xsl:for-each select="distinct-values(rights)">
                            <xsl:value-of select="."/>
                            <xsl:if test="(position() &lt; $total)">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </rightsStatement>
                </rights>
                
                
                <xsl:for-each select="distinct-values(variable)">
                    <subject type="local">
                        <xsl:value-of select="."/>
                    </subject>
                </xsl:for-each>
                
                <xsl:for-each-group select="bounding_box" group-by="coordinates">
                    <xsl:variable name="coords" select="normalize-space(current-grouping-key())"/>
                    <xsl:variable name="coords_sequence" select="tokenize($coords,' ')"/>
                    <xsl:variable name="total" select="count($coords_sequence)" as="xs:integer"/>
                    <xsl:if test="count($coords_sequence) > 0">
                     <coverage>
                         <spatial type="gmlKmlPolyCoords">
                             <xsl:for-each select="$coords_sequence">
                                 <xsl:value-of select="."/>
                                 <xsl:if test="(position() &lt; $total)">
                                     <xsl:choose>
                                         <xsl:when test="(position() mod 2 = 0)">
                                             <xsl:text> </xsl:text>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:text>,</xsl:text>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:if>
                             </xsl:for-each>
                         </spatial>
                     </coverage>
                    </xsl:if>
                </xsl:for-each-group>
                
                
                
                <xsl:for-each-group select="access" group-by="type">
                    <xsl:for-each select="distinct-values(access)">
                        <relatedInfo type="service">
                            <identifier type="uri"><xsl:value-of select="."/></identifier>
                        <relation type="supports">
                            <url><xsl:value-of select="."/></url>
                         </relation>
                        <title>
                            <xsl:value-of select="current-grouping-key()"/>
                        </title>
                         
                        </relatedInfo>
                    </xsl:for-each>
                 </xsl:for-each-group>
                
                <xsl:for-each select="distinct-values(dpn_info/organisation)">
                    <relatedInfo type="party">
                        <identifier type="uri">
                            <xsl:value-of select="."/>
                        </identifier> 
                        <relation type="hasCollector"/>
                     </relatedInfo>
                </xsl:for-each>
                
                <xsl:for-each-group select="contacts" group-by="type">
                    <xsl:for-each select="distinct-values(url)">
                        <relatedInfo type="party">
                            <identifier type="uri">
                                <xsl:value-of select="."/>
                            </identifier>
                            <relation type="{current-grouping-key()}"/>
                        </relatedInfo>
                    </xsl:for-each>
                </xsl:for-each-group>
                
            </collection>
        </registryObject>
    </xsl:template>
    
    <xsl:function name="local:getDistinctValue">
        <xsl:param name="value_sequence" as="node()*"/>
        <xsl:variable name="value_distinct_sequence">
            <xsl:for-each select="distinct-values($value_sequence)">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:message select="concat('Expecting 1 value, found ', count($value_distinct_sequence))"/>
        
        <!-- custom assertion -->
        <xsl:message select="concat('Assert if count of value_distinct_sequence is greater than 1: ', $value_distinct_sequence )"/>
        
        <xsl:choose>
            <xsl:when test="count($value_distinct_sequence) = 1">
                <xsl:value-of select="$value_distinct_sequence[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
   
</xsl:stylesheet>

