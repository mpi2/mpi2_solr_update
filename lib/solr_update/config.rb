class SolrUpdate::Config
  def self.init_config
    return if class_variable_defined?(:@@config)
    pre_parsed_config = YAML.load_file("#{Rails.root}/config/solr_update.yml")
    @@config = pre_parsed_config.fetch(Rails.env)
    @@config.merge!(pre_parsed_config['all'])
  end

  def self.[](key)
    return @@config[key]
  end

  def self.fetch(key)
    return @@config.fetch(key)
  end

end
