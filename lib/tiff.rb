require 'rexml/document'
require 'RJhove.rb'
require 'image'

include REXML

class Tiff < Image

  def parse(xml)
    super
    
    unless (@mix.nil?)
      # retrieve the createDate metadata
      createDate =  @mix.elements['mix:ImageCaptureMetadata/mix:GeneralCaptureInformation/mix:dateTimeCreated']
      unless (createDate.nil?)
        @fileObject.createDate = createDate.get_text.to_s
      end

      createAppName = @mix.elements['mix:ImageCaptureMetadata/mix:ScannerCapture/mix:ScanningSystemSoftware/mix:scanningSoftwareName']
      unless (createAppName.nil?)
        @fileObject.createAppName = createAppName.get_text.to_s
      end
    end
  end

end
