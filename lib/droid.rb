require 'rexml/document'
require 'rubygems'
require 'active_record'

include REXML

class Format < ActiveRecord::Base
  validates_presence_of :registry
end

class Droid
  def initialize(sigFile)
    #create a XML document for the signature file
    io = open sigFile
    @sigFile = Document.new io
    @keyword = 'PUID'
  end

 def extract_V13
    puts "extract_V13"
    startElement = @sigFile.root.elements['/FFSignatureFile/FileFormatCollection']    
    count = 0;    
    startElement.each_element('FileFormat') do |ch|   
      @format = Format.new
      @format.registry = 'PRONOM'
      @format.rid = ch.attributes['PUID']
      if ch.attributes['Version'].nil?
        @format.info =  ch.attributes['Name']
      else
        @format.info = ch.attributes['Name'] + ' ' + ch.attributes['Version']   
      end
      @format.mime_type = ch.attributes['MIMEType']
      extension = ""
      ch.each_element("Extension") do |ext|
        extension += ext.text + ' '
      end
      @format.extensions = extension
      @format.save!
      count += 1
      puts count
    end
    return count    
  end

  def find_formatID(fid)
      format = Format.find(:first, 
                                :conditions => ["formatID = ?", fid])
      return format.registryID
  end

  def find_registryID(rid)
      format = Format.find(:first, 
                                :conditions => ["registryID = ?", rid])
      return format.formatID
  end
end
  