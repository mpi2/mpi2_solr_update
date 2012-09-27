class SolrUpdate::Queue
  def self.enqueue_for_update(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'update')
  end

  def self.enqueue_for_delete(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'delete')
  end

  def self.run
    proxy = SolrUpdate::IndexProxy::Allele.new
    SolrUpdate::Queue::Item.process_in_order do |reference, command_type|
      if command_type == 'update'
        command = SolrUpdate::CommandFactory.create_solr_command_to_update_in_index(reference)
      elsif command_type == 'delete'
        command = SolrUpdate::CommandFactory.create_solr_command_to_delete_from_index(reference)
      end
      proxy.update(command)
    end
  end

end
