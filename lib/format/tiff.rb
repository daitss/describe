require 'format/image'

class Tiff < Image

  def parse(xml)
    super

    unless (@mix.nil?)
      begin
        # retrieve the createDate metadata
        createDate =  @mix.find_first('mix:ImageCaptureMetadata/mix:GeneralCaptureInformation/mix:dateTimeCreated', NAMESPACES)
        unless (createDate.nil?)
          # parse createDate
          @fileObject.createDate = Time.xmlschema(createDate.content)
        end
      rescue => e
         @anomaly.add "malformed dateTimeCreated"
      end
      createAppName = @mix.find_first('mix:ImageCaptureMetadata/mix:ScannerCapture/mix:ScanningSystemSoftware/mix:scanningSoftwareName', NAMESPACES)
      unless (createAppName.nil?)
        @fileObject.createAppName = createAppName.content
      end
   end
   
   # traverse through multiple image bitstreams inside TIFF 
   nodes = @jhove.find("//jhove:property[jhove:name/text()='NisoImageMetadata']/jhove:values/jhove:value", NAMESPACES)
   sequence = 1
   nodes.each do |node|
     mixstream = node.find_first("mix:mix", NAMESPACES)
     bitstream = BitstreamObject.new
     bitstream.uri = @fileObject.uri + "/" + sequence.to_s
     compression = mixstream.find_first('mix:BasicDigitalObjectInformation/mix:Compression/mix:compressionScheme', NAMESPACES)
     if (compression)
       bitstream.formatName = compression.content
     else 
       bitstream.formatName = 'unknown'
     end
     bitstream.objectExtension = fixMix(mixstream)
     @bitstreams << bitstream
     sequence += 1
   end
  end

end
