require 'rexml/document'
require 'formatBase.rb'
require 'DescribeLogger.rb'

include REXML

class Audio < FormatBase
  protected
  def parse(xml)
    super
    
    # retrieve and dump the AES audio metadata
    aes = @jhove.elements['//property[name/text()="AESAudioMetadata"]']
    unless (aes.nil?)
      #retrieve the aes namespace
      audio = aes.elements['//*[name()="aes:audioObject"]']
      audioNS = audio.namespace
      @fileObject.objectExtension.add_element audio  
    else 
      DescribeLogger.instance.warn "No AESAudioMetadata found"
    end
    
  end

end
