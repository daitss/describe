require 'xml'
require 'libxslt'
require 'structures'
require 'fileutils'
require 'rjb'
require 'set'
require 'jar'

class FormatBase
  NAMESPACES = {
   'jhove' => 'http://hul.harvard.edu/ois/xml/ns/jhove',
    'mix' => 'http://www.loc.gov/mix/v20',
    'aes' => 'http://www.aes.org/audioObject'
  }

  attr_accessor :jhoveEngine # An instance of JHOVE interface
  attr_accessor :result      # placeholder for the validation and characterization result
  
  def initialize(jhoveModule)
    @module = jhoveModule
  end

  public
 
  def extract(input, uri)
    @uri = uri
    @location = input
    @invalid = false
    
    # create a temperary file to hold the jhove extraction result
    unless (@module.nil?)
      output = "extract_#{Process.pid}.xml"
      begin        
        @jhoveEngine.validateFile @module, input, output
 
        io = open output
        XML.default_keep_blanks = false
        doc = XML::Document.io io
        # parse the jhove output, extracting the metadata we need to record
        parse(doc)
         
        # parse the validation result, record anomaly
        messages = @jhove.find('jhove:messages/jhove:message', NAMESPACES)
        messages.each do |msg|
          @result.anomaly.add msg.content unless msg.content.empty?
        end
        @result.status = @jhove.find_first('jhove:status', NAMESPACES).content
        if @result.status.casecmp("well-formed and valid") >=0 && @invalid
          @result.status = "Well-Formed, but not valid""
        end
        
        @jhove = nil
        io.close 
        FileUtils.rm output       
      rescue  => e
        raise "running into exception #{e.class} '#{e.message}' while processing #{input.length} bytes of input\n#{e.backtrace.join('\n')}"
      end
    end
  end

  protected  
  def parse(doc)
    @jhove = doc.find_first("//jhove:repInfo", NAMESPACES)

    unless (@jhove.nil?)
      @result.fileObject.location = @location
      @result.fileObject.uri = @uri
      @result.fileObject.size = @jhove.find_first('//jhove:size/text()', NAMESPACES)
      @result.fileObject.compositionLevel = '0'
    else
      # if JHOVE crash while validating the file, there would be no JHOVE output
      raise FormatError.new("Running into prolems during JHOVE validation and charaterization.  No JHOVE output is generated.")
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
