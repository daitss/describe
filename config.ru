require 'rubygems'
require 'sinatra'
$:.unshift '/var/www/html/description/lib'

require '/var/www/html/description/describe.rb'
Sinatra::Default.set(:run, false)

Rack::Handler::Thin.run Describe, :Port => 4577
