# DAITSS Copyright (C) 2009 University of Florida
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# app.rb

require 'rubygems'
require "bundler/setup"
require 'sinatra'
require 'uri'
require 'erb'
require 'pp'
require 'net/http'
require 'yaml'
require 'semver'
require_relative 'lib/structures'
require_relative 'lib/jar'
require_relative 'lib/format/pdf'
require_relative 'lib/format/pdfa'
require_relative 'lib/formatpool'
require 'datyl/logger'
require 'datyl/config'

include Datyl

MAX_RANDOM_NUM = 10000
DESCRIBE_VERSION = SemVer.find(File.dirname(__FILE__)).format "v%M.%m.%p%s"

def get_config
  raise "No DAITSS_CONFIG environment variable has been set, so there's no configuration file to read"             unless ENV['DAITSS_CONFIG']
  raise "The DAITSS_CONFIG environment variable points to a non-existant file, (#{ENV['DAITSS_CONFIG']})"          unless File.exists? ENV['DAITSS_CONFIG']
  raise "The DAITSS_CONFIG environment variable points to a directory instead of a file (#{ENV['DAITSS_CONFIG']})"     if File.directory? ENV['DAITSS_CONFIG']
  raise "The DAITSS_CONFIG environment variable points to an unreadable file (#{ENV['DAITSS_CONFIG']})"            unless File.readable? ENV['DAITSS_CONFIG']

  config = Datyl::Config.new(ENV['DAITSS_CONFIG'], :defaults, ENV['VIRTUAL_HOSTNAME'])
end

configure do |s|
  config = get_config

  disable :logging        # Stop CommonLogger from logging to STDERR; we'll set it up ourselves.

  disable :dump_errors    # Normally set to true in 'classic' style apps (of which this is one) regardless of :environment; it adds a backtrace to STDERR on all raised errors (even those we properly handle). Not so good.

  set :environment,  :production  # Get some exceptional defaults.

  set :raise_errors, false        # Handle our own exceptions.
 
  PDF.max_pdf_bitstreams = config.max_pdf_bitstreams
  PDFA.validator = config.pdfa_validator 
  Datyl::Logger.setup('Describe', ENV['VIRTUAL_HOSTNAME'])

  if not (config.log_syslog_facility or config.log_filename)
    Datyl::Logger.stderr # log to STDERR
  end

  Datyl::Logger.facility = config.log_syslog_facility if config.log_syslog_facility
  Datyl::Logger.filename = config.log_filename if config.log_filename

  Datyl::Logger.info "Starting up describe service"
  Datyl::Logger.info "Using temp directory #{ENV['TMPDIR']}"

  use Rack::CommonLogger, Datyl::Logger.new(:info, 'Rack:')

  config.jvm_options.each do |o| 
    ENV["_JAVA_OPTIONS"] = o if o =~ /-Xmx/
  end

  # jvm options, for this to work it must be ran before any other rjb code
  if config.jvm_options
    Rjb.load '.', config.jvm_options
  end

  Jar.load_jars
end #of configure

error do
  e = @env['sinatra.error']

  request.body.rewind if request.body.respond_to?('rewind') # work around for verbose passenger warning

  Datyl::Logger.err "Caught exception #{e.class}: '#{e.message}'; backtrace follows", @env
  e.backtrace.each { |line| Datyl::Logger.err line, @env }

  halt 500, { 'Content-Type' => 'text/plain' }, e.message + "\n"
end 

not_found do
  request.body.rewind if request.body.respond_to?(:rewind)

  content_type 'text/plain'  

  "Not Found\n"
end

get '/describe' do
  throw :halt, [400, "require a location parameter."] if params['location'].nil?
 
  url = URI.parse(params['location'].to_s)
  # set originalName, "originalName" param is optional
  
  unless params['originalName'].nil?
    originalName = params['originalName']
  else
    originalName = url.path
  end
  
  tmpfile = nil 
  case url.scheme
  when "file"
    input = File.join(Dir.tmpdir, rand(MAX_RANDOM_NUM).to_s + '_' + File.basename(originalName))
    FileUtils::ln_s(url.path, input)
    # uri parameter is optional, set the file url if uri param is not specified
    uri = input
    uri = params['uri'] unless params['uri'].nil?
  when "http"
    resource = Net::HTTP.get_response url
    index = url.path.rindex('.')
    file_ext = ""
    file_ext = url.path.slice(index, url.path.length) if index 
    tmpfile = Tempfile.new(['file2describe', file_ext])
    tmpfile.write resource.body
    tmpfile.flush
    input = tmpfile.path
    resource = nil # ruby memory leak if not nullify the resource from Net::HTTP.get_response
    # uri parameter is optional, set to the specified url if uri param is not specified
    uri = url
    uri = params['uri'] unless params['uri'].nil?
  else
    throw :halt, [400,  "invalid url location type"]
  end

  throw :halt, [400,  "invalid url"] if (input.nil?)
 
  # make sure the file exist and it's a valid file
  throw :halt, [404, "either #{input} does not exist or it is not a valid file"] unless File.symlink?(input) || File.file?(input)
  begin
    pool = FormatPool.instance
    @result = pool.describe(input, uri, originalName)
    headers 'Content-Type' => 'application/xml'
    # dump the xml output to the response, pretty the xml output (ruby bug)
    body erb(:premis)
    @result.clear
  rescue => e
    Datyl::Logger.err "running into exception #{e} while processing #{originalName}"
    Datyl::Logger.err e.backtrace.join("\n")
    throw :halt, [500, "running into exception #{e} while processing #{originalName}\n#{e.backtrace.join('\n')}"]
  ensure
    FileUtils.rm(input) if File.exist?(input)
    tmpfile.close unless tmpfile.nil?
    @result = nil
  end
  response.finish
