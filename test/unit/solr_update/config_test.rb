require 'test_helper'

class SolrUpdate::ConfigTest < ActiveSupport::TestCase
  context 'SolrUpdate::Config' do

    should 'parse config file and return values using [] for current environment' do
      assert_equal 'http://localhost:8984/solr/allele', SolrUpdate::Config['index_proxy']['allele']
    end

    should 'implement fetch interface like hashes' do
      assert_equal 'http://localhost:8984/solr/allele', SolrUpdate::Config.fetch('index_proxy')['allele']
      if RbConfig::CONFIG['ruby_version'].match /^1\.8/
        assert_raise(IndexError) { SolrUpdate::Config.fetch('nonexistent') }
      else
        assert_raise(KeyError) { SolrUpdate::Config.fetch('nonexistent') }
      end
    end

    should 'allow access to targ_rep_url and other "all" values from any environment' do
      assert_equal 'http://www.knockoutmouse.org/targ_rep', SolrUpdate::Config['targ_rep_url']
    end

  end
end
