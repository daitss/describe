require 'format/formatbase'
require 'datyl/logger'

class RXML < FormatBase

  def parse(xml)
    super
    # retrieve and dump the XML metadata
    xmlMD = @jhove.find_first('//jhove:property[jhove:name/text()="XMLMetadata"]', NAMESPACES)
    unless (xmlMD.nil?)
      @fileObject.objectExtension = apply_xsl("xml2TextMD.xsl").root
    else 
      Datyl::Logger.warn "no XMLMetadata found"
    end

  end
end
