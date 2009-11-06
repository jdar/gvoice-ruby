# coding: UTF-8

$:.unshift(File.dirname(__FILE__))
require 'yaml'
require 'gvoice-ruby/client'
require 'gvoice-ruby/user'

module GvoiceRuby
PROJECT_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

  def self.load_config(config_file = File.join(PROJECT_ROOT, 'config', 'gvoice-ruby-config.yml'))
    # Load our config
    begin
      if File.exists?(config_file)
        config_hash = File.open(config_file) { |yf| YAML::load(yf) }
      else
        raise IOError
      end
    rescue IOError
      STDERR.puts "Failed to open file #{config_file}\nFile doesn't seem to exist. (#{$!})"
      raise
    end
    return config_hash
  end

  def self.write_config(config_hash, config_file = File.join(PROJECT_ROOT, 'config', 'gvoice-ruby-config.yml'))
    # Clean things up and put them away
    begin
      if File.exists?(config_file)
        File.open(config_file, 'w' ) do |out_file|
          YAML.dump(config_hash, out_file)
        end
      else
        raise IOError
      end
    rescue IOError
      STDERR.puts "#{config_file} doesn't exist: (#{$!})"
      raise
    end
  end
end