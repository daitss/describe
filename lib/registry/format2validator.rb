require 'xml'
require 'singleton'
require 'config'

# Format2Validator class performs validator lookup by registry id
class Format2Validator
  attr_reader :rid
  attr_reader :validators
    
  def initialize
    @doc = XML::Document.file config_file('format2validator.xml')
    @validators = Array.new
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
