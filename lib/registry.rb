require 'xml'

class Format
  attr_accessor :registry
  attr_accessor :puid
  attr_accessor :name
  attr_accessor :version
  attr_accessor :registry
  
  include Singleton
  
  def initialize
    @registry = "http://www.nationalarchives.gov.uk/pronom"
    @doc = XML::Document.file('config/DROID_SignatureFile_V13.xml')
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
      end
      self
    else
      nil
    end
  end
end

class Validator
  attr_accessor :name
  attr_accessor :class
  attr_accessor :method
  attr_accessor :parameter
  attr_accessor :priority
  
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

class Format2Validator
  attr_accessor :rid
  attr_accessor :validator
  attr_accessor :lookup
  
  include Singleton
    
  def initialize
    @doc = XML::Document.file('config/format2validator.xml')
  end
  
  def find_by_lookup(lookup)
    xml = @doc.find_first("//format[lookup='#{lookup}']")
    unless (xml.nil?)
       @rid = @doc.find_first("//format[lookup='#{lookup}']/rid/text()").to_s
       @validator = @doc.find_first("//format[lookup='#{lookup}']/validator/text()").to_s
       @lookup = @doc.find_first("//format[lookup='#{lookup}']/lookup/text()").to_s

       self
     else
       nil
     end
  end
  
  def find_by_rid(rid)
    xml = @doc.find_first("//format[rid='#{rid}']")
    unless (xml.nil?)
      @rid = @doc.find_first("//format[rid='#{rid}']/rid/text()").to_s
      @validator = @doc.find_first("//format[rid='#{rid}']/validator/text()").to_s
      @lookup = @doc.find_first("//format[rid='#{rid}']/lookup/text()").to_s

      self
    else
      nil
    end

  end
   
  # def set(xml)
  #    @rid = xml.find_first('//rid/text()').to_s
  #    @validator = xml.find_first('//validator/text()').to_s
  #    @lookup = xml.find_first('//lookup/text()').to_s
  #  end  
end