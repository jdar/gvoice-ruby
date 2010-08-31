# -*- encoding: utf-8 -*-
$:.unshift "." # Ruby 1.9.2 does not include current directory in the path
require File.dirname(__FILE__) + "/test_helper"
require 'mocha'
 
class ClientTest < Test::Unit::TestCase
  def setup
    @config_file = File.join(File.dirname(__FILE__), 'fixtures', 'config_fixture.yml')
    @page_body = String.new(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'login_fixture.html')))
  end
  
  should "raise argument error if username nil" do
    assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_email => nil }) }
  end
  
  should "raise argument error if password nil" do
    assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_password => nil }) }
  end
  
  should "accept a simple hash as parameters" do
    Curl::Easy.any_instance.stubs(:perform).returns(true)
    Curl::Easy.any_instance.stubs(:body_str).returns(@page_body)
    client = GvoiceRuby::Client.new({:google_account_email => 'google_test_account@gmail.com', :google_account_password => "bar"})
    assert_kind_of(GvoiceRuby::Client, client)
    # assert_equal(File.join(File.dirname(File.dirname(__FILE__)), 'log', 'gvoice-ruby.log'),           
                    # client.logger.instance_variable_get(:@logdev).instance_variable_get(:@filename))
  end
  
  should "raise an error when unable to connect to Google" do
    # Curl::Easy.any_instance.stubs(:perform).returns(false)
    # Curl::Easy.any_instance.stubs(:response_code).returns()
    client = GvoiceRuby::Client.new(GvoiceRuby::Configurator.load_config(@config_file))
    assert_equal(client.instance_variable_get(:@curb_instance).response_code, 405)
  end
  
  should "raise an error when failing to login" do
    Curl::Easy.any_instance.stubs(:perform).returns(false)
    assert_raise(GvoiceRuby::LoginFailed) do
      GvoiceRuby::Client.new({:google_account_email => 'google_test_account@gmail.com', :google_account_password => "bar"})
    end
  end
  
  should "login" do
    Curl::Easy.any_instance.stubs(:body_str).returns(@page_body)
    client = GvoiceRuby::Client.new(GvoiceRuby::Configurator.load_config(@config_file))
    assert client.logged_in?
    assert_kind_of(Curl::Easy, client.instance_variable_get(:@curb_instance))
  end
  
  should "logout" do
    Curl::Easy.any_instance.stubs(:body_str).returns(@page_body)
    client = GvoiceRuby::Client.new(GvoiceRuby::Configurator.load_config(@config_file))
    assert client.logged_in?
    assert_kind_of(Curl::Easy, client.instance_variable_get(:@curb_instance))
    Curl::Easy.any_instance.stubs(:perform).returns(true)
    client.logout
    deny client.logged_in?
  end
end
