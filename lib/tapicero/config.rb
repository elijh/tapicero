require 'yaml'

module Tapicero
  module Config
    extend self

    attr_accessor :users_db_name
    attr_accessor :db_prefix
    attr_accessor :couch_connection

    def self.load(base_dir, *configs)
      configs.each do |file_path|
        load_config find_file(base_dir, file_path)
      end
    end

    # TODO: enable username and password
    def couch_host
      couch_connection[:protocol] + '://' +
        couch_connection[:host] + ':' +
        couch_connection[:port] + '/'
    end

    private

    def load_config(file_path)
      return unless file_path
      puts " * Loading configuration #{file_path}"
      load_settings YAML.load(File.read(file_path))
    rescue NoMethodError => exc
      STDERR.puts "ERROR in file #{file_path}"
      exit(1)
    end

    def load_settings(hash)
      return unless hash
      hash.each do |key, value|
        apply_setting(key, value)
      end
    end

    def apply_setting(key, value)
      if value.is_a? Hash
        value = symbolize_keys(value)
      end
      self.send("#{key}=", value)
    rescue NoMethodError => exc
      STDERR.puts "'#{key}' is not a valid option"
      raise exc
    end

    def self.symbolize_keys(hsh)
      newhsh = {}
      hsh.keys.each do |key|
        newhsh[key.to_sym] = hsh[key]
      end
      newhsh
    end

    def self.find_file(base_dir, file_path)
      return nil unless file_path
      if defined? CWD
        return File.expand_path(file_path, CWD)  if File.exists?(File.expand_path(file_path, CWD))
      end
      return File.expand_path(file_path, base_dir) if File.exists?(File.expand_path(file_path, base_dir))
      return nil
    end
  end
end
