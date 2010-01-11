require 'format/formatbase'
require 'format/formatstylesheet'

class RXML < FormatBase
  include FormatStylesheet

  def parse(xml)
    super
    # retrieve and dump the XML metadata
    xmlMD = @jhove.find_first('//jhove:property[jhove:name/text()="XMLMetadata"]', NAMESPACES)
    unless (xmlMD.nil?)
      DescribeLogger.instance.info "transforming JHOVE output to XML"
      @fileObject.objectExtension = apply_xsl("xml2TextMD.xsl")
    else 
      DescribeLogger.instance.warm "no XMLMetadata found"
    end

  end
end
