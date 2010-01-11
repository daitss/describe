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

$:.unshift File.join(File.dirname(__FILE__), 'lib')

# describe.rb
require 'rubygems'
require 'sinatra'
require 'RJhove'
require 'RDroid'
require 'DescribeLogger'
require 'uri'
require 'rjb'
require 'structures'
require 'erb'
require 'digest/md5'
require 'ftools'
require 'pp'
require 'net/http'

#load all required JAVA libraries.
jar_pattern = File.expand_path File.join(File.dirname(__FILE__), 'jars', '*.jar')
jars = Dir[jar_pattern].join ':'
#Rjb::load jars

ENV['CLASSPATH'] = if ENV['CLASSPATH']                                                                                                                        
                     [jars, ENV['CLASSPATH']].join ':'
                   else
                     jars
                   end


class Describe < Sinatra::Default
  enable :logging

  set :root, File.dirname(__FILE__)

  error do
    'Encounter Error ' + env['sinatra.error'].name
  end

  get '/describe' do
    if params['location'].nil?
      throw :halt, [400, "require a location parameter."]
    end

    url = URI.parse(params['location'].to_s)
    case url.scheme
    when "file"
      @input = url.path
    when "http"
      resource = Net::HTTP.get_response url
      Tempfile.open("file2describe") do |io|
        io.write resource.body
        io.flush
        @input = io.path
      end
    else
      throw :halt, [400,  "invalid url location type"]
    end

    @originalName = url.path
    if (@input.nil?)
      throw :halt, [400,  "invalid url location"]
    end

    # make sure the file exist and it's a valid file
    if (File.exist?(@input) && File.file?(@input)) then
      description
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
      puts params['document'][:tempfile].path
      File.link(params['document'][:tempfile].path, @input)
    when String
      tmp = File.new(@input, "w+")
      tmp.write params['document']
      tmp.close
    end
    
    pp params['document'][:filename]
    
    @originalName = params['document'][:filename]
    puts "originalName:#{@originalName}"
    # describe the transmitted file with format identifier and metadata 
    description
    File.delete(@input)
    response.finish
  end

  def description
    jhove = RJhove.new
    droid = RDroid.instance
    validator = nil

    if request.env["HTTP_HOST"]
      @agent_url = "http://" + request.env["HTTP_HOST"]  + request.env["PATH_INFO"]
    else
      @agent_url =  "http://description.fcla.edu" + request.env["PATH_INFO"]
    end
 
    DescribeLogger.instance.info "describe #{@input}"
    # identify the file format
    @formats = droid.identify(@input)

    begin
      if (@formats.empty?)
        @result = jhove.retrieveFileProperties(@input, @formats)
      else
        # extract the technical metadata
        @result = jhove.extractAll(@input, @formats)
      end
    rescue => e
      puts "running into exception #{e}"
      puts e.backtrace
    end

    unless (@result.nil?)
      # build a response
      headers 'Content-Type' => 'application/xml'
      
      @result.fileObject.originalName = @originalName
      
      # dump the xml output to the response, pretty the xml output (ruby bug)
      body erb(:premis)
  
      DescribeLogger.instance.info "HTTP 200"
    else
      throw :halt, [500, "unexpected empty response"]
    end
  end
end

Describe.run! if __FILE__ == $0
