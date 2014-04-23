require 'xml'
require './lib/config'

# Format2Validator class performs validator lookup by registry id
class Format2Validator
  attr_reader :rid
  attr_reader :validators
    
  def initialize
    @doc = open(config_file('format2validator.xml')) { |io| XML::Document.io io }
    @validators = Array.new
  end

  def clear
    @doc = nil
    @validators.clear
    @validator = nil
  end
  
  def find_by_rid(rid)
    baseURI = "//format[rid='#{rid}']"
    xml = @doc.find_first(baseURI)
    unless (xml.nil?)
      @rid =  @doc.find_first(baseURI + "/rid/text()").to_s
      validators = @doc.find(baseURI + "/validator/text()")
      validators.each do |val| 
        @validators << val.to_s 
      end
    end
  end
    
end
