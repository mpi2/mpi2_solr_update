class SolrUpdate::ActionPerformer

  def self.do(reference, type_of_change)
    proxy = SolrUpdate::IndexProxy::Allele.new
    if type_of_change == 'update'
      command = SolrUpdate::CommandFactory.create_solr_command_to_update_in_index(reference)
    elsif type_of_change == 'delete'
      command = SolrUpdate::CommandFactory.create_solr_command_to_delete_from_index(reference)
    end
    proxy.update(command)
  end

end