require 'log4r'

class DescribeLogger
  attr_reader :LOGGERNAME
  include Singleton

  def initialize()
    @LOGGERNAME = 'DescribeService'
    logger = Log4r::Logger.new(@LOGGERNAME)
    
    #add the file and stdout outputer
    fileoutput = Log4r::FileOutputter.new('fileoutput', :filename => @LOGGERNAME+'.log', :trunc =>false)
    logger.add(fileoutput)
    stdoutput = Log4r::StdoutOutputter.new('stdout')
    logger.add(stdoutput)
    
    #add a formatter to file output
    formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d %c: %m")
    fileoutput.formatter = formatter
  end
  
  def error message
    Log4r::Logger[@LOGGERNAME].error message
  end
  
  def warn message
    Log4r::Logger[@LOGGERNAME].warn message
  end
  
  def info message
    Log4r::Logger[@LOGGERNAME].info message
  end
  
  def debug object 
    #dump out the parameters in the object
    if Log4r::Logger[LOGGERNAME].debug?
      log.debug(object.collect{|p| p.to_s})
    end 
  end
  
end