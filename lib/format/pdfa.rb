require 'format/pdf'
require 'tmpdir'

INPUTFILE = '$INPUT_FILE$'
LEVEL = '$LEVEL$'
REPORTFILE = '$REPORT_FILE$'

class PDFA < PDF  
  @@validator = nil
  
  def self.validator= validator
      @@validator = validator
  end
  
  def initialize(jhoveModule)
      super
  end
  
  # perform the pdf/a specific format validation and extract the format-specific metadata
  def parse(xml)
    super
    unless @@validator.nil?
      # default the conformance level for pdf/a validation to 1b
      level = "1b"
      reportpath = Dir.tmpdir + "/pdfa" + rand(1000).to_s + ".xml"
      # retrieve the pdf/a conformance level already identified for the input file.
      level = @result.fileObject.formats[0].formatVersion if @result.fileObject.formats[0]
      command = @@validator.sub(INPUTFILE, @location).sub(LEVEL, level).sub(REPORTFILE, reportpath)
      Datyl::Logger.info "command #{command}"
      # backquote the external pdf/a validator
      command_output = `#{command}`
      Datyl::Logger.info "command output #{command_output}"
      output_code = $?
      Datyl::Logger.info "output_code #{output_code}"
      Datyl::Logger.info "reportpath #{File.size(reportpath)}"
      parse_report(reportpath) if File.size?(reportpath)
      FileUtils.rm reportpath
    end
  end
  
  # parse and record the validation errors in report generated from pdf/a validation
  def parse_report(report_file)
    doc = open(report_file) { |io| XML::Document.io io }
    # retrieve the transformation conversion error from the report.
    namespace = "callas:http://www.callassoftware.com/namespace/pi4"
    hits = doc.find("//callas:hits[@severity='Error']", namespace)
    if hits.length > 0
      # retrieve the detail description of the validation errors
      hits.each do |hit|
        rule_id = hit.find_first("@rule_id", namespace).value
        error = doc.find_first("//callas:rule[@id='#{rule_id}']/callas:display_name", namespace).content 
        # record the pdf/a validation errors as anomalies
        @result.anomaly.add('pdfaPilot:' + error)
      end
      # set the status as invalid
      super.setInvalid
    end
    doc = nil
  end
end
