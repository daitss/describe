#!/usr/local/env ruby

# a placeholder for holding the extracted values from the format characterization.
# the metadata extracted here conform to premis data dictionary.  Please
# see Premis data dictionary 2.0 for explaination of the metadata.

require 'registry/format_tree'

# metadata related to inhibitor
class Inhibitor
  attr_accessor :type
  attr_accessor :target
  attr_accessor :key
end

# metadata related to format
class FileFormat
  attr_accessor :registryName
  attr_accessor :registryKey
  attr_accessor :formatName
  attr_accessor :formatVersion
  attr_accessor :formatNote
end

# extracted metadata of a file object
class FileObject
  attr_accessor :location
  attr_accessor :uri
  attr_accessor :size
  attr_accessor :originalName
  attr_accessor :compositionLevel
  attr_accessor :formats
  attr_accessor :objectExtension
  attr_accessor :inhibitors
  attr_accessor :createAppName
  attr_accessor :createAppVersion
  attr_accessor :createDate

  def initialize
 	@formats = Array.new
  end

  # trim down the list of identified formats to the most specific.  Ex., if both PDF/A and PDF/1.4 are listed
  # as identified formats for the object, only PDF/A shall be recorded.
  def trimFormatList
	formatTree = FormatTree.new
	formats.each do |format|
	  branches = formatTree.getBranches(format.formatName)
	  if branches
	    # create an array excluding the current format
	    otherFormats = Array.new(formats)
	    otherFormats.delete_if {|f| f.formatName == format.formatName }
	    # remove the duplicate format from the list of identified formats
	    otherFormats.each do |fmt| 
	      formats.delete(format) if branches.include?(fmt.formatName) 
		end
	  end
	end
  end

end

# extracted metadata of a bitstream object
class BitstreamObject
  attr_accessor :uri
  attr_accessor :formatName
  attr_accessor :objectExtension
end
