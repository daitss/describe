require 'xml'
require 'structures'
require 'DescribeLogger'
require 'fileutils'
require 'rjb'

class FormatError < StandardError; end
  
class FormatBase
  
  JHOVE_NS = "jhove:http://hul.harvard.edu/ois/xml/ns/jhove"

  attr_reader :fileObject
  attr_reader :bitstreams
  attr_reader :anomaly
  attr_reader :status
  
  def initialize(jhoveModule)
    @module = jhoveModule
    @anomaly = Set.new
    @bitstreams = Array.new
    jhoveEngine =Rjb::import('shades.JhoveEngine')
    @jhoveEngine = jhoveEngine.new('config/jhove.conf')
  end

  public
  def setFormat(registry, registryKey)
    @registry = registry
    @registryKey = registryKey
  end
  
  def extractWOparse(input)
    # A temporary file to hold the jhove extraction result
    tmp = File.new("extract.xml", "w+")
    output = tmp.path()
    DescribeLogger.instance.info "module #{@module}, input #{input}, output #{output}"
    @jhoveEngine.validateFile @module, input, output
    nil
  end

  def extract(input)
    @fileOjbect = nil

    # create a temperary file to hold the jhove extraction result
    unless (@module.nil?)
      tmp = File.new("extract.xml", "w+")
      output = tmp.path()
      tmp.close
      DescribeLogger.instance.info "module #{@module}, input #{input}, output #{output}"
      @jhoveEngine.validateFile @module, input, output 
      begin
        io = open output
        XML.default_keep_blanks = false
        doc = XML::Document.io io
        # parse the jhove output, extracting only the information we need
        parse(doc) 
        # parse the validation result, record anomaly
        messages = @jhove.find('jhove:messages/jhove:message', JHOVE_NS) 
        messages.each do |msg|
          @anomaly.add msg.content
        end
        io.close
        File.delete output
        @status = @jhove.find_first('jhove:status', JHOVE_NS).content
      rescue  => ex
        DescribeLogger.instance.error ex
      end
    end
    @status
  end

  protected
  def parse(doc)
    @jhove = doc.find_first("//jhove:repInfo", JHOVE_NS)
    unless (@jhove.nil?)
      @fileObject = FileObject.new
      @fileObject.url = @jhove.attributes['uri']
      @fileObject.size = @jhove.find_first('//jhove:size/text()', JHOVE_NS)
      @fileObject.compositionLevel = '0'
      recordFormat

      # create the object characteristic extension element to hold the format metadata
      @fileObject.objectExtension = XML::Node.new('objectCharacteristicsExtension')
    else
      # if JHOVE crash while validating the file, there would be no JHOVE output
      raise FormatError.new("No JHOVE output")
    end 
  end

  def recordFormat
    #retreive the format name
    unless (@jhove.find_first('//jhove:format', JHOVE_NS).nil?)
      @fileObject.formatName = @jhove.find_first('//jhove:format', JHOVE_NS).content
      # retrieve the format version
      unless (@jhove.find_first('//jhove:version', JHOVE_NS).nil?)
        @fileObject.formatVersion = @jhove.find_first('//jhove:version', JHOVE_NS).content

        lookup = @fileObject.formatName.to_s + ' ' + @fileObject.formatVersion.to_s

        record = Format2Validator.instance.find_by_lookup(lookup)
        # make sure there is a format record, 
        # if the format identifier has been decided (by format identification), skip this
        unless (record.nil?)
          fmt = Format.instance.find_puid(record.rid)
          @registry = fmt.registry
          @registryKey = fmt.puid
          DescribeLogger.instance.info "#{@registry} : #{@registryKey}"
        end
      end

      # record format profiles in multiple format designation
      profiles = @jhove.find('//jhove:profiles/jhove:profile', JHOVE_NS)
      unless (profiles.nil?)
        @fileObject.profiles = Array.new
        # traverse through all profiles and append them to create multipart format name
        profiles.each do |p|
          @fileObject.profiles << p.content
          end
      end
    end

    @fileObject.registryName = @registry
    @fileObject.registryKey = @registryKey
  end
end
