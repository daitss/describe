require 'format/image.rb'

class JP2 < Image
  def parse(xml)
    super
    #create a bitstream object for the image bitstream inside tiff
    bitstream = BitstreamObject.new
    bitstream.url = @fileObject.url + "/1"
    compression = @mix.find_first('mix:BasicDigitalObjectInformation/mix:Compression/mix:compressionScheme', MIX_NS)
    if (compression)
      bitstream.formatName = compression.content
    end
    bitstream.objectExtension = @mix
    @bitstreams << bitstream
  end

end
