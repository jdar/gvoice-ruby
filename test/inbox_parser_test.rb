# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/test_helper"
require 'mocha'

class InboxParserTest < Test::Unit::TestCase
  
  def setup
    @page_body = String.new(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'inbox_fixture.html')))
    @inbox_fixture = File.open(File.join(File.dirname(__FILE__), 'fixtures', 'inbox.yml')) { |yf| YAML::load(yf) }
    @page_obj = mock()
    @page_obj.stubs(:body_str).returns(@page_body)
  end
  
  should "return true" do
    assert true
  end
  
  should "create instance variables" do
    ibp = GvoiceRuby::InboxParser.new
    assert_equal([], ibp.instance_variable_get(:@smss))
    assert_equal([], ibp.instance_variable_get(:@voicemails))    
  end
  
  should "parse the page" do
    GvoiceRuby::Client.any_instance.stubs(:fetch_page).returns(true)
    inbox = GvoiceRuby::InboxParser.new.parse_page(@page_obj)
    assert_equal(Hash, inbox.class)
    assert_equal(@inbox_fixture, inbox)
  end
  
  should "parse sms messages" do
    GvoiceRuby::Client.any_instance.stubs(:fetch_page).returns(true)
    parser = GvoiceRuby::InboxParser.new
    inbox = parser.parse_page(@page_obj)
    parser.parse_sms_messages(inbox['messages'])
    assert_equal(parser.instance_variable_get(:@smss)[0].class, GvoiceRuby::Sms)
    assert_equal(parser.instance_variable_get(:@voicemails), [])
  end
  
  should "parse voicemail messages" do
    GvoiceRuby::Client.any_instance.stubs(:fetch_page).returns(true)
    parser = GvoiceRuby::InboxParser.new
    inbox = parser.parse_page(@page_obj)
    parser.parse_voicemail_messages(inbox['messages'])
    assert_equal(parser.instance_variable_get(:@voicemails)[0].class, GvoiceRuby::Voicemail)
    assert_equal(parser.instance_variable_get(:@smss), [])
  end
  
end
