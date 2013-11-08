require './lib/format/formatbase'
require 'datyl/logger'

class UTF8 < FormatBase

  def parse(xml)
    super

    # retrieve and dump the XML metadata
    utf8MD = @jhove.find_first('//jhove:property[jhove:name/text()="UTF8Metadata"]', NAMESPACES)

    unless (utf8MD.nil?)
      @result.fileObject.objectExtension = apply_xsl("utf2TextMD.xsl").root
    else
      Datyl::Logger.warn "No UTF8Metadata found"
    end

  end

end
