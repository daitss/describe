require 'log4r'
require 'config'

class DescribeLogger
  attr_reader :LOGGERNAME
  include Singleton

  def initialize()
    logfile = config_option "log-file"    
    @LOGGERNAME = 'DescribeService'
    logger = Log4r::Logger.new(@LOGGERNAME)
    
    #add a formatter to log output
    formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d %c: %m")
      
    #add logfile if log-file config option is specified, otherwise use stdout outputer
    if logfile
      fileoutput = Log4r::FileOutputter.new('fileoutput', :filename => logfile, :trunc =>false)
      fileoutput.formatter = formatter
      logger.add(fileoutput)
    else
      stdoutput = Log4r::StdoutOutputter.new('stdout')
      stdoutput.formatter = formatter
      logger.add(stdoutput)      
    end

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