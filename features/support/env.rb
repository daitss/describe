require File.dirname(__FILE__) + "/../../describe"

# RSpec matchers
require 'spec/expectations'

# Required for RSpec to play nice with Sinatra/Test
#require 'spec/interop/test'

# Sinatra/Test
require 'sinatra/test'

Test::Unit::TestCase.send :include, Sinatra::Test

World do
  Sinatra::TestHarness.new(Sinatra::Application)
end
