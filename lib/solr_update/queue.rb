class SolrUpdate::Queue
  def self.enqueue_for_update(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'update')
  end

  def self.enqueue_for_delete(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'delete')
  end

  def self.run
    proxy = SolrUpdate::IndexProxy::Allele.new
    SolrUpdate::Queue::Item.process_in_order do |reference, action|
      if action == 'update'
        command = SolrUpdate::CommandFactory.create_solr_command_to_update_in_index(reference)
      elsif action == 'delete'
        command = SolrUpdate::CommandFactory.create_solr_command_to_delete_from_index(reference)
      end
      proxy.update(command)
      @@after_update_hook.call(reference, action) if @@after_update_hook
    end
  end

  @@after_update_hook = nil

  def self.after_update_hook(&block)
    @@after_update_hook = block
  end

end
