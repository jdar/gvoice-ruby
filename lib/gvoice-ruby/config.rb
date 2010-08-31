# -*- encoding: utf-8 -*-
# $:.unshift(File.dirname(__FILE__))

module GvoiceRuby
  class Configurator
    PROJECT_ROOT = File.expand_path(Pathname.new(__FILE__).ancestor(2))
  
    def self.load_config(config_file = File.join(PROJECT_ROOT, 'config', 'gvoice-ruby-config.yml'))
      # Load our config
      begin
        if File.exists?(config_file)
          config_hash = File.open(config_file) { |yf| YAML::load(yf) }
        else
          raise IOError
        end
      rescue IOError
        STDERR.puts "Failed to open file #{File.expand_path(config_file)} for reading. File doesn't seem to exist. (#{$!})"
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
        STDERR.puts "Failed to open #{File.expand_path(config_file)} for writing.  File doesn't seem to exist: (#{$!})"
        raise
      end
    end
  end
end