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

#load all required JAVA library.
Rjb::load('jars/jhove.jar:jars/jhove-module.jar:jars/jhove-handler.jar:jars/shades.jar:jars/droid.jar')
 
enable :logging

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

put '/describe' do 
  params['extension']

  if (params["extensioin"].nil?)
    throw :halt, [400,  "extension parameter is required"]
  end
  extension = params["extension"].to_s
  size = request.params["HTTP_CONTENT_LENGTH"]

  unless (size.nil?)
    tmp = File.new("/var/tmp/object." + extension, "w+")
    @input = tmp.path()
    # read 1 MB at a time
    while (buff = request.body.read(1048510))
      tmp.write buff
    end
    tmp.close

    # describe the transmitted file with format identifier and metadata 
    description
  else
    throw :halt, [411, "HTTP_CONTENT_LENGTH not defined"]
  end
  response.finish
  
end

def description
  jhove = RJhove.instance
  droid = RDroid.instance
  validator = nil

  DescribeLogger.instance.info "describe #{@input}"
  # identify the file format
  @formats = droid.identify(@input)

  if (@formats.empty?)
    @result = jhove.retrieveFileProperties(@input, @formats)
  else
    # extract the technical metadata
    @result = jhove.extractAll(@input, @formats)
  end

    # build a response
    headers 'Content-Type' => 'application/xml'
    # dump the xml output to the response, pretty the xml output (ruby bug)
    body erb(:fileObject)
    
    DescribeLogger.instance.info "HTTP 200"
  # else
  #   throw :halt, [500, "unexpected empty response"]
  # end
end
