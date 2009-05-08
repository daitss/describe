#!/usr/local/env ruby
require 'rubygems'
require 'active_record'
require 'digest/md5'

class Inhibitor
  attr_accessor :type
  attr_accessor :target
  attr_accessor :key
end

class FileObject
  attr_accessor :url
  attr_accessor :size
  attr_accessor :compositionLevel
  attr_accessor :registryName
  attr_accessor :registryKey
  attr_accessor :formatName
  attr_accessor :formatVersion
  attr_accessor :objectExtension
  attr_accessor :inhibitors
  attr_accessor :createAppName
  attr_accessor :createAppVersion
  attr_accessor :createDate

  def initialize
    @inhibitors = Array.new
  end
end

class Premis
  attr_reader :root

  def initialize
    #create premis 
    @root = Element.new('premis') 
    #add premis namespace
    @root.add_namespace("info:lc/xmlns/premis-v2")
    @root.add_namespace("xsi","http://www.w3.org/2001/XMLSchema-instance")
    #add premis schema location
    @root.add_attribute("xsi:schemaLocation","info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/draft-schemas-2-0/premis-v2-0.xsd")
    @root.add_attribute("version", "2.0")

  end

  def toDocument
    @doc = Document.new
    @doc.add_element @root
    #insert the XML declaration
    @doc << XMLDecl.new
    @doc
  end

  #create premis file object using the information in fileObject
  def createFileObject(fileObject)
    #create premis file object
    object = Element.new('object')
    object.add_attributes( {'xsi:type' => 'file'} )

    #object identifier
    objId = Element.new('objectIdentifier')
    type   = Element.new('objectIdentifierType')
    type.add_text('DAITSS2')
    objId.add_element type
    value = Element.new('objectIdentifierValue')
    value.add_text(fileObject.url)
    objId.add_element value
    object.add_element objId

    #create object characteristic
    objectChar = Element.new('objectCharacteristics')
    compositionLevel = Element.new('compositionLevel')
    compositionLevel.add_text(fileObject.compositionLevel)
    objectChar.add_element compositionLevel

    size = Element.new('size')
    size.add_text(fileObject.size)
    objectChar.add_element size

    objectChar.add_element createFormat(fileObject)     
    objectChar.add_element createCreatingApplication(fileObject)
    objectChar.add_element createFixity(fileObject.url)

    unless (fileObject.objectExtension.nil?)
      objectChar.add_element fileObject.objectExtension
    end

    unless (fileObject.inhibitors.nil?)
      objectChar.add_element createInhibitor(fileObject.inhibitors)
    end

    object.add_element objectChar
    @root.add_element object
  end

  #create the premis format element, using the information from the fileObject
  def createFormat(fileObject)
    format = Element.new('format')

    unless (fileObject.formatName.nil?)
      #format designation
      formatDesignation = Element.new('formatDesignation')
      ele = Element.new('formatName')
      ele.add_text(fileObject.formatName)
      formatDesignation.add_element ele

      # format version
      unless (fileObject.formatVersion.nil?)
        ele = Element.new('formatVersion')
        ele.add_text(fileObject.formatVersion)
        formatDesignation.add_element ele
      end
      format.add_element formatDesignation

      #format registry
      unless (fileObject.registryName.nil?)
        formatRegistry = Element.new('formatRegistry')
        regName = Element.new('formatRegistryName')
        regName.add_text(fileObject.registryName)
        formatRegistry.add_element regName
        regKey = Element.new('formatRegistryKey')
        regKey.add_text(fileObject.registryKey)
        formatRegistry.add_element regKey
        format.add_element formatRegistry
      end
    end

    format
  end

  # create the "CreatingApplication" premis element
  def createCreatingApplication(fileObject)
    creatingApplication = Element.new('creatingApplication')
    unless fileObject.createAppName.nil?
      creatingApplicationName = Element.new('creatingApplicationName')
      creatingApplicationName.add_text(fileObject.createAppName)
      creatingApplication.add_element creatingApplicationName
    end
    unless fileObject.createAppVersion.nil?
      creatingApplicationVersion = Element.new('creatingApplicationVersion')
      creatingApplicationVersion.add_text(fileObject.createAppVersion)
      creatingApplication.add_element creatingApplicationVersion
    end
    unless fileObject.createDate.nil?
      dateCreatedByApplication = Element.new('dateCreatedByApplication')
      dateCreatedByApplication.add_text(fileObject.createDate)
      creatingApplication.add_element dateCreatedByApplication
    end
    creatingApplication
  end

  # create premis agent
  def createAgent(url)
    agent = Element.new('agent')

    #agent identifier
    agentId = Element.new('agentIdentifier')
    type   = Element.new('agentIdentifierType')
    type.add_text('uri')
    agentId.add_element type
    value   = Element.new('agentIdentifierValue')
    value.add_text(url)
    agentId.add_element value
    agent.add_element agentId

    # agentName
    name = Element.new('agentName')
    name.add_text('Format Description Service')
    agent.add_element name

    #agentType
    type = Element.new('agentType')
    type.add_text('Web Service')
    agent.add_element type

    #add agent element
    @root.add_element agent
  end

  # create premis event with the specified event id and eventOutcomeInfo
  def createEvent(eventid, eventOutcomeInfo)
    event = Element.new('event')

    #event identifier
    eventId = Element.new('eventIdentifier')
    type   = Element.new('eventIdentifierType')
    type.add_text('DAITSS2')
    eventId.add_element type
    value   = Element.new('eventIdentifierValue')
    value.add_text(eventid)  #TODO put int real event id
    eventId.add_element value
    event.add_element eventId

    #eventType
    type = Element.new('eventType')
    type.add_text('Format Description')
    event.add_element type

    #eventDateTime
    eventTime = Element.new('eventDateTime')
    eventTime.add_text(Time.now.strftime("%Y-%m-%dT%H:%M:%S"))
    event.add_element eventTime

    #eventOutcome
    unless (eventOutcomeInfo.nil?)
      event.add_element eventOutcomeInfo
    end

    #add to root
    @root.add_element event
  end

  # create a premis event outout info, using the status and messages
  def createEventOutcomeInfo(status, messageType, messages)
    #create the event outcome 
    eventOutcomeInfo = Element.new('eventOutcomeInformation')
    eventOutcome = Element.new('eventOutcome')
    eventOutcome.add_text(status)
    eventOutcomeInfo.add_element eventOutcome

    #event outcome detail
    unless(messages.nil?)
      eventOutcomeDetail = Element.new('eventOutcomeDetail')
      eventOutcomeDetailExt = Element.new('eventOutcomeDetailExtension')
      eventOutcomeDetail.add_element eventOutcomeDetailExt
      eventOutcomeInfo.add_element eventOutcomeDetail

      #parse the validation result, record anomaly
      messages.each do |msg|
        msgElement = Element.new(messageType)
        msgElement.text = msg
        eventOutcomeDetailExt.add msgElement
      end
    end

    eventOutcomeInfo
  end

  def createInhibitor(inhbs)
    # create inhibitors
    inhibitors = Element.new('inhibitors')

    inhbs.each do |inhibitor|
      unless (inhibitor.type.nil?)
        inhibitorType = Element.new('inhibitorType')
        inhibitorType.add_text(inhibitor.type)
        inhibitors.add_element inhibitorType
      end

      unless (inhibitor.target.nil?)
        inhibitorTarget = Element.new('inhibitorTarget')
        inhibitorTarget.add_text(inhibitor.target)
        inhibitors.add_element inhibitorTarget
      end

      unless (inhibitor.key.nil?)
        inhibitorKey = Element.new('inhibitorKey')
        inhibitorKey.add_text(inhibitor.key)
        inhibitors.add_element inhibitorKey
      end

    end
    inhibitors
  end

  def createFixity(url)
    fixity = Element.new('fixity')

    # message Digest Type
    messageDigestType = Element.new('messageDigestAlgorithm')
    messageDigestType.add_text('MD5')
    fixity.add_element messageDigestType

    # message digest value
    messageDigest = Element.new('messageDigest')
    value = Digest::MD5.hexdigest(File.read(url))
    messageDigest.add_text(value)
    fixity.add_element messageDigest

    fixity
  end

end