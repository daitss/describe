require 'formatBase'
require 'DescribeLogger.rb'

class PDF < FormatBase
  def parse(xml)
    super
    # retrieve and dump the PDF metadata
    pdfMD = @jhove.find_first('//jhove:property[jhove:name/text()="PDFMetadata"]', JHOVE_NS)

    # puts pdfMD
    unless (pdfMD.nil?)
      # retrieve CreateAppName
      unless (pdfMD.find_first('//jhove:property[jhove:name/text()="Creator"]', JHOVE_NS).nil?)
        @fileObject.createAppName = pdfMD.find_first('//jhove:property[jhove:name/text()="Creator"]/jhove:values/jhove:value', JHOVE_NS).content
      end

      # retrieve CreateDate
      unless (pdfMD.find_first('//jhove:property[jhove:name/text()="CreationDate"]', JHOVE_NS).nil?)
        @fileObject.createDate =  pdfMD.find_first('//jhove:property[jhove:name/text()="CreationDate"]/jhove:values/jhove:value', JHOVE_NS).content
      end

      # check if the pdf is encrypted
      encrypt = pdfMD.find_first('//jhove:property[jhove:name/text()="Encryption"]', JHOVE_NS)
      unless (encrypt.nil?)
        inhibitor = Inhibitor.new 
        handler = encrypt.find_first('//jhove:property[jhove:name/text()="SecurityHandler"]/jhove:values/jhove:value', JHOVE_NS)
        # based on PDF spec., "Standard" implies passwork-protected
        if (handler.content == "Standard") 
          inhibitor.type = "Password protection"
          inhbtrs = encrypt.find_first('//jhove:property[jhove:name/text()="StandardSecurityHandler"]/jhove:values/jhove:property[jhove:name/text()="UserAccess"]/jhove:values',
            JHOVE_NS)
            inhbtrs.each do |ele| 
              inhibitor.target = 'UserAccess: ' + ele.content
          end
          @fileObject.inhibitors << inhibitor
        end
      end

      # convert to doc schema        
      DescribeLogger.instance.info "transforming JHOVE output to DocMD"
      xslt = XML::XSLT.new()
      xslt.xml = pdfMD.to_s
      xslt.xsl = REXML::Document.new File.read("xsl/pdf2DocMD.xsl")
      docMDString = xslt.serve()

      # convert the xml string into xml element
      tmpDoc = XML::Document.string(docMDString)
      @fileObject.objectExtension = tmpDoc.root

      # retrieve all image bitstreams
      nodes = @jhove.find("//jhove:property[jhove:name/text()='NisoImageMetadata']/jhove:values/jhove:value", JHOVE_NS)
      nodes.each do |node|
        mix = node.find_first("//mix:mix", "mix:http://www.loc.gov/mix/v20")
        bitstream = BitstreamObject.new
        bitstream.objectExtension = mix
        @bitstreams << bitstream
      end
    else 
      DescribeLogger.instance.warn "No PDFMetadata found"
    end  

  end
end