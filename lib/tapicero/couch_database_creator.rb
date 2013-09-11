require 'couchrest'
require 'json'

module Tapicero
  class CouchDatabaseCreator

    def initialize(host)
      @host = host
      @couch = CouchRest.new(host)
    end

    def create(name, security = {})
      db = @couch.create_db(name)
      puts security.to_json
      puts "-> #{@host}#{name}/_security"
      CouchRest.put "#{@host}#{name}/_security", security
    end
  end
end
