require 'test_helper'

class SolrUpdate::QueueTest < ActiveSupport::TestCase
  context 'SolrUpdate::Queue' do

    teardown do
      SolrUpdate::Queue.after_update_hook(&nil)
    end

    should 'allow adding of queue items' do
      object1 = stub('object1')
      object2 = stub('object2')
      object3 = stub('object3')

      seq = sequence('seq')

      SolrUpdate::Queue::Item.expects(:add).with(object1, 'update').in_sequence(seq)
      SolrUpdate::Queue::Item.expects(:add).with(object2, 'update').in_sequence(seq)
      SolrUpdate::Queue::Item.expects(:add).with(object3, 'delete').in_sequence(seq)

      SolrUpdate::Queue.enqueue_for_update(object1)
      SolrUpdate::Queue.enqueue_for_update(object2)
      SolrUpdate::Queue.enqueue_for_delete(object3)
    end

    should 'be run and process items in order they were added' do
      command1 = stub('command1')
      command2 = stub('command2')

      ref1 = stub('ref1')
      ref2 = stub('ref2')

      used_within_block = stub('used_within_block')

      SolrUpdate::Queue::Item.expects(:process_in_order).multiple_yields([ref1, 'update'], [ref2, 'delete'])

      SolrUpdate::Queue.after_update_hook { used_within_block.used }

      seq = sequence('seq')

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_update_in_index).with(ref1).returns(command1).in_sequence(seq)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command1).in_sequence(seq)
      used_within_block.expects(:used).in_sequence(seq)

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_delete_from_index).with(ref2).returns(command2).in_sequence(seq)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command2).in_sequence(seq)
      used_within_block.expects(:used).in_sequence(seq)

      SolrUpdate::Queue.run
    end

    should 'be allow number of items to be processed to be configurable via config file' do
      begin
        SolrUpdate::IndexProxy::Allele.any_instance.stubs(:update)
        SolrUpdate::DocFactory.stubs(:create_solr_command_to_delete_from_index)
        SolrUpdate::DocFactory.stubs(:create_solr_command_to_update_in_index)

        class SolrUpdate::Config; @@config['queue_run_limit'] = 5; end
        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => 5)
        SolrUpdate::Queue.run

        class SolrUpdate::Config; @@config.delete 'queue_run_limit'; end
        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => nil)
        SolrUpdate::Queue.run

        class SolrUpdate::Config; @@config.delete 'queue_run_limit'; end
        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => nil)
        SolrUpdate::Queue.run
      ensure
        SolrUpdate::Config.init_config
        SolrUpdate::DocFactory.unstub(:create_solr_command_to_delete_from_index)
        SolrUpdate::IndexProxy::Allele.any_instance.unstub(:update)
      end
    end

    should 'be allow number of items to be processed to be configurable via argument, overriding config file' do
      begin
        SolrUpdate::IndexProxy::Allele.any_instance.stubs(:update)
        SolrUpdate::DocFactory.stubs(:create_solr_command_to_delete_from_index)
        SolrUpdate::DocFactory.stubs(:create_solr_command_to_update_in_index)
        class SolrUpdate::Config; @@config['queue_run_limit'] = 5; end

        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => 10)
        SolrUpdate::Queue.run(:limit => 10)

        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => nil)
        SolrUpdate::Queue.run(:limit => nil)
      ensure
        SolrUpdate::Config.init_config
        SolrUpdate::DocFactory.unstub(:create_solr_command_to_delete_from_index)
        SolrUpdate::IndexProxy::Allele.any_instance.unstub(:update)
      end
    end

  end
end
