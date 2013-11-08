require './lib/format/formatbase'
require 'erb'
require 'datyl/logger'
require 'datyl/config'

class PDF < FormatBase
  @@max_pdf_bitstreams = nil
  
  def self.max_pdf_bitstreams= num
      @@max_pdf_bitstreams = num
  end
   
  
  def initialize(jhoveModule)
      super
  end
  
  def parse(xml)
    super
    # retrieve and dump the PDF metadata
    pdfMD = @jhove.find_first('//jhove:property[jhove:name/text()="PDFMetadata"]', NAMESPACES)
    unless (pdfMD.nil?)
      # check if the pdf is encrypted
      encrypt = pdfMD.find_first('//jhove:property[jhove:name/text()="Encryption"]', NAMESPACES)
      unless (encrypt.nil?)
        inhibitor = Inhibitor.new
        handler = encrypt.find_first('//jhove:property[jhove:name/text()="SecurityHandler"]/jhove:values/jhove:value', NAMESPACES)
        # based on PDF spec., "Standard" implies passwork-protected
        if (handler.content == "Standard")
          inhibitor.type = "Password protection"
          inhbtrs = encrypt.find_first('//jhove:property[jhove:name/text()="StandardSecurityHandler"]/jhove:values/jhove:property[jhove:name/text()="UserAccess"]/jhove:values',
          NAMESPACES)
          unless (inhbtrs.nil?)
            nodes = inhbtrs.find('jhove:value',NAMESPACES)
            arr = Array.new
            nodes.each {|node| arr << node.content}
            inhibitor.target = "UserAccess: " + arr.join(', ')
            arr = nil
          end
          @result.fileObject.inhibitors << inhibitor
        end

      else
        # only retrieve CreateAppName when not encrypted, JHOVE dump out bad creator info for encrypted file
        unless (pdfMD.find_first('//jhove:property[jhove:name/text()="Producer"]', NAMESPACES).nil?)
          @result.fileObject.createAppName = pdfMD.find_first('//jhove:property[jhove:name/text()="Producer"]/jhove:values/jhove:value', NAMESPACES).content
        end
      end

      # retrieve CreateDate
      unless (pdfMD.find_first('//jhove:property[jhove:name/text()="CreationDate"]', NAMESPACES).nil?)
        createDate =  pdfMD.find_first('//jhove:property[jhove:name/text()="CreationDate"]/jhove:values/jhove:value', NAMESPACES).content
        @result.fileObject.createDate =  Time.parse(createDate).xmlschema
      end

      # convert to doc schema

      Datyl::Logger.info "transforming JHOVE output to DocMD"
      nodes = pdfMD.find("//jhove:property[jhove:name='Page']", NAMESPACES)
      @pageCount = nodes.size

      if pdfMD.find_first("//jhove:property[jhove:name='Language']", NAMESPACES)
        @language =  pdfMD.find_first("//jhove:property[jhove:name='Language']/jhove:values/jhove:value", NAMESPACES).content
      end

      #retrieve fonts used in the pdf, note if it's embedded.
      @fonts = Hash.new
      nodes = pdfMD.find("//jhove:property[jhove:name='Fonts']/jhove:values/jhove:property/jhove:values/jhove:property[jhove:name='Font']/jhove:values/jhove:property[jhove:name='FontDescriptor']", NAMESPACES)
      nodes.each do |font|
        font_name = font.find_first("jhove:values/jhove:property[jhove:name='FontName']/jhove:values/jhove:value", NAMESPACES)
        unless font_name.nil?
          fontname = font_name.content
          # remove font substitution string (every character before +)
          subfont = fontname.split("+")
          fontname = subfont.last
          hasfontfile = font.find_first("jhove:values/jhove:property[starts-with(jhove:name, 'FontFile')]/jhove:values/jhove:value", NAMESPACES)
          isEmbedded = 'false'
          isEmbedded = 'true' if hasfontfile && hasfontfile.content.eql?('true')
          @fonts[fontname] = isEmbedded
        end
      end
      #retrieve all the features in the pdf.
      @features = Array.new
      @features << "isTagged" if pdfMD.find_first("//jhove:profiles[jhove:profile='Tagged PDF']", NAMESPACES)
      @features << "hasOutline" if pdfMD.find_first("//jhove:property[jhove:name='Outlines']", NAMESPACES)
      thumbnail = pdfMD.find_first("//jhove:property[jhove:name='Thumb']/jhove:values/jhove:value", NAMESPACES)
      @features << "hasThumbnails" if thumbnail && thumbnail.content.eql?('true')
      @features << "hasAnnotations" if pdfMD.find_first("//jhove:property[jhove:name='Annotation']", NAMESPACES)

      docmd = File.read("views/docmd.erb").to_s
      docmdTemplate = ERB.new(docmd)
      @result.fileObject.objectExtension = docmdTemplate.result(binding)

      # retrieve all image bitstreams inside the pdf
      nodes = @jhove.find("//jhove:property[jhove:name/text()='NisoImageMetadata']/jhove:values/jhove:value", NAMESPACES)
      sequence = 1

      nodes.each do |node|
        mix = node.find_first("mix:mix", NAMESPACES)
        bitstream = BitstreamObject.new
        bitstream.uri = @result.fileObject.uri + "/" + sequence.to_s
        compression = mix.find_first('mix:BasicDigitalObjectInformation/mix:Compression/mix:compressionScheme', NAMESPACES)
        if (compression)
          bitstream.formatName = compression.content
        else
          bitstream.formatName = 'unknown'
        end
        bitstream.objectExtension = mix

        @result.bitstreams << bitstream
        sequence += 1
   
        # stop retrieving image bitstream when exceeding number of bitstream we want to retrieve in pdf.
        if (@@max_pdf_bitstreams and sequence > @@max_pdf_bitstreams)
          @result.anomaly.add "excessive number of image bitstreams in the PDF"
          break
        end
      end
      # clean up arrays
      @fonts.clear
      @features.clear
      @fonts = nil
      @features = nil
    else
      Datyl::Logger.warn "No PDFMetadata found"
    end
    
  end
end
