# # -*- encoding: utf-8 -*-
# $:.unshift "." # Ruby 1.9.2 does not include current directory in the path
# require File.dirname(__FILE__) + "/test_helper"
# require 'mocha'
#  
# class ClientTest < Test::Unit::TestCase
#   def setup
#     warn "client test setup is running..."
#     @page_body = String.new(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'login_fixture.html')))
#     warn String.new(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'login_fixture.html')))
#     # warn "client test setup is running..."
#     warn "GALX in #{@page_body.scan(/GALX/)}"
#   end
#   
#   should "raise argument error if username nil" do
#     assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_email => nil }) }
#   end
#   
#   should "raise argument error if password nil" do
#     assert_raise(ArgumentError) { GvoiceRuby::Client.new({ :google_account_password => nil }) }
#   end
#   
#   should "raise an error when unable to connect to Google" do
#     
#     assert true
#   end
#   
#   should "login" do
#     Curl::Easy.any_instance.stubs(:body_str).returns(@page_body)
#     warn "self.config file is #{self.config_file}\n"
#     client = GvoiceRuby::Client.new(GvoiceRuby::Configurator.load_config(self.config_file))
#     assert client.logged_in?
#     assert_kind_of(Curl::Easy, client.instance_variable_get(:@curb_instance))
#   end
#   
#   should "logout" do
#     Curl::Easy.any_instance.stubs(:body_str).returns(@page_body)
#     warn "Config file is #{self.config_file}"
#     client = GvoiceRuby::Client.new(GvoiceRuby::Configurator.load_config(self.config_file))
#     assert client.logged_in?
#     assert_kind_of(Curl::Easy, client.instance_variable_get(:@curb_instance))
#     Curl::Easy.any_instance.stubs(:perform).returns(true)
#     client.logout
#     deny client.logged_in?
#   end
# end













