end

# POST a file to the description service 
# ex:  curl -F file=@GLASS.WAV http://localhost:7002/describe
post '/describe' do
  halt 400, "missing parameter file='@filename'" unless params['file']
  halt 400, "missing [file][:tempfile] parameter file='@filename'" unless tempfile = params['file'][:tempfile]
 
  # set originalName, "originalName" param is optional
  unless params['originalName'].nil?
    originalName = params['originalName']
  else
    originalName = params['file'][:filename]
  end
  
  input = File.join(Dir.tmpdir, rand(MAX_RANDOM_NUM).to_s + '_' + File.basename(originalName))
  FileUtils.mv(tempfile.path, input)
  
  # uri parameter is optional, set the file url if uri param is not specified  
  unless params['uri'].nil?
    uri = params['uri'] 
  else
    uri = input
  end

  throw :halt, [400,  "invalid url"] if (input.nil?)
 
  # make sure the file exist and it's a valid file
  throw :halt, [404, "either #{input} does not exist or it is not a valid file"] unless File.file?(input)
  begin
    pool = FormatPool.instance
    @result = pool.describe(input, uri, originalName)
    headers 'Content-Type' => 'application/xml'
    # dump the xml output to the response, pretty the xml output (ruby bug)
    body erb(:premis)
    @result.clear
    # take care of ruby rack file handle leak
    env['rack.request.form_input'].close
  rescue => e
    Datyl::Logger.err "running into exception #{e} while processing #{originalName}"
    Datyl::Logger.err e.backtrace.join("\n")
    throw :halt, [500, "running into exception #{e} while processing #{originalName}\n#{e.backtrace.join('\n')}"]
  ensure
    FileUtils.rm_rf(input) if File.exist?(input)  
    # close and remove the temporary file created by sinatra-curl
    if (tempfile)
      tempfile.close 
      tempfile.unlink
    end

  end
  status = 200
end

#TODO change PIM to use post /describe method
# note: use /description to keep in sync with oss thin setup
post '/description' do
  halt 400, "Query parameter document is required" unless params['document']
  halt 400, "Query parameter extension is required.  Is java script enabled?" unless params['extension']

  extension = params["extension"].to_s
  io = Tempfile.open("object")
  
  input = io.path + '.' + extension;
  io.close!
  uri = input

  tempfile = params['document'][:tempfile]
  # pp request.env
  case params['document']
    when Hash
      File.symlink(tempfile.path, input)
      originalName = params['document'][:filename]
    when String
      tmp = File.new(input, "w+")
      tmp.write params['document']
      tmp.close
      tmp = nil
      originalName = input      
    end
  
  # describe the transmitted file with format identifier and metadata
  begin
    pool = FormatPool.instance
    @result = pool.describe(input, uri, originalName)
    headers 'Content-Type' => 'application/xml'
    # dump the xml output to the response, pretty the xml output (ruby bug)
    body erb(:premis)
    @result.clear
    @result = nil
    FileUtils.rm_rf(input) if File.exist?(input) 
    # take care of ruby rack file handle leak
    env['rack.request.form_input'].close
  rescue => e
    Datyl::Logger.err "running into exception #{e} while processing #{originalName}"
    Datyl::Logger.err e.backtrace.join("\n")
    throw :halt, [500, "running into exception #{e} while processing #{originalName}\n#{e.backtrace.join('\n')}"]
  ensure
    FileUtils.rm_rf(input) if File.exist?(input) 
    # close and remove the temporary file created by sinatra-curl
    if (tempfile)
      tempfile.close 
      tempfile.unlink
    end 
  end
  status = 200
end

get '/' do
  # render haml index template
  config = get_config
  max_upload_file_size = config.max_upload_file_size   
  haml :index, :locals => {:max_upload_file_size => "#{max_upload_file_size}"}
end

get '/information' do
  haml :'information/index'
end

get '/status' do
  [ 200, {'Content-Type'  => 'application/xml'}, "<status/>\n" ]
end

