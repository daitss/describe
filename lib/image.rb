require 'xml'
require 'formatBase.rb'
require "DescribeLogger.rb"

class Image < FormatBase
  MIX_NS = "mix:http://www.loc.gov/mix/v20"
  
  protected
  def parse(xml)
    super
    # retrieve and dump the mix image metadata
    niso = @jhove.find_first('//jhove:property[jhove:name/text()="NisoImageMetadata"]/jhove:values/jhove:value', JHOVE_NS)
    unless (niso.nil?)
      #retrieve the mix namespace
      @mix = niso.find_first("//mix:mix", MIX_NS)
    else 
      DescribeLogger.instance.warn "No NisoImageMetadata found"
    end
  end

end