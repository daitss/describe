require File.dirname(__FILE__) + "/../../describe"

# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = File.join(File.dirname(__FILE__), "/../../describe")
require 'rack/test'
# RSpec matchers
require 'spec/expectations'

Sinatra::Application.set :environment, :development

World do
  def app
      Sinatra::Application
  end
  include Rack::Test::Methods
  # include Webrat::Methods
  # include Webrat::Matchers
end
