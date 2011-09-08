require 'rubygems'
require "bundler"
Bundler.setup
require 'RJhove'
require 'rjb'

describe RJhove do
  before do
    #load all required JAVA library.
    Rjb::load('jars/jhove.jar:jars/jhove-module.jar:jars/jhove-handler.jar:jars/shades.jar:jars/droid.jar')
    @jhove = RJhove.instance
  end

  it "return nil if no validator is defined for the format" do
    pending "stale test"
    input = "files/choi_s.pdf"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "x-fmt/100", "")}.should_not raise_error
    # output should be nil
    lambda {xml.nil?}.call.should be_true
  end

  it "return nil if it is an undefined format" do
    pending "stale test"
    input = "files/choi_s.pdf"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "xxx", "")}.should_not raise_error
    #output should be nil
    lambda {xml.nil?}.call.should be_true
  end

  it "return an xml output if existing PDF" do
    input = "files/choi_s.pdf"
    xml = nil

   # lambda {xml = @jhove.extractAll(input, "fmt/19")}.should_not raise_error

   xml = @jhove.extractAll("files/choi_s.pdf", "fmt/19", "")
    #check the output
    lambda {xml.nil?}.call.should be_false
  end

  it "return an xml output for existing XML" do
    input = "files/UF00003061.xml"
    xml = nil
    lambda { xml = @jhove.extractAll(input, "fmt/121", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return a xml containing metadata for existing ASCII" do
    input = "files/rawfree.datafile"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "x-fmt/111", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing TIFF" do
    input = "files/florida.tif"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "fmt/9", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
    #lambda { xml.toDocument.to_s =~ /<format>/ }.call.should be_true
  end

  it "return an xml output for existing JPEG" do
    input = "files/DSC04975_small.jpg"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "fmt/42", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing JPEG2k" do
    input = "files/00021.jp2"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "x-fmt/392", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing AIFF" do
    input = "files/wood12.aiff"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "x-fmt/135", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

  it "return an xml output for existing WAVE" do
    input = "files/GLASS.WAV"
    xml = nil
    lambda {xml = @jhove.extractAll(input, "fmt/6", "")}.should_not raise_error
    #check the output
    lambda { xml.nil? }.call.should be_false
  end

end
