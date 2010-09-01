require 'format/formatbase'
require 'erb'
class PDF < FormatBase

  def parse(xml)
    super
    # retrieve and dump the PDF metadata
    pdfMD = @jhove.find_first('//jhove:property[jhove:name/text()="PDFMetadata"]', NAMESPACES)
    unless (pdfMD.nil?)
      # check if the pdf is encrypted
      encrypt = pdfMD.find_first('//jhove:property[jhove:name/text()="Encryption"]', NAMESPACES)
      unless (encrypt.nil?)
        @fileObject.inhibitors = Array.new
        inhibitor = Inhibitor.new 
        handler = encrypt.find_first('//jhove:property[jhove:name/text()="SecurityHandler"]/jhove:values/jhove:value', NAMESPACES)
        # based on PDF spec., "Standard" implies passwork-protected
        if (handler.content == "Standard") 
          inhibitor.type = "Password protection"
          inhbtrs = encrypt.find_first('//jhove:property[jhove:name/text()="StandardSecurityHandler"]/jhove:values/jhove:property[jhove:name/text()="UserAccess"]/jhove:values',
          NAMESPACES)
          inhbtrs.each do |ele| 
            inhibitor.target = 'UserAccess: ' + ele.content
          end
          @fileObject.inhibitors << inhibitor
        end
      else
        # only retrieve CreateAppName when not encrypted, JHOVE dump out bad creator info for encrypted file
        unless (pdfMD.find_first('//jhove:property[jhove:name/text()="Producer"]', NAMESPACES).nil?)
          @fileObject.createAppName = pdfMD.find_first('//jhove:property[jhove:name/text()="Producer"]/jhove:values/jhove:value', NAMESPACES).content
        end
      end

      # retrieve CreateDate
      unless (pdfMD.find_first('//jhove:property[jhove:name/text()="CreationDate"]', NAMESPACES).nil?)
        @fileObject.createDate =  pdfMD.find_first('//jhove:property[jhove:name/text()="CreationDate"]/jhove:values/jhove:value', NAMESPACES).content
      end

      # convert to doc schema        
  	  DescribeLogger.instance.info "transforming JHOVE output to DocMD"
      nodes = pdfMD.find("//jhove:property[jhove:name='Page']", NAMESPACES)
      @pageCount = nodes.size
	
	  if pdfMD.find_first("//jhove:property[jhove:name='Language']", NAMESPACES)
	 	@language =  pdfMD.find_first("//jhove:property[jhove:name='Language']/jhove:values/jhove:value", NAMESPACES).content
	  end
	
	  @fonts = Hash.new
	  nodes = pdfMD.find("//jhove:property[jhove:name='Fonts']/jhove:values/jhove:property/jhove:values/jhove:property[jhove:name='Font']/jhove:values/jhove:property[jhove:name='FontDescriptor']", NAMESPACES)	
	  nodes.each do |font|
		fontname = font.find_first("jhove:values/jhove:property[jhove:name='FontName']/jhove:values/jhove:value", NAMESPACES).content
		# remove font substitution string (every character before +)
		subfont = fontname.split("+")
		fontname = subfont.last
 	    hasfontfile = font.find_first("jhove:values/jhove:property[starts-with(jhove:name, 'FontFile')]/jhove:values/jhove:value", NAMESPACES)
		isEmbedded = 'false'
 	    isEmbedded = 'true' if hasfontfile && hasfontfile.content.eql?('true')
		@fonts[fontname] = isEmbedded
	  end

      @features = Array.new
      @features << "isTagged" if pdfMD.find_first("//jhove:profiles[jhove:profile='Tagged PDF']", NAMESPACES)
      @features << "hasOutline" if pdfMD.find_first("//jhove:property[jhove:name='Outlines']", NAMESPACES)
      thumbnail = pdfMD.find_first("//jhove:property[jhove:name='Thumb']/jhove:values/jhove:value", NAMESPACES)
  	  @features << "hasThumbnails" if thumbnail && thumbnail.content.eql?('true')   
      @features << "hasAnnotations" if pdfMD.find_first("//jhove:property[jhove:name='Annotation']", NAMESPACES)

	  docmd = File.read("views/docmd.erb").to_s
      docmdTemplate = ERB.new(docmd)
	  @fileObject.objectExtension = docmdTemplate.result(binding)
      # @fileObject.objectExtension = apply_xsl("pdf2DocMD.xsl").root

      # retrieve all image bitstreams inside the pdf
      nodes = @jhove.find("//jhove:property[jhove:name/text()='NisoImageMetadata']/jhove:values/jhove:value", NAMESPACES)
      sequence = 1
      nodes.each do |node|
        mix = node.find_first("mix:mix", NAMESPACES)
        bitstream = BitstreamObject.new
        bitstream.uri = @fileObject.uri + "/" + sequence.to_s
        compression = mix.find_first('mix:BasicDigitalObjectInformation/mix:Compression/mix:compressionScheme', NAMESPACES)
        if (compression)
          bitstream.formatName = compression.content
        else 
          bitstream.formatName = 'unknown'
        end
        bitstream.objectExtension = mix
        @bitstreams << bitstream
        sequence += 1
      end
    else 
      DescribeLogger.instance.warn "No PDFMetadata found"
    end  

  end
end
