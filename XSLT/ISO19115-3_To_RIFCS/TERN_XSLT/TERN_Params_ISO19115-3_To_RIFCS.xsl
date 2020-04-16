<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
  xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
  xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
  xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
  xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
  xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
  xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
  xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
  xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
  xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
  xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
  xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
  xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/1.0"
  xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
  xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:custom="http://custom.nowhere.yet"
  xmlns:gaFunc="http://gafunc.nowhere.yet"
  xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
  exclude-result-prefixes="csw gaFunc oai lan mrc xlink srv mrd geonet mas mri mcc mrl xs mco mrs xsi mda msr mdb mds mdq cat mdt mac cit mex gco gcx mmi gmx gex mpc gml custom">


  <xsl:import href="rifcs/ISO19115-3_To_RIFCS.xsl"/>

  <!-- <xsl:param name="global_debug" select="true()" as="xs:boolean"/> -->
  <!-- <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/> -->
  <xsl:param name="global_originatingSource" select="'Terrestrial Ecosystem Research Network (TERN)'"/>
  <xsl:param name="global_acronym" select="'TERN'"/>
  <xsl:param name="global_baseURI" select="'geonetwork.tern.org.au'"/>
  <xsl:param name="global_baseURI_PID" select="'pid.tern.org.au'"/>
  <xsl:param name="global_path_PID" select="'/dataset/tern/'"/>
  <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
  <xsl:param name="global_group" select="'Terrestrial Ecosystem Research Network'"/>
  <xsl:param name="global_publisherName" select="'Terrestrial Ecosystem Research Network (TERN)'"/>
  <xsl:param name="global_publisherPlace" select="'Australia'"/>

  <!-- =========================================== -->
  <!-- RegistryObject RegistryObject - Related Party Templates -->
  <!-- =========================================== -->

  <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
    <xsl:param name="originatingSource"/>

    <xsl:for-each select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |

            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |

            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |

            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |

            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)]">
      <xsl:apply-templates select="." mode="party_person">
        <xsl:with-param name="originatingSource" select="$originatingSource"/>
      </xsl:apply-templates>
    </xsl:for-each>

    <xsl:for-each select="
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]  |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]">
      <xsl:apply-templates select="." mode="party_group">
        <xsl:with-param name="originatingSource" select="$originatingSource"/>
      </xsl:apply-templates>
    </xsl:for-each>

    <xsl:for-each select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]">
      <xsl:apply-templates select="." mode="party_group_2">
        <xsl:with-param name="originatingSource" select="$originatingSource"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="cit:linkage" mode="registryObject_location_service_URL">
    <xsl:variable name="protocol" select="../cit:protocol"/>
    <location>
      <address>
        <electronic>
          <xsl:attribute name="type">
            <xsl:text>url</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="target">
            <xsl:choose>
              <xsl:when test="$protocol = 'WWW:LINK-1.0-http--opendap'">
                <xsl:value-of select="'landingPage'"/>
              </xsl:when>
              <xsl:when test="$protocol = 'WWW:DOWNLOAD-1.0-http--download'">
                <xsl:value-of select="'directDownload'"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <value>
            <xsl:value-of select="."/>
          </value>
          <title>
            <xsl:value-of select="../cit:name"/>
          </title>
          <notes>
            <xsl:value-of select="../cit:description"/>
          </notes>
        </electronic>
      </address>
    </location>
  </xsl:template>

  <xsl:template match="mri:keyword" mode="registryObject_subject">
    <subject>
      <xsl:attribute name="type">
        <xsl:variable name="xlinkTitle" select="lower-case(ancestor::mri:MD_Keywords[1]/mri:type/mri:MD_KeywordTypeCode/@codeListValue)"/>
        <xsl:variable name="uuid" select="lower-case(ancestor::mri:MD_Keywords[1]/@uuid)"/>
        <xsl:variable name="identifierLink" select="following-sibling::mri:thesaurusName/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gcx:Anchor/@xlink:href"/>
        <xsl:choose>
          <xsl:when test="$identifierLink = 'https://vocabs.ands.org.au/viewById/20'">
            <xsl:text>anzsrc-for</xsl:text>
          </xsl:when>
          <xsl:when test="$identifierLink = 'https://vocabs.ands.org.au/viewById/238'">
            <xsl:text>gcmd</xsl:text>
          </xsl:when>
          <xsl:when test="contains($identifierLink, 'https://vocabs.ands.org.au/viewById/')">
            <xsl:value-of select="following-sibling::mri:thesaurusName/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gcx:Anchor"/>
          </xsl:when>
          <xsl:when test="($uuid = 'data_group') and (gcx:Anchor/@xlink:title ='Parameter')">
            <xsl:text>data-group</xsl:text>
          </xsl:when>
          <xsl:when test="($uuid = 'data_group') and ((gcx:Anchor/@xlink:title = 'UOM') or (gcx:Anchor/@xlink:title = 'Platform'))">
            <xsl:text>ignore</xsl:text>
          </xsl:when>
          <!-- something for the methods -->
          <xsl:when test="$identifierLink = 'https://vocabs.ands.org.au/viewById/238'">
            <xsl:text>method</xsl:text>
          </xsl:when>
          <xsl:when test="string-length($uuid) > 0">
            <xsl:value-of select="$uuid"/>
          </xsl:when>
          <xsl:when test="string-length($xlinkTitle) > 0">
            <xsl:value-of select="$xlinkTitle"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>local</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="(ancestor::mri:MD_Keywords[1]/@uuid = 'Data_Group') and (gcx:Anchor/@xlink:title ='Parameter')">
          <xsl:value-of select="normalize-space(concat(., ' ('))"></xsl:value-of>
          <xsl:value-of select="(following-sibling::*)[gcx:Anchor/@xlink:title = 'UOM']"></xsl:value-of>
          <xsl:text>) </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(xlink:title)"></xsl:value-of>
          <xsl:value-of select="normalize-space(.)"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </subject>
  </xsl:template>

  <xsl:template match="cit:CI_Organisation" mode="party_group_2">
    <xsl:param name="originatingSource"/>

    <registryObject group="{$global_group}">
      <key>
        <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
      </key>

      <originatingSource>
        <xsl:value-of select="$originatingSource"/>
      </originatingSource>

      <party type="group">
        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource[contains(lower-case(.), 'abn')]" mode="ABN"/>

        <identifier> <!-- extra elements added compared to party_group template -->
          <xsl:attribute name="type">
            <xsl:value-of select="cit:name/gcx:Anchor/@xlink:role"/>
          </xsl:attribute>
          <xsl:value-of select="cit:name/gcx:Anchor/@xlink:href"/>
        </identifier>

        <name type="primary">
          <namePart>
            <xsl:value-of select="normalize-space(cit:name)"/>
          </namePart>
        </name>


        <xsl:variable name="groupUri" select="normalize-space(cit:name/gcx:Anchor/@xlink:href)"/>

        <xsl:for-each select="
                    ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(normalize-space(gcx:Anchor/@xlink:href)) > 0 and 
