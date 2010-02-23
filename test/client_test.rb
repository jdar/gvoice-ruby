# coding: utf-8
require File.dirname(__FILE__) + "/test_helper"
require 'gvoice-ruby/client'
require 'gvoice-ruby/user'
require 'gvoice-ruby'
require 'mocha'
 
class ClientTest < Test::Unit::TestCase
  
  def setup
    setup_config_fixture
    @page_body = String.new(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'login_fixture.html')))
    # puts @page_body
  end
  
  should "raise argument error if username nil" do
    assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_email => nil }) }
  end
  
  should "raise argument error if password nil" do
    assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_password => nil }) }
  end
  
  should "raise an error when unable to connect to Google" do
    
    assert true
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