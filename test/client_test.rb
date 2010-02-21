# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/../test/test_helper")
require 'gvoice-ruby/client'
require 'gvoice-ruby/user'
require 'gvoice-ruby'
require 'mocha'
 
class ClientTest < Test::Unit::TestCase
  
  def setup
    setup_config_fixture
    puts @config.to_yaml
  end
  
  should "raise argument error if username nil" do
    assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_email => nil }) }
  end
  
  should "raise argument error if password nil" do
    assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_password => nil }) }
  end
  
  should "raise an error when unable to connect to Google" do
    Curl::Easy.any_instance.stubs(:perform).returns(false)
    assert_raise(Curl::Err::ConnectionFailedError) { GvoiceRuby::Client.new(@config) }
  end
  
  should "login" do
    client = GvoiceRuby::Client.new(@config)
    assert client.logged_in?
    assert_kind_of(Curl::Easy, client.instance_variable_get(:@curb_instance))
  end
  
  should "logout" do
    client = GvoiceRuby::Client.new(@config)
    assert client.logged_in?
    assert_kind_of(Curl::Easy, client.instance_variable_get(:@curb_instance))
    client.logout
    deny client.logged_in?
  end
end