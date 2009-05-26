require 'rexml/document'
require 'RJhove.rb'
require 'image.rb'

include REXML

class Jpeg < Image
  def parse(xml)
    super
    # retrieve and dump the JPEG compression metadata
    compType = @jhove.find_first('//jhove:property[jhove:name/text()="CompressionType"]', JHOVE_NS)
    unless compType.nil?
       @fileObject.objectExtension = compType
    end

    # put MIX inside the file object (Jpeg does not have bitsteam object)
    @fileObject.objectExtension = @mix
  end

end
