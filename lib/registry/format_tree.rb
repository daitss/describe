require 'xml'
require './lib/config'

class FormatTree
  def initialize
    @doc = open(config_file('format_tree.xml')) { |io| XML::Document.io io }
  end
  
  # retrieve all branch formats 
  def getBranches(format)

	branch_formats = @doc.find("//branch[format = '#{format}']//branch/format/text()")
	# return the branch format as an array of string
	if branch_formats
		branches = branch_formats.to_a
		branches.map! {|b| b.to_s}
	end
	branches
  end

end