# -*- encoding: utf-8 -*-
require 'test/unit'
begin
  require 'shoulda'
rescue LoadError
  warn "\nYou need to run 'bundle exec rake test' in order to avoid load errors.\n"
end

require 'gvoice-ruby'

class Test::Unit::TestCase
  
  # def config_file
  #   File.join(File.dirname(__FILE__), 'fixtures', 'config_fixture.yml')
  # end unless method_defined?(:config_file)
  
  def deny(*args)
    args.each { |arg| assert !arg }
  end
end