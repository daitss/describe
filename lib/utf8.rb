require 'formatBase'
require 'xml/xslt'
require 'DescribeLogger.rb'

class UTF8 < FormatBase
  def parse(xml)
    super
    # retrieve and dump the XML metadata
    asciiMD = @jhove.elements['//property[name/text()="UTF8Metadata"]']
    unless (asciiMD.nil?)
      xslt = XML::XSLT.new()
      xslt.xml = @jhove.to_s
      xslt.xsl = REXML::Document.new File.read("xsl/utf2TextMD.xsl")
      textMDString = xslt.serve()
      #convert the xml string into xml element
      tmpDoc = REXML::Document.new textMDString
      textMD = tmpDoc.root
      @fileObject.objectExtension.add_element textMD
    else
      DescribeLogger.instance.warn "No UTF8Metadata found"
    end

  end
end