require 'test_helper'

class SolrUpdate::ActionPerformerTest < ActiveSupport::TestCase
  context 'SolrUpdate::ActionPerformer' do

    teardown do
      SolrUpdate::IndexProxy::Allele.any_instance.unstub(:update)
    end

    should 'update docs in index when a referenced entity has changed' do
      reference = stub('reference')
      command = stub('command')

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_update_in_index).with(reference).returns(command)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command)

      SolrUpdate::ActionPerformer.do(reference, 'update')
    end

    should 'delete docs from index when a referenced entity has been deleted' do
      reference = stub('reference')
      command = stub('command')

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_delete_from_index).with(reference).returns(command)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command)

      SolrUpdate::ActionPerformer.do(reference, 'delete')
    end

  end
end
