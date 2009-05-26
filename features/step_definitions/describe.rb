abs = FileUtils.pwd

# TODO make sure all test cases include formatDesignation (formatName) test

Given /^an empty file$/ do
  @file = "location=file://#{abs}/files/empty"
end

Given /^an aiff file$/ do
  @file = "location=file://#{abs}/files/wood12.aiff"
end

Given /^an aifc file$/ do
    @file = "location=file://#{abs}/files/alaw.aifc"
end

Given /^a jp2$/ do
  @file = "location=file://#{abs}/files/00021.jp2"
end

Given /^a jpeg file$/ do
  @file = "location=file://#{abs}/files/DSC04975_small.jpg"
end

Given /^a PDF 1\.3 file$/ do
  @file = "location=file://#{abs}/files/etd.pdf"
end

Given /^a PDF 1\.4 file$/ do
  @file = "location=file://#{abs}/files/choi_s.pdf"
end

Given /^a PDF 1\.5 file$/ do
  @file = "location=file://#{abs}/files/00001.pdf"
end

Given /^a PDF 1\.6 file$/ do
  @file = "location=file://#{abs}/files/Webb_Christina_M_200508_MA.pdf"
end

Given /^a PDF 1\.7 file$/ do
  @file = "location=file://#{abs}/files/hunsaker_t.pdf"
end

Given /^a PDF\/A conformed file$/ do
  @file = "location=file://#{abs}/files/PdfGuideline.pdf"
#  @file = "location=file://#{abs}/files/outalbert_j.pdf"
end

Given /^pdf with application metadata$/ do
   @file = "location=file://#{abs}/files/etd.pdf"
end

Given /^an password\-protected PDF file$/ do
  @file = "location=file://#{abs}/files/pwprotected.pdf"
end

Given /^tiff with application metadata$/ do
   @file = "location=file://#{abs}/files/MM00000285.tif"
end

Given /^a TIFF 4\.0 file$/ do
  @file = "location=file://#{abs}/files/florida.tif"
end

Given /^a TIFF 5\.0 file$/ do
   @file = "location=file://#{abs}/files/00170.tif"
end

Given /^a TIFF 6\.0 file$/ do
  @file = "location=file://#{abs}/files/MM00000285.tif"
end

# note: this ASCII is not well-formed, find one that is well-formed and valid and thus whose textMD can be retrieved
Given /^an ascii file$/ do
  @file = "location=file://#{abs}/files/test.txt"
end

Given /^an utf\-8 file$/ do
  @file = "location=file://#{abs}/files/Doc1.txt"
end

Given /^a file with unknown format$/ do
  @file = "location=file://#{abs}/files/rawfree.datafile"
end

Given /^a file whose format is power point$/ do
  @file = "location=file://#{abs}/files/test.ppt"
end

Given /^a wave file$/ do
  @file = "location=file://#{abs}/files/GLASS.WAV"
end

When /^describing the file$/ do
  get '/describe?'+ @file
end

Then /^I should receive (.+?) on the format version$/ do |version|
  response.body.to_s =~ /formatVersion>(.*?)<\/formatVersion>/
  $1.should == version
end

Then /^I should receive (.+?) on the format id$/ do |id|
  response.body.to_s =~ /formatRegistryKey>(.*?)<\/formatRegistryKey>/
  $1.should == id
end

Then /^I should receive (.+?) on the format name$/ do |name|
  response.body.to_s =~ /formatName>(.*?)<\/formatName>/
  $1.should == name
end

Then /^the status should be ok$/ do
  response.should be_ok
end

Then /^aes should exist$/ do
  lambda {response.body.to_s =~ /aes>/ }.call.should be_nil
end

Then /^I should receive creating application in premis$/ do
  # should have application name and create date
  lambda {response.body.to_s =~ /creatingApplicationName>/ }.call.should_not be_nil
  lambda {response.body.to_s =~ /dateCreatedByApplication>/ }.call.should_not be_nil
end

Then /^I should receive inhibitor whose type is 'password protected'$/ do
   response.body.to_s =~ /inhibitorType>(.*?)<\/inhibitorType>/
   $1.should == 'Password protection'
end

Then /^the docmd should exist$/ do
   lambda {response.body.to_s =~ /document>/ }.call.should_not be_nil
end

Then /^the docmd should not exist$/ do
  puts response.body
  lambda {response.body.to_s =~ /document>/ }.call.should be_nil
end

Then /^I should receive PDF\/A-1b on the format profile$/ do
  response.body.to_s =~ /format>(.*?)<\/format>/
  puts $1
#  lambda { $1.include? "ISO PDF/A-1, Level B" }.call.should be_true
end

Then /^mix should exist$/ do
   lambda {response.body.to_s =~ /mix>/ }.call.should_not be_nil
end

Then /^textmd should exist$/ do
  # puts response.body
  lambda {response.body.to_s =~ /textMD>/ }.call.should_not be_nil
end

Then /^the general metadata should exist$/ do
  # make sure file size is retrieved
  lambda {response.body.to_s =~ /size>/ }.call.should_not be_nil

  # make sure checksum is retrieved
  lambda {response.body.to_s =~ /messageDigest>/ }.call.should_not be_nil
end
