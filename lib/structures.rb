#!/usr/local/env ruby

# a placeholder for holding the extracted values from the format characterization.
# the metadata extracted here conform to premis data dictionary.  Please
# see Premis data dictionary 2.0 for explaination of the metadata.

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
end

# extracted metadata of a bitstream object
class BitstreamObject
  attr_accessor :uri
  attr_accessor :formatName
  attr_accessor :objectExtension
end
