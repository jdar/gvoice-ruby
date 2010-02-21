# coding: utf-8

require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'gvoice-ruby'

class Test::Unit::TestCase
  
  def setup_config_fixture
    @config = GvoiceRuby::Configurator.load_config(File.join(File.dirname(__FILE__), 'fixtures', 'config_fixture.yml'))
  end
  
  def deny(*args)
    args.each { |arg| assert !arg }
  end
end