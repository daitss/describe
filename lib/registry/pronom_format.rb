require 'xml'
require 'singleton'
require 'config'

PRONOM_URL = "http://www.nationalarchives.gov.uk/pronom"

class PRONOMFormat
  attr_reader :registry
  attr_reader :puid
  attr_reader :name
  attr_reader :version
  
  include Singleton
  
  def initialize
    @registry = PRONOM_URL
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
