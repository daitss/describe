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

    it "should return 405 for unsupported HEAD method" do
      head
      response.code.to_i.should == 405
    end

  end
end
