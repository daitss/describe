require 'format/formatbase'

class UTF8 < FormatBase

  def parse(xml)
    super

    # retrieve and dump the XML metadata
    utf8MD = @jhove.find_first('//jhove:property[jhove:name/text()="UTF8Metadata"]', NAMESPACES)

    unless (utf8MD.nil?)
      @fileObject.objectExtension = apply_xsl("utf2TextMD.xsl").root
    else
      DescribeLogger.instance.warn "No UTF8Metadata found"
    end

  end

end
