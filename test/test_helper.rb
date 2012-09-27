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

  class ::Rails
    module VERSION
      MAJOR = 2
    end
    def self.env; 'test'; end
    def self.test?; true; end
    def self.root; GEM_ROOT; end
    def self.logger; @@logger ||= Logger.new(GEM_ROOT + '/log/test.log'); end
  end
end

require 'mpi2_solr_update'

class SolrUpdate::Queue::Item
end

class SolrUpdate::DocFactory
end
