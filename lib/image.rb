require 'rexml/document'
require 'formatBase.rb'
require "DescribeLogger.rb"

include REXML

class Image < FormatBase
  protected
  def parse(xml)
    super
    # retrieve and dump the mix image metadata
    niso = @jhove.elements['//property[name/text()="NisoImageMetadata"]']
    unless (niso.nil?)
      #retrieve the mix namespace
      @mix = niso.elements['//*[name()="mix:mix"]']
      mixns = @mix.namespace
      @fileObject.objectExtension.add_element @mix
    else 
      DescribeLogger.instance.warn "No NisoImageMetadata found"
    end
  end

end
