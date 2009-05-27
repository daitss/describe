require 'format/image'

class Tiff < Image

  def parse(xml)
    super
    
    unless (@mix.nil?)
      # retrieve the createDate metadata
      createDate =  @mix.find_first('mix:ImageCaptureMetadata/mix:GeneralCaptureInformation/mix:dateTimeCreated', MIX_NS)
      unless (createDate.nil?)
        @fileObject.createDate = createDate.content
      end

      createAppName = @mix.find_first('mix:ImageCaptureMetadata/mix:ScannerCapture/mix:ScanningSystemSoftware/mix:scanningSoftwareName', MIX_NS)
      unless (createAppName.nil?)
        @fileObject.createAppName = createAppName.content
      end
      
      #create a bitstream object for the image bitstream inside tiff
      bitstream = BitstreamObject.new
      bitstream.objectExtension = @mix
      @bitstreams << bitstream
      
      # TODO multiple images bitstream inside TIFF 
     end
  end

end
