require 'xml'
require 'structures'
require 'DescribeLogger'
require 'fileutils'
require 'rjb'
require 'config'
require 'set'

class FormatError < StandardError; end
  
class FormatBase
  NAMESPACES = {
   'jhove' => 'http://hul.harvard.edu/ois/xml/ns/jhove',
    'mix' => 'http://www.loc.gov/mix/v20',
    'aes' => 'http://www.aes.org/audioObject'
  }

  attr_reader :fileObject
  attr_reader :bitstreams
  attr_reader :anomaly
  attr_reader :status
  
  def initialize(jhoveModule)
    @module = jhoveModule
    @anomaly = Set.new
    @bitstreams = Array.new
    jhoveEngine = Rjb::import('shades.JhoveEngine')
    @jhoveEngine = jhoveEngine.new config_file('jhove.conf')
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
        messages = @jhove.find('jhove:messages/jhove:message', NAMESPACES) 
        messages.each do |msg|
          @anomaly.add msg.content
        end
        io.close
        File.delete output
        @status = @jhove.find_first('jhove:status', NAMESPACES).content
      rescue  => ex
        DescribeLogger.instance.error ex
      end
    end
    @status
  end

  protected
  def parse(doc)
    @jhove = doc.find_first("//jhove:repInfo", NAMESPACES)
    # puts @jhove
    unless (@jhove.nil?)
      @fileObject = FileObject.new
      @fileObject.url = @jhove.attributes['uri']
      @fileObject.size = @jhove.find_first('//jhove:size/text()', NAMESPACES)
      @fileObject.compositionLevel = '0'
      recordFormat
    else
      # if JHOVE crash while validating the file, there would be no JHOVE output
      raise FormatError.new("No JHOVE output")
    end 
  end

  def recordFormat
    #retreive the format name
    unless (@jhove.find_first('//jhove:format', NAMESPACES).nil?)
      @fileObject.formatName = @jhove.find_first('//jhove:format', NAMESPACES).content
      # retrieve the format version
      unless (@jhove.find_first('//jhove:version', NAMESPACES).nil?)
        @fileObject.formatVersion = @jhove.find_first('//jhove:version', NAMESPACES).content
        lookup = @fileObject.formatName.to_s + ' ' + @fileObject.formatVersion.to_s
      else
        lookup = @fileObject.formatName.to_s
      end
      record = Format2Validator.instance.find_by_lookup(lookup)

      # make sure there is a format record, 
      # if the format identifier has been decided (by format identification), skip this
      unless (record.nil?)
        fmt = Format.instance.find_puid(record.rid)
        @registry = fmt.registry
        @registryKey = fmt.puid
        DescribeLogger.instance.info "#{@registry} : #{@registryKey}"
      end
    
      # record format profiles in multiple format designation
      profiles = @jhove.find('//jhove:profiles/jhove:profile', NAMESPACES)
      unless (profiles.nil?)
        @fileObject.profiles = Array.new
        # retrieve through all profiles
        profiles.each do |p|
          @fileObject.profiles << p.content
          end
      end
    end

    @fileObject.registryName = @registry
    @fileObject.registryKey = @registryKey
  end

  require 'libxml'
  require 'libxslt'

  def apply_xsl xsl_file_name
    stylesheet_file = xsl_file xsl_file_name
    stylesheet_doc = open(stylesheet_file) { |io| LibXML::XML::Document::io io }
    stylesheet = LibXSLT::XSLT::Stylesheet.new stylesheet_doc

    # apply the xslt
    jdoc = LibXML::XML::Document.string @jhove.to_s
    #jdoc.root = jdoc.import @jhove
    stylesheet.apply jdoc
  end
  

end
