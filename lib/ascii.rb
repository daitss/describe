require 'formatBase'
require 'xml/xslt'
require 'DescribeLogger.rb'

class ASCII < FormatBase
  def parse(xml)
    super
    # retrieve and dump the XML metadata
    asciiMD = @jhove.find_first('//jhove:property[jhove:name/text()="ASCIIMetadata"]', JHOVE_NS)
    unless (asciiMD.nil?)
      xslt = XML::XSLT.new()
      xslt.xml = @jhove.to_s
      xslt.xsl = REXML::Document.new File.read("xsl/ascii2TextMD.xsl")
      textMDString = xslt.serve()
      #convert the xml string into xml element
      tmpDoc =  XML::Document.string(textMDString)
      @fileObject.objectExtension = tmpDoc.root
    else 
       DescribeLogger.instance.warn "No ASCIIMetadata found"
    end
    
  end
end