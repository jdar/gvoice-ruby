# -*- encoding: utf-8 -*-
$:.unshift "." # Ruby 1.9.2 does not include current directory in the path
require File.dirname(__FILE__) + "/test_helper"
require 'mocha'

class CompatibilityTest < Test::Unit::TestCase
  
  def setup
    @page_body = String.new(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'inbox_fixture.html')))
    @inbox_fixture = File.open(File.join(File.dirname(__FILE__), 'fixtures', 'inbox.yml')) { |yf| YAML::load(yf) }
    @page_obj = mock()
    @page_obj.stubs(:body_str).returns(@page_body)
  end
  
  should "add an instance method to Pathname" do
    assert Pathname.new("/blah").respond_to?(:ancestor)
  end
  
  should "return the appropriate ancestor path" do
    path = Pathname.new("/Users/foo/bar/baz/bat/quux")
    assert_equal(Pathname.new("/Users/foo/bar"), path.ancestor(3))
  end
  
  if RUBY_VERSION > '1.9'
    context "Using Ruby 1.9" do
      should "Provide correct format of the display_start_date_time method" do
        GvoiceRuby::Client.any_instance.stubs(:fetch_page).returns(true)
        parser = GvoiceRuby::InboxParser.new
        inbox = parser.parse_page(@page_obj)
        parser.parse_calls(inbox['messages'])
        assert_equal(parser.instance_variable_get(:@calls)[0].display_start_date_time, "2010-2-17 11:36 AM")
        assert_not_equal(parser.instance_variable_get(:@calls)[0].display_start_date_time, "2/17/2010 11:36 AM")
      end
    end
  else
    context "Using Ruby 1.8" do
      should "Provide correct format of the display_start_date_time method" do
        GvoiceRuby::Client.any_instance.stubs(:fetch_page).returns(true)
        parser = GvoiceRuby::InboxParser.new
        inbox = parser.parse_page(@page_obj)
        parser.parse_calls(inbox['messages'])
        assert_not_equal(parser.instance_variable_get(:@calls)[0].display_start_date_time, "2010-2-17 11:36 AM")
        assert_equal(parser.instance_variable_get(:@calls)[0].display_start_date_time, "2/17/10 11:36 AM")
      end
    end
  end
end