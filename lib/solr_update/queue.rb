class SolrUpdate::Queue
  class BulkError < SolrUpdate::Error
    def initialize(message, exceptions)
      super(message)
      @exceptions = exceptions
    end

    attr_reader :exceptions
  end

  def self.enqueue_for_update(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'update')
  end

  def self.enqueue_for_delete(object_or_reference)
    SolrUpdate::Queue::Item.add(object_or_reference, 'delete')
  end

  def self.run(args = {})
    args.symbolize_keys!

    proxy = SolrUpdate::IndexProxy::Allele.new
    if args.has_key?(:limit)
      limit = args[:limit]
    else
      limit = SolrUpdate::Config['queue_run_limit']
    end

    exceptions = []

    SolrUpdate::Queue::Item.process_in_order(:limit => limit) do |reference, action|
      begin
        if action == 'update'
          command = SolrUpdate::CommandFactory.create_solr_command_to_update_in_index(reference)
        elsif action == 'delete'
          command = SolrUpdate::CommandFactory.create_solr_command_to_delete_from_index(reference)
        end
        proxy.update(command)
        @@after_update_hook.call(reference, action) if @@after_update_hook
      rescue SolrUpdate::Error => e
        exceptions << [e, reference]
      end
    end

    if exceptions.present?
      message = "Errors during SOLR update:\n"

      exceptions.each do |e, reference|
        message += "\n#{e.class.name} for reference #{reference.inspect}: #{e.message}\n#{e.backtrace.join("\n")}\n"
      end

      raise BulkError.new(message, exceptions.map(&:first))
    end
  end

  @@after_update_hook = nil

  def self.after_update_hook(&block)
    @@after_update_hook = block
  end

end
