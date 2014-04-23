require_relative 'image.rb'

class JP2 < Image
  def parse(xml)
    super
    if @mix
      #create a bitstream object for the image bitstream inside tiff
      bitstream = BitstreamObject.new
      bitstream.uri = @result.fileObject.uri + "/1"
      compression = @mix.find_first('mix:BasicDigitalObjectInformation/mix:Compression/mix:compressionScheme', NAMESPACES)
      if (compression)
        bitstream.formatName = compression.content
      else 
        bitstream.formatName = 'Unknown'
      end
      bitstream.objectExtension = @mix
      @result.bitstreams << bitstream
    end
  end

end
