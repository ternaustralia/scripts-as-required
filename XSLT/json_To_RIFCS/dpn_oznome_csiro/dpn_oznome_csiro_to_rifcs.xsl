<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:localFunc="http://www.localfunc.net"
    xmlns:local="http://local.to.here"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <!-- stylesheet to convert http://databroker.oznome.csiro.au' xml (transformed from json with python script) to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_originatingSource" select="'http://databroker.oznome.csiro.au'"/>
    <xsl:param name="global_baseURL" select="'http://databroker.oznome.csiro.au'"/>
    <xsl:param name="global_group" select="'OzNome'"/>
    <xsl:param name="global_contributor" select="'http://databroker.oznome.csiro.au'"/>
    <xsl:param name="global_publisherName" select="'http://databroker.oznome.csiro.au'"/>
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
        
        <xsl:variable name="datasetsNode" select="." as="node()"/>
        
        <xsl:for-each select="distinct-values(dataset_id)">
            
            <xsl:variable name="position" select="position()" as="xs:integer"/>
            
            <xsl:variable name="datasetId" select="."/>
            <xsl:message select="concat('datasetId: ', $datasetId)"/>
            <xsl:message select="concat('position: ', $position)"/>
            <xsl:message select="concat('datasetsNode: ', $datasetsNode)"/>
            
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
                    <xsl:value-of select="."/>
                </identifier>
                
                <xsl:variable name="datasetId_tokenized" select="tokenize($datasetId, '/')"/>
                <xsl:variable name="total" select="count($datasetId_tokenized)" as="xs:integer"/>
                <xsl:choose>
                    <xsl:when test="count($datasetId_tokenized) > 0">
                        <xsl:variable name="datasetName" select="$datasetId_tokenized[$total]"/>
                        <xsl:choose>
                             <xsl:when test="contains($datasetName, '.')">
                                 <name type="primary">
                                     <namePart>
                                            <xsl:value-of select="substring-before($datasetName, '.')"/>
                                     </namePart>
                                 </name>
                             </xsl:when>
                             <xsl:otherwise>
                                 <name type="primary">
                                     <namePart>
                                        <xsl:value-of select="$datasetName"/>
                                     </namePart>
                                 </name>
                             </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="distinct-values($datasetsNode/dpn_info[following-sibling::dataset_id[1] =  $datasetId]/dataset)">
                            <name type="primary">
                                <namePart>
                                    <xsl:value-of select="."/>
                                </namePart>
                            </name>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                    
                <xsl:variable name="total" select="count(distinct-values($datasetsNode/description[following-sibling::dataset_id[1] =  $datasetId]))" as="xs:integer"/>
                <description type="full">
                    <xsl:for-each select="distinct-values($datasetsNode/description[following-sibling::dataset_id[1] =  $datasetId])">
                        <xsl:value-of select="."/>
                        <xsl:if test="(position() &lt; $total)">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                   </xsl:for-each>
                </description>
                
                <xsl:for-each select="distinct-values($datasetsNode/variable[following-sibling::dataset_id[1] =  $datasetId])">
                    <subject type="local">
                        <xsl:value-of select="."/>
                    </subject>
                </xsl:for-each>
                
                <xsl:for-each-group select="$datasetsNode/bounding_box[following-sibling::dataset_id[1] =  $datasetId]" group-by="coordinates">
                    <xsl:variable name="coords" select="normalize-space(current-grouping-key())"/>
                    <xsl:variable name="coords_sequence" select="tokenize($coords,' ')"/>
                    <xsl:variable name="total" select="count($coords_sequence)" as="xs:integer"/>
                    <xsl:if test="count($coords_sequence) > 0">
                        <coverage>
                            <spatial type="gmlKmlPolyCoords">
                                <xsl:variable name="spatialString">
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
                                </xsl:variable>
                                <xsl:value-of select="$spatialString"/>
                            </spatial>
                        </coverage>
                    </xsl:if>
                </xsl:for-each-group>
                
             
                <xsl:for-each-group select="$datasetsNode/access[following-sibling::dataset_id[1] =  $datasetId]" group-by="type">
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
                
                <xsl:for-each select="distinct-values($datasetsNode/dpn_info[following-sibling::dataset_id[1] =  $datasetId]/organisation)">
                    <relatedInfo type="party">
                        <identifier type="uri">
                            <xsl:value-of select="."/>
                        </identifier> 
                        <relation type="hasCollector"/>
                     </relatedInfo>
                </xsl:for-each>
                
                <xsl:for-each select="$datasetsNode/contacts[following-sibling::dataset_id[1] =  $datasetId]">
                         <relatedInfo type="party">
                            <identifier type="uri">
                                <xsl:value-of select="url"/>
                            </identifier>
                            <relation type="type"/>
                        </relatedInfo>
                </xsl:for-each>
  
            </collection>
        </registryObject>
        </xsl:for-each>
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

