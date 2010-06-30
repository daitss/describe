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
end

class RJhove
  attr_reader :result

  def initialize
    @validators = XML::Document.file config_file('validators.xml')
  end

  # given a tentative format id, extract technical metadata of the input file
  def extract(input, format)
    # retrieve the validator used for this format
    vdr = Format2Validator.new
    vdr.find_by_rid(format)

    # make sure this is a valid format
    if (vdr.nil?)
      DescribeLogger.instance.warn "no validator for this format id #{format}"
      result = nil
    else
      DescribeLogger.instance.info "validator id #{vdr.validator}"
      xml = @validators.find_first("//validator[name/text()='#{vdr.validator}']")

      # make sure there is a validator defined for this format
      unless (xml.nil?)    
        validator = Validator.new(@validators, "//validator[name/text()='#{vdr.validator}']")    
    
        # create the parser
        DescribeLogger.instance.info "validator: #{validator.class} method: #{validator.method}" 
        require "format/"+ validator.class.downcase
        parser = eval(validator.class).new validator.parameter

		# set the presume format since we already determine the file foramt prior to validation. 
        parser.setPresumeFormat(findFormat(format))
   
        # validate and extract the metadata
        result = parser.send validator.method, input, input
      else
        DescribeLogger.instance.warn "No validator is defined for this format " + format
        result = nil
      end
    end
    result
  end

  # given a list of tentative format id, extract technical metadata of the input file
  def extractAll(input, formats, uri)
    @result = nil

    # get the list of validators for validating the matching formats
    validators = getValidator(formats)

    # make sure there is a validator defined for this validator id
    unless (validators.empty?)
      @result = Result.new
      validators.each do |vdr|
        DescribeLogger.instance.info "validator: #{vdr.class}, method: #{vdr.method}, parameter: #{vdr.parameter}"
        # create the parser
        require "format/"+ vdr.class.downcase
        parser = eval(vdr.class).new vdr.parameter

        # set the presume format if we can already determine the file foramt prior to validation. 
        parser.setPresumeFormat(findFormat(formats.first)) if (formats.size ==  1)
        
        # validate and extract metadata
        @result.status = parser.send vdr.method, input, uri
        @result.anomaly = parser.anomaly
        @result.fileObject = parser.fileObject
        @result.bitstreams = parser.bitstreams

        # if result shows an invalid file, try the next validator in the list if there is any
        if (@result.fileObject != nil && isValid(@result.status))
          DescribeLogger.instance.info "valid #{vdr.name}"
          break
        end
      end
      # for consistency, use the format name and version in the registry instead of using the validator output
      @result.fileObject.formats.each do |format| 
		f = PRONOMFormat.instance.find_puid(format.registryKey)
		if f
	  	  format.formatName = f.name
	   	  format.formatVersion = f.version
	    end
	  end
    else
      DescribeLogger.instance.info "no validator is defined for these formats: " + formats.join(",")
      # no validator, retrieve the basic file metadata
      @result = retrieveFileProperties(input, formats, uri)
    end

    @result
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
    @result = nil
    @result = Result.new

    @result.fileObject = FileObject.new
    @result.fileObject.location = input
    @result.fileObject.uri = uri
    @result.fileObject.size = File.size(input).to_s
    @result.fileObject.compositionLevel = '0'
    
    unless (formats.empty?)
      if (formats.size ==  1)
        # we know which exactly what format this file is 
		fileformat = findFormat(formats.first)
        @result.fileObject.formats << fileformat
        @result.status = "format identified"
      else
        # ambiguous formats, record all (based on premis data dictionary 2.0, page 196)
        formatName = formats.each do |f| 
		  fileformat = findFormat(f)
		  fileformat.formatNote = "Candidate Format"
          @result.fileObject.formats << fileformat
          end
        @result.status = "multiple formats identified"
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
	  @result.fileObject.formats << fileformat
      @result.status = "cannot identify file format of the file: #{input}"
    end

    @result
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

    DescribeLogger.instance.info "applicable validators found: #{validatorSet.to_a.join(",")}"  
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
      DescribeLogger.instance.info "status : #{status}"
      if status.casecmp("well-formed and valid") >=0
        valid = true
      end
    end
    valid
  end

end
