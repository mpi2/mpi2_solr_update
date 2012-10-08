require 'solr_update'
require 'solr_update/util'
require 'solr_update/config'
require 'solr_update/net_http_proxy'
require 'solr_update/index_proxy'
require 'solr_update/queue'
require 'solr_update/command_factory'
require 'solr_update/test_help'

if Rails::VERSION::MAJOR <= 2
  SolrUpdate::Config.init_config
else
  class SolrUpdate::Railtie < ::Rails::Railtie
    initializer "solr_update.railtie.configure_rails_initialization" do
      SolrUpdate::Config.init_config
    end
  end
end
