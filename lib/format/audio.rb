require 'format/formatbase.rb'
require 'datyl/logger'

class Audio < FormatBase
  protected
  def parse(xml)
    super
    
    # retrieve and dump the AES audio metadata
    aes = @jhove.find_first('//jhove:property[jhove:name/text()="AESAudioMetadata"]/jhove:values/jhove:value', NAMESPACES)
    unless (aes.nil?)
      #retrieve the aes namespace
      audio = aes.find_first("//aes:audioObject", NAMESPACES)
      @result.fileObject.objectExtension = audio
    else 
      Datyl::Logger.warn "No AESAudioMetadata found"
    end
  end

end
