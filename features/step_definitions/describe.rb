require 'xml'
path = 'http://www.fcla.edu/daitss-test/files/'

# TODO make sure all test cases include formatDesignation (formatName) test
Given /^an empty file$/ do
  @file = "#{path}/empty"
end

Given /^an aiff file$/ do
  @file = "#{path}/wood12.aiff"
end

Given /^an aifc file$/ do
  @file = "#{path}/alaw.aifc"
end

Given /^a jp2$/ do
  @file = "#{path}/00021.jp2"
end

Given /^a jpeg file$/ do
  @file = "#{path}/DSC04975_small.jpg"
end

Given /^a jpeg file from ufdc$/ do
  @file = "#{path}/00200.QC.jpg"
end

Given /^a PDF 1\.3 file$/ do
  @file = "#{path}/etd.pdf"
end

Given /^a PDF 1\.4 file$/ do
  @file = "#{path}/choi_s.pdf"
end

Given /^a PDF 1\.5 file$/ do
  @file = "#{path}/00001.pdf"
end

Given /^a PDF 1\.6 file$/ do
  @file = "#{path}/Webb_Christina_M_200508_MA.pdf"
end

Given /^a PDF 1\.7 file$/ do
  @file = "#{path}/hunsaker_t.pdf"
end

Given /^a PDF\/A conformed file$/ do
  @file = "#{path}/TestingPDFA.pdf"
end

Given /^a PDF with embedded language metadata$/ do
  @file = "#{path}/useLang.pdf"
end

Given /^a PDF embedded with multiple images$/ do
  @file = "#{path}/etd.pdf"
end

Given /^pdf with application metadata$/ do
  @file = "#{path}/etd.pdf"
end

Given /^a PDF with bad trailing dictionary$/ do
  @file = "#{path}/03-2013.pdf"
end

Given /^a PDF with bad PDFA conformance stream$/ do
  @file = "#{path}/fsu_168965.pdf"
end

Given /^an password\-protected PDF file$/ do
  @file = "#{path}/pwprotected.pdf"
end

Given /^a tagged PDF file$/ do
  @file = "#{path}/tagged.pdf"
end

Given /^a PDF with annotations$/ do
  @file = "#{path}/outalbert_j.pdf"
end

Given /^a PDF with CreatingApplication but not CreateDate$/ do
  @file = "#{path}/00020.pdf"
end

Given /^a PDF with bad Encoding property in its font dictionary/ do
  @file = "#{path}/JAPR_April_2010.pdf"
end

Given /^a non\-wellformed PDF$/ do
  @file = "#{path}/IATUL_FSU_2010_06_17.pdf"
end

Given /^tiff with application metadata$/ do
  @file = "#{path}/00008.tif"
end

Given /^a TIFF 4\.0 file$/ do
  @file = "#{path}/florida.tif"
end

Given /^a TIFF 5\.0 file$/ do
  @file = "#{path}/00170.tif"
end

Given /^a TIFF 6\.0 file$/ do
  @file = "#{path}/00008.tif"
end

Given /^a TIFF file with flash, meteringMode and exposureBiasValue metadata$/ do
   @file = "#{path}/18.tif"
end

Given /^a GeoTiff file$/ do
  @file = "#{path}/tjpeg.tif"
end

# note: this ASCII is not well-formed, find one that is well-formed and valid and thus whose textMD can be retrieved
Given /^an ascii file$/ do
  @file = "#{path}/00004.txt"
end

Given /^an utf\-8 file$/ do
  @file = "#{path}/Doc1.txt"
end

Given /^a bad text file with disallowed character$/ do
  @file = "#{path}/00356.txt"
end

Given /^a file with unknown format$/ do
  @file = "#{path}/rawfree.datafile"
end

Given /^a file whose format is power point$/ do
  @file = "#{path}/test.ppt"
end

Given /^a file whose format is mpg$/ do
  @file = "#{path}/test-mpeg.mpg"
end

Given /^a file whose format is mdb$/ do
  @file = "#{path}/surveydata.mdb"
end

Given /^a double-quoted xml file$/ do
  @file = "#{path}/UF00003061.xml"
end

Given /^a single-quoted xml file$/ do
  @file = "#{path}/ateam.xml"
end

Given /^a html file$/ do
  @file = "#{path}/ccsurvey.html"
end

Given /^a wave file$/ do
  @file = "#{path}/obj1.wav"
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
  last_response.body.to_s =~ /Features>(.*?)<\/Features>/
  $1.should == feature
end

Then /^I should receive (.+?) on the format$/ do |format|
  doc = XML::Document.string(last_response.body)
  # make sure the intended profile exist in the file format
  list = doc.find("//premis:object[@xsi:type='file']/premis:objectCharacteristics/premis:format", 'premis' => 'http://www.loc.gov/premis/v3')
  
  found = false
  list.each do |node|
    if node.content.include? format
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
  list = doc.find("//premis:object[@xsi:type='bitstream']", 'premis' => 'http://www.loc.gov/premis/v3', 'xsi' => 'http://www.w3.org/2001/XMLSchema-instance')
  list.size.should == num.to_i
end

Then /^I should receive eventDetail equal to 'Not well-formed'$/ do
  last_response.body.to_s =~ /eventDetail>(.*?)<\/eventDetail>/
  $1.should == 'Not well-formed'
end

Then /^I should receive eventDetail equal to 'Well-Formed, but not valid'$/ do
  last_response.body.to_s =~ /eventDetail>(.*?)<\/eventDetail>/
  $1.should == 'Well-Formed, but not valid'
end

Then /^I should receive eventDetail equal to 'Well-Formed and valid'$/ do
  last_response.body.to_s =~ /eventDetail>(.*?)<\/eventDetail>/
  $1.should == 'Well-Formed and valid'
end
