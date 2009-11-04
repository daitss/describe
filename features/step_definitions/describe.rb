require 'xml'
abs = FileUtils.pwd

# TODO make sure all test cases include formatDesignation (formatName) test
Given /^an empty file$/ do
  @file = "file://#{abs}/files/empty"
end

Given /^an aiff file$/ do
  @file = "file://#{abs}/files/wood12.aiff"
end

Given /^an aifc file$/ do
  @file = "file://#{abs}/files/alaw.aifc"
end

Given /^a jp2$/ do
  @file = "file://#{abs}/files/00021.jp2"
end

Given /^a jpeg file$/ do
  @file = "file://#{abs}/files/DSC04975_small.jpg"
end

Given /^a PDF 1\.3 file$/ do
  @file = "file://#{abs}/files/etd.pdf"
end

Given /^a PDF 1\.4 file$/ do
  @file = "file://#{abs}/files/choi_s.pdf"
end

Given /^a PDF 1\.5 file$/ do
  @file = "file://#{abs}/files/00001.pdf"
end

Given /^a PDF 1\.6 file$/ do
  @file = "file://#{abs}/files/Webb_Christina_M_200508_MA.pdf"
end

Given /^a PDF 1\.7 file$/ do
  @file = "file://#{abs}/files/hunsaker_t.pdf"
end

Given /^a PDF\/A conformed file$/ do
  @file = "file://#{abs}/files/TestingPDFA.pdf"
end

Given /^a PDF with embedded language metadata$/ do
 @file = "file://#{abs}/files/useLang.pdf"
end

Given /^a PDF embedded with multiple images$/ do
  @file = "file://#{abs}/files/etd.pdf"
end

Given /^pdf with application metadata$/ do
  @file = "file://#{abs}/files/etd.pdf"
end

Given /^an password\-protected PDF file$/ do
  @file = "file://#{abs}/files/pwprotected.pdf"
end

Given /^a tagged PDF file$/ do
  @file = "file://#{abs}/files/tagged.pdf"
end

Given /^a PDF with annotations$/ do
 @file = "file://#{abs}/files/outalbert_j.pdf"
end

Given /^tiff with application metadata$/ do
  @file = "file://#{abs}/files/MM00000285.tif"
end

Given /^a TIFF 4\.0 file$/ do
  @file = "file://#{abs}/files/florida.tif"
end

Given /^a TIFF 5\.0 file$/ do
  @file = "file://#{abs}/files/00170.tif"
end

Given /^a TIFF 6\.0 file$/ do
  @file = "file://#{abs}/files/MM00000285.tif"
end

Given /^a GeoTiff file$/ do
  @file = "file://#{abs}/files/tjpeg.tif"
end

# note: this ASCII is not well-formed, find one that is well-formed and valid and thus whose textMD can be retrieved
Given /^an ascii file$/ do
  @file = "file://#{abs}/files/00004.txt"
end

Given /^an utf\-8 file$/ do
  @file = "file://#{abs}/files/Doc1.txt"
end

Given /^a file with unknown format$/ do
  @file = "file://#{abs}/files/rawfree.datafile"
end

Given /^a file whose format is power point$/ do
  @file = "file://#{abs}/files/test.ppt"
end

Given /^a file whose format is mpeg$/ do
    @file = "file://#{abs}/files/jitter.mpg"
end
	
Given /^a file whose format is mdb$/ do
    @file = "file://#{abs}/files/surveydata.mdb"
end

Given /^a double-quoted xml file$/ do
  @file = "file://#{abs}/files/UF00003061.xml"
end

Given /^a single-quoted xml file$/ do
  @file = "file://#{abs}/files/ateam.xml"
end

Given /^a html file$/ do
  @file = "file://#{abs}/files/ccsurvey.html"
end

Given /^a wave file$/ do
  @file = "file://#{abs}/files/obj1.wav"
end

When /^describing the file$/ do
  get '/describe', :location => @file
end

Then /^I should receive (.+?) on the format version$/ do |version|
  last_response.body.to_s =~ /formatVersion>(.*?)<\/formatVersion>/
  $1.should == version
end

Then /^I should receive (.+?) on the format id$/ do |id|
  last_response.body =~ /formatRegistryKey>(.*?)<\/formatRegistryKey>/
  $1.should == id
end

Then /^I should receive (.+?) on the format name$/ do |name|
  last_response.body.to_s =~ /formatName>(.*?)<\/formatName>/
  $1.should == name
end

Then /^the status should be ok$/ do
  last_response.status.should == 200
end

Then /^aes should exist$/ do
  lambda {last_response.body.to_s =~ /aes>/ }.call.should be_nil
end

Then /^I should receive creating application in premis$/ do
  # should have application name and create date
  lambda {last_response.body.to_s =~ /creatingApplicationName>/ }.call.should_not be_nil
  lambda {last_response.body.to_s =~ /dateCreatedByApplication>/ }.call.should_not be_nil
end

Then /^I should receive inhibitor whose type is 'password protected'$/ do
  last_response.body.to_s =~ /inhibitorType>(.*?)<\/inhibitorType>/
  $1.should == 'Password protection'
end

Then /^the docmd should exist$/ do
  lambda {last_response.body.to_s =~ /document>/ }.call.should_not be_nil
end

Then /^the docmd should not exist$/ do
  lambda {last_response.body.to_s =~ /document>/ }.call.should be_nil
end

Then /^I should have (.+?) on the language element$/ do |lang|
  last_response.body.to_s =~ /Language>(.*?)<\/Language>/
  $1.should == lang
end

Then /^I should have (.+?) on the feature element$/ do |feature|
  last_response.body.to_s =~ /Feature>(.*?)<\/Feature>/
  $1.should == feature
end

Then /^I should receive (.+?) on the format profile$/ do |profile|
  doc = XML::Document.string(last_response.body)
  # make sure the intended profile exist in the file format
  list = doc.find("//premis:object[@xsi:type='file']/premis:objectCharacteristics/premis:format", 'premis' => 'info:lc/xmlns/premis-v2')
  
  found = false
  list.each do |node|
    puts node
    if node.content.include? profile
      found = true
    end
  end
  found.should == true
end

Then /^mix should exist$/ do
  lambda {last_response.body.to_s =~ /mix>/ }.call.should_not be_nil
end

Then /^textmd should exist$/ do
  last_response.body.should match(/textMD/)
end

Then /^the general metadata should exist$/ do
  # make sure file size is retrieved
  last_response.body.should match(/size/)

  # make sure checksum is retrieved
  last_response.body.should match(/messageDigest/)
end

Then /^I should receive (.+?) bitstreams$/ do |num|
  doc = XML::Document.string(last_response.body)
  # make sure there are expected number of bitstream objects
  list = doc.find("//premis:object[@xsi:type='bitstream']", 'premis' => 'info:lc/xmlns/premis-v2', 'xsi' => 'http://www.w3.org/2001/XMLSchema-instance')
  list.size.should == num.to_i
end
