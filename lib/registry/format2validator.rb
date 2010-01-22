require 'xml'
require 'singleton'
require 'config'

# Format2Validator class performs validator lookup by registry id
class Format2Validator
  attr_reader :rid
  attr_reader :validator
  
  include Singleton
    
  def initialize
    @doc = XML::Document.file config_file('format2validator.xml')
  end

  def find_by_rid(rid)
    baseURI = "//format[rid='#{rid}']"
    xml = @doc.find_first(baseURI)
    unless (xml.nil?)
      set(baseURI)
      self
    else
      nil
    end
  end
   
  def set(baseURI)
    @rid =  @doc.find_first(baseURI + "/rid/text()").to_s
    @validator =  @doc.find_first(baseURI + "/validator/text()").to_s
  end
    
end
