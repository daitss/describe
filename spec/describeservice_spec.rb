require 'describe'
require 'fileutils'
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

set :environment, :test

describe 'Describe Service' do
  include Sinatra::Test

  abs = FileUtils.pwd
  before(:all) do
    begin
      #load all required JAVA library.
      Rjb::load('jars/jhove.jar:jars/jhove-module.jar:jars/jhove-handler.jar:jars/shades.jar:lib/droid.jar')

      @url = '/describe'
    end
     
    # def send(method, querystring = nil, data=nil, head=nil)
    #   url = URI.parse(@url)   
    #   #puts querystring
    #   response = Net::HTTP.start(url.host, url.port) {|http|
    #     unless (querystring.nil?)
    #       http.send_request(method, url.path + querystring, data, head)
    #     else
    #       http.send_request(method, url.path, data, head)
    #     end
    #   }
    #   response
    # end
  

    it "it should return 200 for PUT with text data" do  
      put "describe/?extension=txt", "testing data"
      response.should be_ok
    end

    it "should return 400 if missing url" do
      get ''
      response.code.to_i.should == 400
    end

    it "should return 400 for bad url location scheme" do
      get '/describe?scheme:///test'
      response.code.to_i.should == 400
    end

    it "should return 404 for invalid file" do
      get "/describe?location=file://#{abs}/files/wood12"
      response.code.to_i.should == 404
    end

    it "it should return 400 for PUT missing extension parameter" do  
      put 
      response.code.to_i.should == 400
    end

    it "should return 405 for unsupported HEAD method" do
      head
      response.code.to_i.should == 405
    end

  end
end