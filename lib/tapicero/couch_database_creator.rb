require 'couchrest'

module Tapicero
  class CouchDatabaseCreator

    def initialize(host)
      @couch = CouchRest.new(host)
    end

    def create(name)
      @couch.database(name).create!
    end
  end
end
