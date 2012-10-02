require 'test_helper'

class SolrUpdate::ActionPerformerTest < ActiveSupport::TestCase
  context 'SolrUpdate::ActionPerformer' do

    should 'update docs in index and trigger after-update filter when a referenced entity has changed' do
      reference = stub('reference')
      command = stub('command')
      seq = sequence('seq')

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_update_in_index).with(reference).returns(command)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command).in_sequence(seq)
      SolrUpdate::ActionPerformer.expects(:after_update).with(reference).in_sequence(seq)

      SolrUpdate::ActionPerformer.do(reference, 'update')
    end

    should 'delete docs from index when a referenced entity has been deleted' do
      reference = stub('reference')
      command = stub('command')
      seq = sequence('seq')

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_delete_from_index).with(reference).returns(command)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command).in_sequence(seq)
      SolrUpdate::ActionPerformer.expects(:after_delete).with(reference).in_sequence(seq)

      SolrUpdate::ActionPerformer.do(reference, 'delete')
    end

    should 'have an empty after_update that may be optionally overridden' do
      assert_nothing_raised { SolrUpdate::ActionPerformer.after_update('reference') }
    end

    should 'have an empty after_delete that may be optionally overridden' do
      assert_nothing_raised { SolrUpdate::ActionPerformer.after_delete('reference') }
    end

  end
end
