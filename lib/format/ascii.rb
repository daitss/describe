require 'format/formatbase'

class ASCII < FormatBase

  def parse(xml)
    super

    # retrieve and dump the XML metadata
    asciiMD = @jhove.find_first('//jhove:property[jhove:name/text()="ASCIIMetadata"]', NAMESPACES)

    unless (asciiMD.nil?)
      @fileObject.objectExtension = apply_xsl("ascii2TextMD.xsl").root
    else 
      DescribeLogger.instance.warn "No ASCIIMetadata found"
    end

  end

end
