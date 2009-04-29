#!/usr/local/env ruby
require 'rubygems'
require 'rjb'
require 'active_record'
require 'singleton'
require 'premis'
require 'DescribeLogger'

ActiveRecord::Base.establish_connection(
:adapter  => "mysql",
:host     => "localhost",
:database => "shades_dev",
:username => "root",
:password => "")

class Format < ActiveRecord::Base
  validates_presence_of :registry, :rid
end

class Validator < ActiveRecord::Base
  validates_presence_of :id
end

class RJhove
  attr_reader :jhoveEngine
  include Singleton

  def initialize
    # create the one and only JHOVE engine (the singleton)
    jhoveEngine =Rjb::import('shades.JhoveEngine')
    @jhoveEngine = jhoveEngine.new('config/jhove.conf')
    #find and load all the plugin
    Dir.glob("lib/*.rb").each do |file|
      load(file) unless file ==$0
    end
  end

  # given a tentative format id, extract technical metadata of the input file
  def extract(input, format)
    # retrieve the validator used for this format
    fmt = Format.find(:first, :conditions => ["rid = ?", format])

    # make sure this is a valid format
    if (fmt.nil?)
      DescribeLogger.instance.warn "no format for this format id #{format}"
      result = nil
    else
      DescribeLogger.instance.info "validator id #{fmt.validator}"
      vdr = Validator.find(:first, :conditions => ["id = ?", fmt.validator])

      # make sure there is a validator defined for this format
      unless (vdr.nil?)        
        # create the parser
        DescribeLogger.instance.info "validator: #{vdr.name} method: #{vdr.routine}" 
        parser = eval(vdr.name).new vdr.arguments

        parser.setFormat(fmt.registry, fmt.rid)
        
        # validate and extract the metadata
        result = parser.send vdr.routine, input
      else
        DescribeLogger.instance.warn "No validator is defined for this format " + format
        result = nil
      end
    end
    result
  end

  # given a list of tentative format id, extract technical metadata of the input file
  def extractAll(input, formats)
    premis = nil
    
    # get the list of validators for validating the matching formats
    validators = getValidator(formats)
    
    # make sure there is a validator defined for this validator id
    unless (validators.empty?)
      validators.each do |vdr|
        premis = nil
        DescribeLogger.instance.info "validator: #{vdr.name}, method: #{vdr.routine}, arguments: #{vdr.arguments}"
        # create the parser
        parser = eval(vdr.name).new vdr.arguments

        #set the format identifier if known
        if (formats.size ==  1)
          # retrive the format record
          format = Format.find(:first, :conditions => ["rid = ?", formats.first])
          parser.setFormat(format.registry, format.rid)
        end
        # validate and extract the metadata
        premis = parser.send vdr.routine, input
        
        #if result shows an invalid file, try the next validator in the list if there is one
        if (premis != nil && isValid(premis.toDocument))
            DescribeLogger.instance.info "valid #{vdr.name}"
          break
        end
      end
    else
      DescribeLogger.instance.info "no validator is defined for these formats #{formats}"
      # no validator, record the basic file properties
      premis = retrieveFileProperties(input, formats)
    end
    premis
  end
  
  def retrieveFileProperties(input, formats)
    premis = Premis.new
    fileObject = FileObject.new
    fileObject.url = input
    fileObject.size = File.size(input).to_s
    unless (formats.empty?)
      if (formats.size ==  1)
        # we know which one
        format = Format.find(:first, :conditions => ["rid = ?", formats.first])
        fileObject.formatName = format.info
        fileObject.registryName = format.registry
        fileObject.registryKey = format.rid
        status = "format identified"
      else
        # ambiguous formats, need to find a temporary format identifier for future resolution
        formatName = String.new
        formats.each do |f|
          format = Format.find(:first, :conditions => ["rid = ?", f])
          formatName << format.info
          formatName << ', '
        end
        fileObject.formatName = formatName
        status = "multiple formats identified"
      end
    else
      # for empty file, the format Name should be 'N/A'
      if (File.zero?(input))
        fileObject.formatName = 'N/A'
      else
        # for unempty file that can't be identified, the format name is 'unknown'
        fileObject.formatName = 'unknown'
      end
      status = "cannot identify this file: #{input}"
    end
    
    premis.createFileObject(fileObject)
    eventOutcomeInfo = premis.createEventOutcomeInfo(status, nil, nil)
    premis.createEvent('1', eventOutcomeInfo)
  
    premis
  end
  
  def getValidator(formats)
    validators_list = nil
    validator = nil
    
    validatorSet = Set.new
    formats.each do |format|
      fmt = Format.find(:first, :conditions => ["rid = ?", format])
      # make sure there is a validator defined
      unless (fmt.nil? || fmt.validator.nil?)
        DescribeLogger.instance.info "#{fmt.registry}/#{fmt.rid}, #{fmt.info}"
        # add unqiue validator id to our validators set
        validatorSet.add(fmt.validator)
      end
    end
    
    DescribeLogger.instance.info "applicable validators found: #{validatorSet.to_a.join(",")}"
    #return a prioritized list of validators if applicable
    validators = Validator.find(:all, :conditions => {:id => validatorSet.to_a}, :order=> "priority DESC")
    validators
  end

  def selectFormat(formats)
    format = nil
    # TODO: if only one format return the one.  Otherwise, 
    formats.each do |f|
      format = Format.find(:first, :conditions => ["rid = ?", f])
      break
    end
    format
  end
   
  def isValid(xml)
    valid = false
    result = xml.root.elements['/premis/event/eventOutcomeInformation/eventOutcome']
    unless result.nil?
      DescribeLogger.instance.info "status : #{result.text}"
      if result.text.casecmp("well-formed and valid") >=0
        valid = true
      end
    end
    valid
  end
end
