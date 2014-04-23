require 'xml'
require './lib/config'

class FDAFormat
  attr_reader :registry
  attr_reader :id
  attr_reader :name
  attr_reader :version
  
  def initialize
    @doc = open(config_file('FDA_FormatRegistry.xml')) { |io| XML::Document.io io }
    @registry = "info:fda//www.fcla.edu/fda/format"
  end
  
  def find(formatName)
    baseuri = "//fda:Format[@Name='#{formatName}']"
    ns = "fda:#{registry}"
    fmt = @doc.find_first(baseuri, ns)
    unless (fmt.nil?)
      @id = @doc.find_first("#{baseuri}//@ID", ns).value.to_s
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
