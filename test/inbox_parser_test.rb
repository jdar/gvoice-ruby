require File.dirname(__FILE__) + "/test_helper"

require "inbox_parser"
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
  
  should "parse the page" do
    GvoiceRuby::Client.any_instance.stubs(:fetch_page).returns(true)
    inbox = GvoiceRuby::InboxParser.new.parse_page(@page_obj)
    assert_equal(Hash, inbox.class)
    assert_equal(@inbox_fixture, inbox)
  end
end
