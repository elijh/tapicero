module Tapicero
  class CouchChanges
    def initialize(stream)
      @stream = stream
    end

    def last_seq
      @stream.get "_changes", :limit => 1, :descending => true do |hash|
        return hash[:last_seq]
      end
    end

    def follow
      @stream.get "_changes", :feed => :continuous, :since => last_seq do |hash|
        yield(hash)
      end
    end
  end
end
