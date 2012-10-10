require 'bundler/setup'

RACK_ENV = 'test'
Bundler.require(:default, RACK_ENV)

SimpleCov.start do
  add_filter 'vendor/gems'

  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
end

# Use test database
DataMapper.setup(:default, 'postgres://dan@localhost/brt_test')

require 'test/unit'
require_relative 'spec/mini'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

require 'boot'
include Rack::Test::Methods

def app
  Brt::App
end
