require 'active_support'
ActiveSupport::JSON

# stdlib
require 'net/http'
require 'net/https'

require 'aha_services/version'
require 'aha_services/networking'
require 'aha_services/schema'
require 'aha_services/errors'
require 'aha_services/service'

Dir["#{File.dirname(__FILE__)}/services/**/*.rb"].each {|file| require file }