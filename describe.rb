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

# describe.rb
require 'rubygems'
require "bundler/setup"

require 'sinatra'
require 'RJhove'
require 'RDroid'
require 'DescribeLogger'
require 'uri'
require 'rjb'
require 'structures'
require 'erb'
require 'digest/md5'
require 'digest/sha1'
require 'ftools'
require 'pp'
require 'net/http'
require 'jar'
require 'yaml'

# load in description service configuration parameter

CONFIG = YAML.load_file config_file('describe.yml')
CONFIG ||= {}

# jvm options, for this to work it must be ran before any other rjb code
if CONFIG["jvm-options"]
  Rjb.load '.', CONFIG["jvm-options"]
  #Rjb.load('.',  ['-Xms32m', '-Xmx32m'])
end

Jar.load_jars

# use cvk's memory_debug 
require 'memory_debug'
get '/debug' do
  GC.start
  delta_stats
end

error do
  'Encounter Error ' + env['sinatra.error'].name
end

get '/describe' do
  if params['location'].nil?
    throw :halt, [400, "require a location parameter."]
  end
  io = nil

  url = URI.parse(params['location'].to_s)
  # set originalName, "originalName" param is optional
  unless params['originalName'].nil?
    @originalName = params['originalName']
  else
    @originalName = url.path
  end
  
  case url.scheme
  when "file"
    
    urlpath = url.path
    link = File.join(Dir.tmpdir, File.basename(@originalName))
    FileUtils::ln_s(url.path, link)
    @input = link
  when "http"
    resource = Net::HTTP.get_response url
    index = url.path.rindex('.')
    file_ext = url.path.slice(index, url.path.length) if index
    io = Tempfile.new(['file2describe', file_ext])
    io.write resource.body
    io.flush
    @input = io.path
    io.close
  else
    throw :halt, [400,  "invalid url location type"]
  end

  if (@input.nil?)
    throw :halt, [400,  "invalid url location"]
  end


  # uri parameter is optional, set the file url is uri param is not specified
  unless params['uri'].nil?
    @uri = params['uri']
  else
    @uri = @input
  end

  # make sure the file exist and it's a valid file
  if (File.symlink?(@input) || File.file?(@input)) then
    description
    if io
      io.unlink
    else
      FileUtils.rm link
    end
  else
    throw :halt, [404, "either #{@input} does not exist or it is not a valid file"]
  end

  response.finish
end

get '/' do
  # render erb index template
  # puts options.inspect
  erb :index
end

# note: use /description to keep in sync with oss thin setup
post '/description' do
  halt 400, "query parameter document is required" unless params['document']
  halt 400, "Query parameter extension is required.  Is java script enabled?" unless params['extension']

  extension = params["extension"].to_s
  io = Tempfile.open("object")
  @input = io.path + '.' + extension;
  io.close!

  pp request.env

  case params['document']
  when Hash
    File.link(params['document'][:tempfile].path, @input)
  when String
    tmp = File.new(@input, "w+")
    tmp.write params['document']
    tmp.close
  end

  pp params['document'][:filename]

  @originalName = params['document'][:filename]
  # describe the transmitted file with format identifier and metadata
  description
  File.delete(@input)
  response.finish
end

def description

  #require 'ruby-prof'
  #RubyProf.measure_mode = RubyProf::MEMORY
  #RubyProf.start
  jhove = RJhove.instance
  droid = RDroid.instance

  # identify the file format
  @formats = droid.identify(@input)

  begin
    if (@formats.empty?)
      @result = jhove.retrieveFileProperties(@input, @formats, @uri)
    else
      # extract the technical metadata
      @result = jhove.extractAll(@input, @formats,  @uri)
    end
  jhove = nil
	@result.fileObject.trimFormatList
	@result.fileObject.resolveFormats
  rescue => e
    DescribeLogger.instance.error "running into exception #{e}"
    DescribeLogger.instance.error e.backtrace.join("\n")
	throw :halt, [500, "running into exception #{e}"]
  end
  
  @formats.clear
  unless (@result.nil?)
    # build a response
    headers 'Content-Type' => 'application/xml'

    @result.fileObject.originalName = @originalName

    # dump the xml output to the response, pretty the xml output (ruby bug)
    body erb(:premis)

    @result.clear
    @result = nil

  else
    throw :halt, [500, "unexpected empty response"]
  end


  #profresult = RubyProf.stop
  #printer = RubyProf::FlatPrinter.new(profresult)
  #printer.print(STDOUT, 0)
end
