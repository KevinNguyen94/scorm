require 'nokogiri'
require 'virtus'

def scorm_manifest(name)
  File.read File.expand_path(
    File.join(__FILE__, "..", "fixtures", "manifests", "#{name}.xml")
  )
end

def xml_scorm_manifest(name)
  Nokogiri::XML(scorm_manifest(name), "utf-8") { |config| config.nonet }
end

def xml_organization_item(contents)
  src = <<-XML
    <?xml version="1.0" encoding="utf-8" standalone="no"?>
    <manifest identifier="one-organization" version="1"
            xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_v1p3"
            xmlns:adlseq="http://www.adlnet.org/xsd/adlseq_v1p3"
            xmlns:adlnav="http://www.adlnet.org/xsd/adlnav_v1p3"
            xmlns:imsss="http://www.imsglobal.org/xsd/imsss"
            xsi:schemaLocation="http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd
                                http://www.adlnet.org/xsd/adlcp_v1p3 adlcp_v1p3.xsd
                                http://www.adlnet.org/xsd/adlseq_v1p3 adlseq_v1p3.xsd
                                http://www.adlnet.org/xsd/adlnav_v1p3 adlnav_v1p3.xsd
                                http://www.imsglobal.org/xsd/imsss imsss_v1p0.xsd">
    <metadata>
      <schema>ADL SCORM</schema>
      <schemaversion>2004 4th Edition</schemaversion>
    </metadata>
    <organizations default="default_org">
      <organization identifier="default_org"
                    structure="not-really-normal"
                    adlseq:objectivesGlobalToSystem="false"
                    adlcp:sharedDataGlobalToSystem="false">
        <title>Default Organization</title>
        <item identifier="intro" identifierref="some-resource">
          #{contents}
        </item>
      </organization>
    </organizations>
    </manifest>
  XML
  doc = Nokogiri::XML(src)
  doc.xpath("//xmlns:item")
end
