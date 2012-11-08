require 'test_helper'

class SolrUpdate::QueueTest < ActiveSupport::TestCase
  context 'SolrUpdate::Queue' do

    teardown do
      SolrUpdate::Queue.after_update_hook(&nil)
      SolrUpdate::CommandFactory.unstub(:create_solr_command_to_delete_from_index)
      SolrUpdate::CommandFactory.unstub(:create_solr_command_to_update_in_index)
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

    should 'be run and process items in order they were added which are then deleted' do
      item1 = stub('item1')
      item2 = stub('item2')
      seq = sequence('seq')

      SolrUpdate::Queue::Item.expects(:process_in_order).multiple_yields(item1, item2)
      SolrUpdate::Queue.expects(:process_item).with(item1).in_sequence(seq)
      SolrUpdate::Queue.expects(:process_item).with(item2).in_sequence(seq)

      SolrUpdate::Queue.run
    end

    should 'be allow number of items to be processed to be configurable via config file' do
      begin
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
      end
    end

    should 'allow number of items to be processed to be configurable via argument, overriding config file' do
      begin
        class SolrUpdate::Config; @@config['queue_run_limit'] = 5; end

        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => 10)
        SolrUpdate::Queue.run(:limit => 10)

        SolrUpdate::Queue::Item.expects(:process_in_order).with(:limit => nil)
        SolrUpdate::Queue.run(:limit => nil)
      ensure
        SolrUpdate::Config.init_config
      end
    end

    should 'store up SolrUpdate::Error-derived exceptions from items that failed to process and print them out en-masse; failed items are not destroyed' do
      ref1 = {'type' => 'test', 'id' => 9001}
      ref2 = {'type' => 'test', 'id' => 9002}
      ref3 = {'type' => 'test', 'id' => 9003}
      ref4 = {'type' => 'test', 'id' => 9004}

      item1 = stub('item1', :reference => ref1, :action => 'update')
      item2 = stub('item2', :reference => ref2, :action => 'update')
      item3 = stub('item3', :reference => ref3, :action => 'update')
      item4 = stub('item4', :reference => ref4, :action => 'update')

      SolrUpdate::Queue::Item.expects(:process_in_order).multiple_yields(item1, item2, item3, item4)
      SolrUpdate::Queue.stubs(:process_item).raises(SolrUpdate::IndexProxy::UpdateError).then.returns(nil).then.raises(SolrUpdate::IndexProxy::LookupError).then.raises(SolrUpdate::IndexProxy::UpdateError)

      begin
        SolrUpdate::Queue.run

        flunk 'Should not get here - ' +
                'BulkError should have been raised'
      rescue SolrUpdate::Queue::BulkError => e
        exception_kinds = e.exceptions.map(&:class)
        assert_equal [SolrUpdate::IndexProxy::UpdateError, SolrUpdate::IndexProxy::LookupError, SolrUpdate::IndexProxy::UpdateError], exception_kinds
        assert_match /UpdateError.+LookupError.+UpdateError/m, e.message
      end
    end

    should 'allow processing of a single item that is processed successfully' do
      ref1 = {'type' => 'test', 'id' => 9001}
      ref2 = {'type' => 'test', 'id' => 9002}
      item1 = stub('item1', :reference => ref1, :action => 'update')
      item2 = stub('item2', :reference => ref2, :action => 'delete')
      command1 = stub('command1')
      command2 = stub('command2')
      seq = sequence('seq')

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_update_in_index).with(ref1).returns(command1).in_sequence(seq)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command1).in_sequence(seq)
      item1.expects(:destroy).in_sequence(seq)

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_delete_from_index).with(ref2).returns(command2).in_sequence(seq)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command2).in_sequence(seq)
      item2.expects(:destroy).in_sequence(seq)

      SolrUpdate::Queue.process_item(item1)
      SolrUpdate::Queue.process_item(item2)
    end

    should 'invoke after update hook correctly when processing single item' do
      ref1 = {'type' => 'test', 'id' => 9001}
      item1 = stub('item1', :reference => ref1, :action => 'update')
      command1 = stub('command1')
      used_within_block = stub('used_within_block')
      seq = sequence('seq')

      SolrUpdate::Queue.after_update_hook { used_within_block.used }

      SolrUpdate::CommandFactory.expects(:create_solr_command_to_update_in_index).with(ref1).returns(command1).in_sequence(seq)
      SolrUpdate::IndexProxy::Allele.any_instance.expects(:update).with(command1).in_sequence(seq)
      used_within_block.expects(:used).in_sequence(seq)
      item1.expects(:destroy).in_sequence(seq)

      SolrUpdate::Queue.process_item(item1)
    end

  end
end
