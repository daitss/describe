require_relative 'structures'
require_relative 'registry/format2validator'
require_relative 'registry/pronom_format'
require_relative 'registry/validator'
require_relative 'registry/registry'
require_relative 'config'
require 'datyl/logger'

class Result
  attr_accessor :fileObject
  attr_accessor :bitstreams
  attr_accessor :status
  attr_accessor :anomaly

  def initialize
    @anomaly = Set.new
    @bitstreams = Set.new
    @fileObject = FileObject.new
  end
  
  def clear
      @anomaly.clear
      @anomaly = nil      
 
      @bitstreams.clear
      @bitstreams = nil      
  
      @fileObject.clear
      @fileObject = nil
  end
end

class RJhove
  include Singleton

  def initialize
    @validators = open(config_file('validators.xml')) { |io| XML::Document.io io }
    jhoveEngine = Jar.import_from_jars('fcla.format.api.JhoveEngine')
    @jhoveEngine = jhoveEngine.new config_file('jhove.conf')
  end

  # given a list of tentative format id, extract technical metadata of the input file
  def extractAll(input, formats, uri, result)
    # get the list of validators for validating the matching formats
    validators = getValidator(formats)
 
    # make sure there is a validator defined for this validator id
    unless (validators.empty?)
      validators.each do |vdr|
        # create the parser
        require "format/"+ vdr.class.downcase
        parser = eval(vdr.class).new vdr.parameter
        parser.jhoveEngine = @jhoveEngine
        parser.result = result        
     
        # validate and extract metadata
        parser.send vdr.method, input, uri
        
        # if result shows an invalid file, try the next validator in the list if there is any
        if (result.fileObject != nil && isValid(result.status))
          break
        end
      end
    else
      Datyl::Logger.info "no validator is defined for these formats: " + formats.join(",")
    end
    validators.clear
  end

  # given a puid, find the registry format information 
  def findFormat(puid)
	fileformat = FileFormat.new
	format = PRONOMFormat.instance.find_puid(puid)
  	fileformat.formatName = format.name
   	fileformat.formatVersion = format.version
   	fileformat.registryName = format.registry
   	fileformat.registryKey = format.puid	
	fileformat
  end 

  # retrieve general file format properties such as size and format information
  def retrieveFileProperties(input, formats, uri)
    result = Result.new

    result.fileObject.location = input
    result.fileObject.uri = uri
    result.fileObject.size = File.size(input).to_s
    result.fileObject.compositionLevel = '0'
    
    unless (formats.empty?)
      if (formats.size ==  1)
        # we know which exactly what format this file is 
		    fileformat = findFormat(formats.first)
        result.fileObject.formats << fileformat
        result.status = "format identified"
      else
        # ambiguous formats, record all (based on premis data dictionary 2.0, page 196)
        formatName = formats.each do |f| 
          fileformat = findFormat(f)
          fileformat.formatNote = "Candidate Format"
          result.fileObject.formats << fileformat
        end
        result.status = "multiple formats identified"
      end
    else
      fileformat = FileFormat.new
      # for empty file, the format Name should be 'N/A'
      if (File.zero?(input))
        fileformat.formatName = 'N/A'
      else
        # for unempty file that can't be identified, the format name is 'unknown'
        fileformat.formatName = 'Unknown'
      end
      result.fileObject.formats << fileformat
      result.status = "cannot identify file format"
    end

    result
  end

  # get the list of validators that may be used to validate the list of identified formats
  def getValidator(formats)
    validators_list = nil
    fmt2val = Format2Validator.new

    # Set does not allow duplicate, thus it makes sure only a unique validator is put into the ValidatorSet.
    validatorSet = Set.new
    formats.each do |format|
      fmt2val.find_by_rid(format)
      fmt2val.validators.each {|val| validatorSet.add(val)}
    end
    fmt2val.clear
    # Datyl::Logger.info "applicable validators found: #{validatorSet.to_a.join(",")}"  
    # return a prioritized list of validators if applicable
    validators = SortedSet.new
    validatorSet.each do |val|
      xml = @validators.find_first("//validator[name/text()='#{val}']")
      unless (xml.nil?)
        val = Validator.new(@validators, "//validator[name/text()='#{val}']")
        validators.add val
      end
    end
    validatorSet = nil
    validators.sort
  end

  # is the return status from the validator indicates that the file is valid?
  def isValid(status)
    valid = false
    unless status.nil?
      # Datyl::Logger.info "status : #{status}"
      if status.casecmp("well-formed and valid") >=0
        valid = true
      end
    end
    valid
  end

end
