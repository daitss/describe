require "rubygems"
require "bundler"
Bundler.setup
require 'rack/test'
require 'rspec/expectations'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require File.dirname(__FILE__) + "/../../app"

Sinatra::Application.set :environment, :test

World do

  def app
    Sinatra::Application
  end

  include Rack::Test::Methods
  # include Webrat::Methods
  # include Webrat::Matchers
end
