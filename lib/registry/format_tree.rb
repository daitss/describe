require 'xml'
require 'config'

class FormatTree
  def initialize
      @doc = XML::Document.file config_file('format_tree.xml')
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