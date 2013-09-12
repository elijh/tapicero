require 'couchrest'
require 'json'

module Tapicero
  class UserDatabase

    def initialize(host, name)
      @host = host
      @name = name
    end

    def create
      begin
        CouchRest.new(host).create_db(name)
      rescue RestClient::PreconditionFailed  # database already existed
      end
    end

    def secure(security)
      # let's not overwrite if we have a security doc already
      return if secured?
      puts security.to_json
      puts "-> #{security_url}"
      CouchRest.put security_url, security
    end

    protected

    def secured?
      CouchRest.get(security_url).keys.any?
    end

    def security_url
      "#{host}/#{name}/_security"
    end

    attr_reader :host, :name
  end
end
