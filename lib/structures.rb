#!/usr/local/env ruby

class Inhibitor
  attr_accessor :type
  attr_accessor :target
  attr_accessor :key
end

class FileObject
  attr_accessor :location
  attr_accessor :uri
  attr_accessor :size
  attr_accessor :originalName
  attr_accessor :compositionLevel
  attr_accessor :registryName
  attr_accessor :registryKey
  attr_accessor :formatName
  attr_accessor :formatVersion
  attr_accessor :profiles
  attr_accessor :objectExtension
  attr_accessor :inhibitors
  attr_accessor :createAppName
  attr_accessor :createAppVersion
  attr_accessor :createDate
end

class BitstreamObject
  attr_accessor :uri
  attr_accessor :formatName
  attr_accessor :objectExtension
end
