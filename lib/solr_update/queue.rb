class SolrUpdate::Queue
  def self.enqueue_for_update(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'update')
  end

  def self.enqueue_for_delete(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'delete')
  end

  def self.run
    SolrUpdate::Queue::Item.process_in_order do |reference, type_of_change|
      SolrUpdate::ActionPerformer.do(reference, type_of_change)
    end
  end

end
