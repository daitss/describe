#!/usr/local/env ruby

# a placeholder for holding the extracted values from the format characterization.
# the metadata extracted here conform to premis data dictionary.  Please
# see Premis data dictionary 2.0 for explaination of the metadata.

require 'registry/format_tree'
require 'registry/fda_format'
require 'ruby-debug'

class FormatError < StandardError; end

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

  # returns true if other is the same format
  def ==(other)
	@formatName == other.formatName and @registryKey == other.registryKey
  end

  alias_method :eql?, :==

  def hash
    @formatName.hash
  end
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
  attr_accessor :md5
  attr_accessor :sha1

  def initialize
 	  @formats = Array.new
   	@inhibitors = Array.new
  end

  def clear
    if @format
      @formats.clear
      @formats = nil
    end
    
    if @inhibitors
      @inhibitors.clear
      @inhibitors = nil
    end   
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
		  otherFormats.clear
	  end
	end
	# trim duplicate formats, duplicate may occurs because JHOVE sometimes dumps out profile (ex. JP2) that is already an format.
	formats.uniq!
  end

  # make sure all formats have associated format registry id.  Otherwise, look up the fda format registry to
  # retrieve the locally defined format id.  
  def resolveFormats
	fdaRegistry = FDAFormat.new
	formats.each do |format|
	  if format.registryName.nil?
	  	fmt = fdaRegistry.find(format.formatName)
	  	# raise FormatError.new("No format registry defined for format name #{format.formatName}.") if fmt.nil?
	  	format.registryName = fmt.registry unless fmt.nil?
	  	format.registryKey = fmt.id unless fmt.nil?
	  end
  end
  end
  
  # calculate md5 and sha1 for the fileObject
  def calculateFixity
    @md5 = Digest::MD5.file(@location).hexdigest 
    @sha1 = Digest::SHA1.file(@location).hexdigest 
  end
end

# extracted metadata of a bitstream object
class BitstreamObject
  attr_accessor :uri
  attr_accessor :formatName
  attr_accessor :objectExtension
end
