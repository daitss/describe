#!/usr/local/env ruby
require 'rubygems' 
require 'structures'
require 'registry'
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
    vdr = Format2Validator.instance.find_by_rid(format)

    # make sure this is a valid format
    if (vdr.nil?)
      DescribeLogger.instance.warn "no format for this format id #{format}"
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

        # retrive the format record
        fmt = Format.instance.find_puid(format)
        DescribeLogger.instance.info "registry: #{fmt.registry} puid: #{fmt.puid}" 
        parser.setFormat(fmt.registry, fmt.puid)

        # validate and extract the metadata
        result = parser.send validator.method, input
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

        #set the format identifier if known
        if (formats.size ==  1)
          # retrive the format record
          format = Format.instance.find_puid(formats.first)
          parser.setFormat(format.registry, format.puid)
        end
        # validate and extract the metadata
        @result.status = parser.send vdr.method, input, uri
        @result.anomaly = parser.anomaly
        @result.fileObject = parser.fileObject
        @result.bitstreams = parser.bitstreams

        #if result shows an invalid file, try the next validator in the list if there is one
        if (@result.fileObject != nil && isValid(@result.status))
          DescribeLogger.instance.info "valid #{vdr.name}"
          break
        end
      end
    else
      DescribeLogger.instance.info "no validator is defined for these formats: " + formats.join(",")
      # no validator, create the base validator to record the basic file properties
      @result = retrieveFileProperties(input, formats, uri)
    end

    @result
  end

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
        # we know which one
        format = Format.instance.find_puid(formats.first)
        @result.fileObject.formatName = format.name
        @result.fileObject.registryName = format.registry
        @result.fileObject.registryKey = format.puid
        @result.status = "format identified"
      else
        # ambiguous formats, need to find a temporary format identifier for future resolution
        formatName = formats.map {|f| 
          format = Format.instance.find_puid(f)
          s = String.new
          s += format.name
          s += ' ' + format.version if format.version
          puts s
          s
          }.join ', '

        @result.fileObject.formatName = formatName
        @result.status = "multiple formats identified"
      end
    else
      # for empty file, the format Name should be 'N/A'
      if (File.zero?(input))
        @result.fileObject.formatName = 'N/A'
      else
        # for unempty file that can't be identified, the format name is 'unknown'
        @result.fileObject.formatName = 'unknown'
      end
      @result.status = "cannot identify this file: #{input}"
    end

    @result
  end

  def getValidator(formats)
    validators_list = nil
    validator = nil

    # Set does not allow duplicate, thus it makes sure only a unique validator is put into the ValidatorSet.
    validatorSet = Set.new
    formats.each do |format|
      validator = Format2Validator.instance.find_by_rid(format)
      unless validator.nil?
        DescribeLogger.instance.info "#{format}"
        validatorSet.add(validator.validator)
      end
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
