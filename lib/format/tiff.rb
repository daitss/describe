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

    end
    # traverse through multiple image bitstreams inside TIFF 
    nodes = @jhove.find("//jhove:property[jhove:name/text()='NisoImageMetadata']/jhove:values/jhove:value", JHOVE_NS)
    nodes.each do |node|
      mix = node.find_first("//mix:mix", "mix:http://www.loc.gov/mix/v20")
      bitstream = BitstreamObject.new
      bitstream.objectExtension = mix
      @bitstreams << bitstream
    end
  end

end
