require 'rexml/document'
require 'formatBase.rb'
require 'DescribeLogger.rb'

include REXML

class Audio < FormatBase
  protected
  def parse(xml)
    super
    
    # retrieve and dump the AES audio metadata
    aes = @jhove.find_first('//jhove:property[jhove:name/text()="AESAudioMetadata"]/jhove:values/jhove:value', JHOVE_NS)
    unless (aes.nil?)
      #retrieve the aes namespace
      audio = aes.find_first("//aes:audioObject", "aes:http://www.aes.org/audioObject")
      @fileObject.objectExtension = audio
    else 
      DescribeLogger.instance.warn "No AESAudioMetadata found"
    end
  end

end
