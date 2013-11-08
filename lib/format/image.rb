require_relative 'formatbase.rb'
require 'datyl/logger'

class Image < FormatBase  
  protected 
  
  def parse(xml)
    super
    # retrieve and dump the mix image metadata
    niso = @jhove.find_first('//jhove:property[jhove:name/text()="NisoImageMetadata"]/jhove:values/jhove:value', NAMESPACES)
    unless (niso.nil?)
      #retrieve the mix namespace
      @mix = niso.find_first("//mix:mix", NAMESPACES)
    else 
      Datyl::Logger.warn "No NisoImageMetadata found"
    end
  end
  
  
  # fix malformed mix metadata, example include non-printable characters in dateTimeCreated
  protected 
  
  def fixMix(mixstream)
    begin
      dateTimeCreated = mixstream.find_first('mix:ImageCaptureMetadata/mix:GeneralCaptureInformation/mix:dateTimeCreated', NAMESPACES)
      # parse dateTimeCreated
      Time.xmlschema(dateTimeCreated.content).xmlschema unless dateTimeCreated.nil?
    rescue => e
      puts e.inspect
      dateTimeCreated.remove! unless dateTimeCreated.nil?
      @result.anomaly.add "malformed dateTimeCreated"
    end
    mixstream
  end

end
