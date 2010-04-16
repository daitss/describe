require 'rubygems'
require 'sinatra'
$:.unshift '/var/www/html/description/lib'

require '/var/www/html/description/describe.rb'
Sinatra::Default.set(:run, false)

Rack::Handler::Thin.run Describe, :Port => 4577

# require 'rubygems'
# require 'sinatra'
# 
# log = File.new("log/describe.log", "a")
# STDOUT.reopen(log)
# STDERR.reopen(log)
#  
# Rack::Handler::Thin.run Describe, :Port => 4577