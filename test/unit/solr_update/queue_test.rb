require 'test_helper'

class SolrUpdate::QueueTest < ActiveSupport::TestCase
  context 'SolrUpdate::Queue' do

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
      reference1 = stub('reference1')
      reference2 = stub('reference2')
      reference3 = stub('reference3')

      SolrUpdate::Queue::Item.expects(:process_in_order).with().multiple_yields(
        [reference1, 'update'],
        [reference2, 'delete'],
        [reference3, 'update']
      )

      SolrUpdate::ActionPerformer.expects(:do).with(reference1, 'update')
      SolrUpdate::ActionPerformer.expects(:do).with(reference2, 'delete')
      SolrUpdate::ActionPerformer.expects(:do).with(reference3, 'update')

      SolrUpdate::Queue.run
    end

  end
end
