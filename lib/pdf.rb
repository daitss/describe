require 'formatBase'
require 'DescribeLogger.rb'

class PDF < FormatBase
  def parse(xml)
    super
    # retrieve and dump the PDF metadata
    pdfMD = @jhove.elements['//property[name/text()="PDFMetadata"]']

    # puts pdfMD
    unless (pdfMD.nil?)
      # retrieve CreateAppName
      unless (pdfMD.elements['//property[name/text()="Creator"]'].nil?)
        @fileObject.createAppName = pdfMD.elements['//property[name/text()="Creator"]/values/value'].get_text.to_s
      end

      # retrieve CreateDate
      unless ( pdfMD.elements['//property[name/text()="CreationDate"]'].nil?)
        @fileObject.createDate =  pdfMD.elements['//property[name/text()="CreationDate"]/values/value'].get_text.to_s
      end

      # check if the pdf is encrypted
      encrypt = pdfMD.elements['//property[name/text()="Encryption"]']
      unless (encrypt.nil?)
        inhibitors = Element.new('Inhibitors')
        handler = encrypt.elements['//property[name/text()="SecurityHandler"]/values/value']
        # based on PDF spec., "Standard" implies passwork-protected
        if (handler.get_text == "Standard") 
          inhibitorType = Element.new("inhibitorType")
          inhibitorType.add_text "Password protection"
          inhibitors.add_element inhibitorType
          encrypt.elements['//property[name/text()="StandardSecurityHandler"]/values/property[name/text()="UserAccess"]/values'].each_element do |ele| 
            targetValue = 'UserAccess: ' + ele.get_text.to_s
            inhibitorTarget = Element.new('inhibitorTarget')
            inhibitorTarget.add_text targetValue
            inhibitors.add_element inhibitorTarget
          end
          @fileObject.inhibitors = inhibitors
        end
      end

      # convert to doc schema        
      DescribeLogger.instance.info "transforming JHOVE output to DocMD"
      xslt = XML::XSLT.new()
      xslt.xml = pdfMD.to_s
      xslt.xsl = REXML::Document.new File.read("xsl/pdf2DocMD.xsl")
      docMDString = xslt.serve()

      # convert the xml string into xml element
      tmpDoc = REXML::Document.new docMDString
      docMD = tmpDoc.root
      @fileObject.objectExtension.add_element docMD
    else 
      DescribeLogger.instance.warn "No PDFMetadata found"
    end

  end
end