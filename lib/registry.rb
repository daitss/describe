require 'xml'
require 'singleton'
require 'config'

class Format
  attr_reader :registry
  attr_reader :puid
  attr_reader :name
  attr_reader :version
  
  include Singleton
  
  def initialize
    @registry = "http://www.nationalarchives.gov.uk/pronom"
    @doc = XML::Document.file config_file('DROID_SignatureFile.xml')
  end
  
  def find_puid(puid)
    baseuri = "//droid:FileFormat[@PUID='#{puid}']"
    ns = "droid:#{registry}/SignatureFile"
    fmt = @doc.find_first("//droid:FileFormat[@PUID='#{puid}']",ns)
    unless (fmt.nil?)
      @puid = @doc.find_first("#{baseuri}//@PUID", ns).value.to_s
      @name = @doc.find_first("#{baseuri}//@Name", ns).value.to_s
      unless (@doc.find_first("#{baseuri}//@Version", ns).nil?)
        @version = @doc.find_first("#{baseuri}//@Version", ns).value.to_s
      else
        @version = nil
      end
      self
    else
      nil
    end
  end
end

class Format2Validator
  attr_reader :rid
  attr_reader :validator
  attr_reader :lookup
  
  include Singleton
    
  def initialize
    @doc = XML::Document.file config_file('format2validator.xml')
  end
  
  def find_by_lookup(lookup)
    baseURI = "//format[lookup='#{lookup}']"
    xml = @doc.find_first(baseURI)
    unless (xml.nil?)
      set(baseURI)
      self
    else
      nil
    end
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
    @lookup =  @doc.find_first(baseURI + "/lookup/text()").to_s
  end
    
  # def set(xml)
  #    @rid = xml.find_first('//rid/text()').to_s
  #    @validator = xml.find_first('//validator/text()').to_s
  #    @lookup = xml.find_first('//lookup/text()').to_s
  #  end  
end


class Validator
  attr_reader :name
  attr_reader :class
  attr_reader :method
  attr_reader :parameter
  attr_reader :priority
  
  def initialize(doc, base)
    @name = doc.find_first("#{base}//name/text()").to_s
    @class = doc.find_first("#{base}//class/text()").to_s
    @method = doc.find_first("#{base}//method/text()").to_s
    @parameter = doc.find_first("#{base}//parameter/text()").to_s
    @priority = doc.find_first("#{base}//priority/text()").to_s
  end
  
  # sorted by priority
  def <=>(other)
    other.priority <=> self.priority
  end
end