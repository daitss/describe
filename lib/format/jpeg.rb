require_relative 'image.rb'

class Jpeg < Image
  def parse(xml)
    super
    # retrieve and dump the JPEG compression metadata
    compType = @jhove.find_first('//jhove:property[jhove:name/text()="CompressionType"]', NAMESPACES)
    unless compType.nil?
       @result.fileObject.objectExtension = compType
    end

    # put MIX inside the file object (Jpeg does not have bitsteam object)
    @result.fileObject.objectExtension = @mix
  end

end
