#!/usr/local/env ruby
require 'rubygems'
require 'rjb'
require 'singleton'
require 'DescribeLogger'

class RDroid
  include Singleton

  def initialize
    #create the JAVA Minimal object
    mindroid = Rjb::import('shades.MinimalDroid')
    @droid = mindroid.new('config/DROID_SignatureFile_V13.xml')
  end

  def identify(input)
    puids = @droid.IdentifyFile(input)
    puidsHash = Hash.new
    # iterate through the list of returned puids (java code) and put them
    # in a ruby hash
    puidsItr = puids.entrySet().iterator()
    while puidsItr.hasNext()
      entry = puidsItr.next()
      puidsHash[entry.key().toString] = entry.value().toString
    end
    # build a list of tentative format id that should be tested
    formats = Array.new
    puidsHash.each do |key, value|
      formats << key
    end

    formats
  end
  
end