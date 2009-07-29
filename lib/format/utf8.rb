require 'format/formatBase'
require 'xml/xslt'

class UTF8 < FormatBase
  def parse(xml)
    super
    # retrieve and dump the XML metadata
    utf8MD = @jhove.find_first('//jhove:property[jhove:name/text()="UTF8Metadata"]', NAMESPACES)
    unless (utf8MD.nil?)
      xslt = XML::XSLT.new()
      xslt.xml = @jhove.to_s
      xslt.xsl = xsl_file "utf2TextMD.xsl"
      textMDString = xslt.serve()
      #convert the xml string into xml element
      tmpDoc =  XML::Document.string(textMDString)
      @fileObject.objectExtension = tmpDoc.root
    else
      DescribeLogger.instance.warn "No UTF8Metadata found"
    end

  end
end