normalize-space(gcx:Anchor/@xlink:href) = $groupUri] |
ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(normalize-space(gcx:Anchor/@xlink:href)) > 0 and 
normalize-space(gcx:Anchor/@xlink:href) = $groupUri]"> <!-- extra elements added compared to party_group template -->
          <!-- ../../../../cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name -->
          <xsl:choose>
            <xsl:when test="(count(../cit:individual/cit:CI_Individual) > 0)">
              <!--  individual position name, so relate this individual to this organisation... -->
              <xsl:for-each select="../cit:individual/cit:CI_Individual">
                <xsl:variable name="name">
                  <xsl:choose>
                    <xsl:when test="string-length(.) > 0">
                      <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:when test="string-length(../cit:positionName) > 0">
                      <xsl:value-of select="../cit:positionName"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:variable>

                <xsl:if test="(string-length($name) > 0)">
                  <relatedObject>
                    <key>
                      <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                    </key>
                    <relation type="hasMember"/>
                  </relatedObject>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="../cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <!--  no individual position name, so use this address for this organisation -->
        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/>

      </party>
    </registryObject>
  </xsl:template>

  <xsl:template match="cit:CI_OnlineResource" mode="registryObject_relatedInfo_service">
        <xsl:variable name="identifierValue" select="normalize-space(cit:linkage)"/>

        <relatedInfo>
            <xsl:attribute name="type" select="'service'"/>

            <xsl:apply-templates select="." mode="relatedInfo_all"/>

            <relation>
                <xsl:attribute name="type">
                    <xsl:choose>
                      <xsl:when test="(cit:protocol = 'WWW:LINK-1.0-http--opendap' and cit:function/cit:CI_OnLineFunctionCode/@codeListValue = 'fileAccess')">
                        <xsl:text>hasValueAddedBy</xsl:text>
                      </xsl:when>
                      <xsl:when test="(cit:protocol = 'WWW:LINK-1.0-http--link' and cit:function/cit:CI_OnLineFunctionCode/@codeListValue = 'information')">
                        <xsl:text>hasValueAddedBy</xsl:text>
                      </xsl:when>
                      <xsl:when test="(cit:protocol = 'WWW:LINK-1.0-http--link' and cit:function/cit:CI_OnLineFunctionCode/@codeListValue = 'fileAccess')">
                        <xsl:text>isAvailableThrough</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>supports</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                <xsl:if test="(contains($identifierValue, '?')) or (contains($identifierValue, '.nc'))">
                    <url>
                        <xsl:value-of select="$identifierValue"/>
                    </url>
                </xsl:if>
            </relation>


        </relatedInfo>

    </xsl:template>
</xsl:stylesheet>