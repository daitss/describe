require 'rexml/document'
require 'RJhove.rb'
require 'image.rb'

include REXML

class Jpeg < Image
  def parse(xml)
    super
    # retrieve and dump the JPEG compression metadata
    compType = @jhove.elements['//property[name/text()="CompressionType"]']
    unless compType.nil?
       @fileObject.objectExtension.add_element compType
    end

  end

end
