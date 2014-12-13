require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
require 'pathname'

unless defined? BASE_DIR
  BASE_DIR = Pathname.new(__FILE__) + '../..'
end

begin
  require 'debugger'
rescue LoadError
end

$:.unshift BASE_DIR + 'lib'

require 'mocha/setup'

require 'tapicero/version'
Tapicero::CONFIGS << "test/config.yaml"
Tapicero::RERAISE = true
require 'tapicero'

require_relative 'support/integration_test'
