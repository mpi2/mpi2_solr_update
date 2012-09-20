require 'rubygems'
require 'bundler/setup'

require 'rbconfig'
require 'yaml'
require 'active_support'
require 'active_support/core_ext'
require 'net/http'
require 'test-unit'
require 'shoulda'
require 'mocha'

GEM_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

if ! Object.const_defined?(:Rails)
  require 'ostruct'
  require 'logger'

  logger = Logger.new(GEM_ROOT + '/log/test.log')

  ::Rails = OpenStruct.new(
    :env => 'test',
    :test? => true,
    :root => GEM_ROOT,
    :logger => logger
  )
end

puts Rails.root

require 'mpi2_solr_update'

class SolrUpdate::Queue::Item
end

class SolrUpdate::CommandFactory
end
