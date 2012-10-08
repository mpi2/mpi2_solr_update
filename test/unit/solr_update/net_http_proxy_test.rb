require 'test_helper'

class SolrUpdate::NetHttpProxyTest < ActiveSupport::TestCase
  context 'SolrUpdate::NetHttpProxy' do

    setup do
      Net::HTTP.unstub(:get)
      Net::HTTP.unstub(:post)
    end

    context '#should_use_proxy_for?' do
      should 'work' do
        begin
          old_no_proxy = ENV['NO_PROXY']
          ENV['NO_PROXY'] = 'somedomain, fakedomain, nonexistent_domain'
          assert_equal true, SolrUpdate::NetHttpProxy.should_use_proxy_for?('testdomain.com')
          assert_equal false, SolrUpdate::NetHttpProxy.should_use_proxy_for?('fakedomain.com')
        ensure
          ENV['NO_PROXY'] = old_no_proxy if old_no_proxy
        end
      end
    end

  end
end
