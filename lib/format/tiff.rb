require 'format/image'

class Tiff < Image

  def parse(xml)
    super

    unless (@mix.nil?)
      # retrieve the createDate metadata
      createDate =  @mix.find_first('mix:ImageCaptureMetadata/mix:GeneralCaptureInformation/mix:dateTimeCreated', NAMESPACES)
      unless (createDate.nil?)
        @fileObject.createDate = createDate.content
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
      mix = node.find_first("mix:mix", NAMESPACES)
      bitstream = BitstreamObject.new
      bitstream.uri = @fileObject.uri + "/" + sequence.to_s
      compression = mix.find_first('mix:BasicDigitalObjectInformation/mix:Compression/mix:compressionScheme', NAMESPACES)
      if (compression)
        bitstream.formatName = compression.content
      else 
        bitstream.formatName = 'unknown'
      end
      bitstream.objectExtension = mix
      @bitstreams << bitstream
      sequence += 1
    end
  end

end
