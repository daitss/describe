require 'rexml/document'
require 'RJhove'
require 'premis'
require 'DescribeLogger'

include REXML

class FormatError < StandardError; end
  
class FormatBase
  attr_reader :fileObject
  attr_reader :bsObjects
  attr_reader :anomaly
  attr_reader :status
  
  def initialize(jhoveModule)
    @module = jhoveModule
    @anomaly = Set.new
  end

  public
  def setFormat(registry, registryKey)
    @registry = registry
    @registryKey = registryKey
  end
  
  def extractWOparse(input)
    jhove = RJhove.instance

    # A temporary file to hold the jhove extraction result
    tmp = Tempfile.new("extract-format.xml")
    output = tmp.path()
    DescribeLogger.instance.info "module #{@module}, input #{input}, output #{output}"
    jhove.jhoveEngine.validateFile @module, input, output

    io = open output
    doc = Document.new io
    premis = Premis.new
    @jhove = doc.root.elements['/jhove/repInfo']
    premis.root.add_element @jhove
    premis
  end

  def extract(input)
    jhove = RJhove.instance

    # create a temperary file to hold the jhove extraction result
    unless (@module.nil?)
      tmp = Tempfile.new("extract-format.xml")
      output = tmp.path()
      jhove.jhoveEngine.validateFile @module, input, output

      io = open output
      doc = Document.new io

      # parse the jhove output, extracting only the information we need
      begin
        parse(doc) 

        # parse the validation result, record anomaly
        @jhove.elements.each('messages//message') do |msg|
          @anomaly.add msg.text
        end
        
        @status = @jhove.elements['status'].get_text
      rescue FormatError => ex
        DescribeLogger.instance.error ex.message
      end
    else
      
    end
    @status
  end

  protected
  def parse(xml)
    @jhove = xml.root.elements['/jhove/repInfo']    
    unless (@jhove.nil?)
      @fileObject = FileObject.new
      @fileObject.url = @jhove.attributes['uri'].to_s
      @fileObject.size = @jhove.elements['size'].get_text.to_s
      @fileObject.compositionLevel = '0'
      recordFormat

      # create the object characteristic extension element to hold the format metadata
      @fileObject.objectExtension = Element.new('objectCharacteristicsExtension')
    else
      # if JHOVE crash while validating the file, there would be no JHOVE output
      raise FormatError.new("No JHOVE output")
    end 
  end

  def recordFormat
    #retreive the format name
    unless (@jhove.elements['format'].nil?)
      formatName = @jhove.elements['format'].get_text.to_s
      
      # retrieve format profiles
      # TODO recording format profiles in multiple format designation, waiting for premis schema fixes
      # unless (@jhove.elements['profiles'].nil?)
      #   # traverse through all profiles and append them to create multipart format name
      #   @jhove.elements.each('profiles//profile') do |p|
      #     formatName = formatName + '_' + p.get_text.to_s
      #     end
      #   puts @jhove.elements['profiles']
      # end
      
      @fileObject.formatName = formatName
      # retrieve the format version
      unless (@jhove.elements['version'].nil?)
        # puts @jhove.elements['version']
        @fileObject.formatVersion = @jhove.elements['version'].get_text

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
    end

    @fileObject.registryName = @registry
    @fileObject.registryKey = @registryKey
  end
end
