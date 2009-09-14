require 'format/formatbase'
require 'xml/xslt'

class RXML < FormatBase
  def parse(xml)
    super
    # retrieve and dump the XML metadata
    xmlMD = @jhove.find_first('//jhove:property[jhove:name/text()="XMLMetadata"]', NAMESPACES)
    unless (xmlMD.nil?)
      DescribeLogger.instance.info "transforming JHOVE output to XML"
      xslt = XML::XSLT.new()
      xslt.xml = @jhove.to_s
      xslt.xsl = xsl_file "xml2TextMD.xsl"
      textMDString = xslt.serve()
      #convert the xml string into xml element
      tmpDoc = XML::Document.string(textMDString)
      @fileObject.objectExtension = tmpDoc.root
    else 
      DescribeLogger.instance.warm "no XMLMetadata found"
    end

  end
end