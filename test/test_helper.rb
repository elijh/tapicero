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

unless defined? DEBUG
  DEBUG = ENV["DEBUG"]
end

$:.unshift BASE_DIR + 'lib'

require 'mocha/setup'

require 'tapicero/version'
Tapicero::CONFIGS << "test/config.yaml"
Tapicero::RERAISE = true
require 'tapicero'

require_relative 'support/integration_test'

require_relative 'support/tapicero_process'
TapiceroProcess.kill!
MiniTest.after_run {
  TapiceroProcess.kill!
}

puts
puts "   REMINDER: check /tmp/tapicero.log for errors"
puts