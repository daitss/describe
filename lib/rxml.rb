require 'formatBase'
require 'xml/xslt'
require 'DescribeLogger.rb'

class RXML < FormatBase
  def parse(xml)
    super
    # retrieve and dump the XML metadata
    xmlMD = @jhove.elements['//property[name/text()="XMLMetadata"]']
    unless (xmlMD.nil?)
      DescribeLogger.instance.info "transforming JHOVE output to XML"
      xslt = XML::XSLT.new()
      xslt.xml = @jhove.to_s
      xslt.xsl = REXML::Document.new File.read("xsl/xml2TextMD.xsl")
      textMDString = xslt.serve()
      #convert the xml string into xml element
      tmpDoc = REXML::Document.new textMDString
      textMD = tmpDoc.root
      @fileObject.objectExtension.add_element textMD
    else 
      DescribeLogger.instance.warm "no XMLMetadata found"
    end

  end
end