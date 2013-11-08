require 'xml'
require 'singleton'
require './lib/config'

# Registry class performs registry identifier lookup by a defined name string
class Registry
  attr_reader :name
  attr_reader :identifier
  attr_reader :lookup
 
  include Singleton
    
  def initialize
    @doc = open(config_file('registrylookup.xml')) { |io| XML::Document.io io }    
  end
  
  # find format registry entry by using the lookup string
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
