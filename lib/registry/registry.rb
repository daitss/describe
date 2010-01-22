require 'xml'
require 'singleton'
require 'config'

# Registry class performs registry identifier lookup by a defined name string
class Registry
  attr_reader :name
  attr_reader :identifier
  attr_reader :lookup
 
  include Singleton
    
  def initialize
    @doc = XML::Document.file config_file('registrylookup.xml')
  end
  
  def find_by_lookup(lookup)
    baseURI = "//registry[lookup='#{lookup}']"
    xml = @doc.find_first(baseURI)
    unless (xml.nil?)
      set(baseURI)
      self
    else
      nil
    end
  end
   
  def set(baseURI)
    @name =  @doc.find_first(baseURI + "/name/text()").to_s
    @identifier =  @doc.find_first(baseURI + "/identifier/text()").to_s
    @lookup =  @doc.find_first(baseURI + "/lookup/text()").to_s
  end

end
