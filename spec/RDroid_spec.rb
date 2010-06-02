require 'rubygems'
require "bundler"
Bundler.setup
require 'RDroid'
require 'rjb'

describe RDroid do
  before do
    #load all required JAVA library.
    Rjb::load('jars/jhove.jar:jars/jhove-module.jar:jars/jhove-handler.jar:jars/shades.jar:jars/droid.jar')
    @droid = RDroid.instance
  end

  it "return an error exception if nil" do
    lambda {@droid.identify(nil)}.should raise_error
  end

  it "return an xml output if existing PDF" do
    input = "files/choi_s.pdf"
    xml = nil
    lambda {xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda {xml.nil?}.call.should be_false
  end

  it "return an xml output for existing XML" do
    input = "files/UF00003061.xml"
    xml = nil
    lambda { xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return a xml containing metadata for existing ASCII" do
    input = "files/rawfree.datafile"
    xml = nil
    lambda {xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing TIFF" do
    input = "files/florida.tif"
    xml = nil
    lambda {xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing JPEG" do
    input = "files/DSC04975_small.jpg"
    xml = nil
    lambda {xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing JPEG2k" do
    input = "files/00021.jp2"
    xml = nil
    lambda {xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing AIFF" do
    input = "files/wood12.aiff"
    xml = nil
    lambda {xml = @droid.identify(input) }.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing WAVE" do
    input = "files/GLASS.WAV"
    xml = nil
    lambda {xml = @droid.identify(input)}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

end
