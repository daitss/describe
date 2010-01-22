require 'xml'
require 'singleton'
require 'config'

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
  
  # sort the validators by priority
  def <=>(other)
    other.priority <=> self.priority
  end
end