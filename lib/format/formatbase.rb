require 'xml'
 require 'libxslt'
require 'structures'
require 'DescribeLogger'
require 'fileutils'
require 'rjb'
require 'config'
require 'set'
require 'jar'

class FormatBase
  NAMESPACES = {
   'jhove' => 'http://hul.harvard.edu/ois/xml/ns/jhove',
    'mix' => 'http://www.loc.gov/mix/v20',
    'aes' => 'http://www.aes.org/audioObject'
  }

  attr_reader :fileObject # a fileObject to hold the extracted file and format metadata from the described file
  attr_reader :bitstreams # a bitstream object to hold the extracted bitstream metadata for the described file
  attr_reader :anomaly # anomaly found during format validation
  attr_reader :status  # validation status

  def initialize(jhoveModule)
    @module = jhoveModule
    @anomaly = Set.new
    @bitstreams = Array.new
    jhoveEngine = Jar.import_from_jars('shades.JhoveEngine')
    @jhoveEngine = jhoveEngine.new config_file('jhove.conf')
  end

  public
  def setPresumeFormat(format)
    @presumeFormat = format
  end

  def extractWOparse(input)
    # A temporary file to hold the jhove extraction result
    tmp = File.new("extract.xml", "w+")
    output = tmp.path()
    DescribeLogger.instance.info "module #{@module}, input #{input}, output #{output}"
    @jhoveEngine.validateFile @module, input, output
    tmp.close
    nil
  end

  def extract(input, uri)
    @fileOjbect = nil
    @uri = uri
    @location = input

    # create a temperary file to hold the jhove extraction result
    unless (@module.nil?)
      output = "extract.xml"
      FileUtils.touch(output)
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
        FileUtils.remove(output)
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
      @fileObject.location = @location
      @fileObject.uri = @uri
      @fileObject.size = @jhove.find_first('//jhove:size/text()', NAMESPACES)
      @fileObject.compositionLevel = '0'
      recordFormat
    else
      # if JHOVE crash while validating the file, there would be no JHOVE output
      raise FormatError.new("Running into prolems during JHOVE validation and charaterization.  No JHOVE output is generated.")
    end
  end

  # given an know format name and version, find the corresponding format entry in the format registry
  def formatLookup(formatName, formatVersion, presumeFormat)
	fileformat = FileFormat.new
	
	# if there is already a determined presume format, use it as the baseline
	fileformat = presumeFormat if presumeFormat
	
	fileformat.formatName = formatName
	# construct the lookup string using formatName, formatVersion
	if formatVersion
	  fileformat.formatVersion = formatVersion
	  lookup = formatName.to_s + ' ' + formatVersion.to_s
    else
      lookup = formatName.to_s
    end

	# lookup the registry entry
    registry = Registry.instance.find_by_lookup(lookup)

    # make sure there is a format registry record
    unless (registry.nil?)
      fileformat.registryName = registry.name
      fileformat.registryKey = registry.identifier
    end

	# return fileformat
	fileformat
  end

  # extract and process identified formats in JHOVE.
  def recordFormat
    #retrieve the format name
    unless (@jhove.find_first('//jhove:format', NAMESPACES).nil?)
      formatName = @jhove.find_first('//jhove:format', NAMESPACES).content
	  formatVersion = nil
      # retrieve format version
      unless (@jhove.find_first('//jhove:version', NAMESPACES).nil?)
        formatVersion = @jhove.find_first('//jhove:version', NAMESPACES).content
      end
	  
	  fileformat = formatLookup(formatName, formatVersion, @presumeFormat)
	  @fileObject.formats << fileformat

      # record and lookup extracted format profiles from jhove
      profiles = @jhove.find('//jhove:profiles/jhove:profile', NAMESPACES)
      if profiles
        # retrieve all recognized profiles
        profiles.each do |p|
      	  fileformat = formatLookup(p.content, nil, nil)
		  fileformat.formatNote = "Alternate Format"
		  @fileObject.formats << fileformat
        end
      end
    end
  end

  # apply stylesheet into an xml document
  def apply_xsl xsl_file_name
    stylesheet_file = xsl_file xsl_file_name
    stylesheet_doc = open(stylesheet_file) { |io| LibXML::XML::Document::io io }
    stylesheet = LibXSLT::XSLT::Stylesheet.new stylesheet_doc

    # apply the xslt
    jdoc = LibXML::XML::Document.string @jhove.to_s
    # jdoc.root = jdoc.import @jhove
    stylesheet.apply jdoc
  end

end
