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

#load all required JAVA library.
jar_pattern = File.expand_path File.join(File.dirname(__FILE__), 'jars', '*.jar')
jars = Dir[jar_pattern].join ':'
Rjb::load jars

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
    puts options.inspect
    erb :index
  end

  post '/describe' do 
    halt 400, "query parameter document is required" unless params['document']
    halt 400, "query parameter extension is required" unless params['extension']  
   
    extension = params["extension"].to_s 
    @input = "/tmp/object." + extension;
    case params['document']
    when Hash
      puts params['document'][:tempfile].path
      File.link(params['document'][:tempfile].path, @input)
    when String
      tmp = File.new(@input, "w+")
      tmp.write params['document']
      tmp.close
    end
    # puts params['document'].inspect
    # puts @input
    # describe the transmitted file with format identifier and metadata 
    description
    File.delete(@input)
    response.finish

  end

  put '/describe' do 
    params['extension']

    if (params["extension"].nil?)
      throw :halt, [400,  "extension parameter is required"]
    end
    extension = params["extension"].to_s
    size = request.env["CONTENT_LENGTH"]

    unless (size.nil?)
      tmp = File.new("/tmp/object." + extension, "w+")
      @input = tmp.path()
      # read 1 MB at a time
      while (buff = request.body.read(1048510))
        tmp.write buff
      end
      tmp.close
 
      # describe the transmitted file with format identifier and metadata 
      description

      File.delete(@input)
    else
      throw :halt, [411, "CONTENT_LENGTH not defined"]
    end
    response.finish

  end

  def description
    jhove = RJhove.new
    droid = RDroid.instance
    validator = nil

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
    end

    unless (@result.nil?)
      # build a response
      headers 'Content-Type' => 'application/xml'
      # dump the xml output to the response, pretty the xml output (ruby bug)
      body erb(:premis)

      DescribeLogger.instance.info "HTTP 200"
    else
      throw :halt, [500, "unexpected empty response"]
    end
  end
end

Describe.run! if __FILE__ == $0