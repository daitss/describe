#!/usr/local/env ruby
require 'rubygems' 
require 'structures'
require 'registry/format2validator'
require 'registry/pronom_format'
require 'registry/validator'
require 'registry/registry'
require 'DescribeLogger'
require 'config'

class Result
  attr_accessor :fileObject
  attr_accessor :bitstreams
  attr_accessor :status
  attr_accessor :anomaly
  
  def clear
    if @anomaly
      @anomaly.clear
      @anomaly = nil      
    end

    if @bitstreams
      @bitstreams.clear
      @bitstreams = nil      
    end

    if @fileObject
      @fileObject.clear
      @fileObject = nil
    end
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
  def extractAll(input, formats, uri)
    # get the list of validators for validating the matching formats
    validators = getValidator(formats)

    # make sure there is a validator defined for this validator id
    unless (validators.empty?)
      result = Result.new
      validators.each do |vdr|
        # DescribeLogger.instance.info "validator: #{vdr.class}, method: #{vdr.method}, parameter: #{vdr.parameter}"
        # create the parser
        require "format/"+ vdr.class.downcase
        parser = eval(vdr.class).new vdr.parameter
        parser.jhoveEngine = @jhoveEngine
        # set the presume format if we can already determine the file foramt prior to validation. 
        parser.setPresumeFormat(findFormat(formats.first)) if (formats.size ==  1)
        
        # validate and extract metadata
        result.status = parser.send vdr.method, input, uri
        result.anomaly = parser.anomaly
        result.fileObject = parser.fileObject
        result.bitstreams = parser.bitstreams
        
        # if result shows an invalid file, try the next validator in the list if there is any
        if (result.fileObject != nil && isValid(result.status))
          break
        end
      end
      # for consistency, use the format name and version in the registry instead of using the validator output
      result.fileObject.formats.each do |format| 
        f = PRONOMFormat.instance.find_puid(format.registryKey)
        if f
          format.formatName = f.name
          format.formatVersion = f.version
        end
      end
    else
      DescribeLogger.instance.info "no validator is defined for these formats: " + formats.join(",")
      # no validator, retrieve the basic file metadata
      result = retrieveFileProperties(input, formats, uri)
    end
    validators.clear
    result
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

    result.fileObject = FileObject.new
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
    # DescribeLogger.instance.info "applicable validators found: #{validatorSet.to_a.join(",")}"  
    # return a prioritized list of validators if applicable
    validators = SortedSet.new
    validatorSet.each do |val|
      xml = @validators.find_first("//validator[name/text()='#{val}']")
      unless (xml.nil?)
        val = Validator.new(@validators, "//validator[name/text()='#{val}']")
        validators.add val
      end
    end
    validators.sort
  end

  # is the return status from the validator indicates that the file is valid?
  def isValid(status)
    valid = false
    unless status.nil?
      # DescribeLogger.instance.info "status : #{status}"
      if status.casecmp("well-formed and valid") >=0
        valid = true
      end
    end
    valid
  end

end
