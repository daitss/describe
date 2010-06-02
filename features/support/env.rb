require "rubygems"
require "bundler"
Bundler.setup
require 'rack/test'
require 'spec/expectations'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require File.dirname(__FILE__) + "/../../describe"

Sinatra::Application.set :environment, :test

World do

  def app
    Sinatra::Application
  end

  include Rack::Test::Methods
  # include Webrat::Methods
  # include Webrat::Matchers
end
