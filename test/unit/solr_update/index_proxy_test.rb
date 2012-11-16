require 'test_helper'

class SolrUpdate::IndexProxyTest < ActiveSupport::TestCase

  context 'SolrUpdate::IndexProxy::Gene' do
    should_if_solr 'retrieve marker_symbol for an mgi_accession_id from a solr index' do
      index_proxy = SolrUpdate::IndexProxy::Gene.new
      assert_equal 'Cbx1', index_proxy.get_marker_symbol('MGI:105369')
      assert_equal 'Tead1', index_proxy.get_marker_symbol('MGI:101876')
    end

    should 'raise error if gene not found' do
      index_proxy = SolrUpdate::IndexProxy::Gene.new
      assert_raise(SolrUpdate::LookupError) { index_proxy.get_marker_symbol('MGI:XXXXXXXXXXXXX') }
    end
  end

  context 'SolrUpdate::IndexProxy::Allele' do
    should_if_solr 'send update commands to index and then gets them: #search and #update' do
      docs = [
        {
          'id' => rand(999),
          'type' => 'test',
          'mgi_accession_id' => 'MGI:99999999991',
          'allele_id' => 55
        },
        {
          'id' => rand(999),
          'type' => 'test',
          'mgi_accession_id' => 'MGI:99999999992',
          'allele_id' => 56
        }
      ]

      commands = ActiveSupport::OrderedHash.new
      commands['delete'] = {'query' => "type:test"}
      commands['add'] = docs
      commands['commit'] = {}
      commands['optimize'] = {}
      commands_json = commands.to_json

      proxy = SolrUpdate::IndexProxy::Allele.new
      proxy.update(commands_json)

      fetched_docs = proxy.search(:q => 'type:test')
      assert_equal docs.map{|a| a['id']}.sort, fetched_docs.map {|a| a['id']}.sort
    end
  end

end
