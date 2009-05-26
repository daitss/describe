require 'rexml/document'
require 'RJhove.rb'
require 'image.rb'

include REXML

class JP2 < Image
  def parse(xml)
    super
    #create a bitstream object for the image bitstream inside tiff
    bitstream = BitstreamObject.new
    bitstream.objectExtension = @mix
    @bitstreams << bitstream
  end

end
