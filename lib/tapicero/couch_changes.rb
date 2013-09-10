module Tapicero
  class CouchChanges
    def initialize(stream)
      @stream = stream
    end

    def created(hash = {}, &block)
      if block_given?
        @created = block
      else
        @created && @created.call(hash)
      end
    end

    def last_seq
      @stream.get "_changes", :limit => 1, :descending => true do |hash|
        return hash[:last_seq]
      end
    end

    def listen
      @stream.get "_changes", :feed => :continuous, :since => last_seq do |hash|
        callbacks(hash)
      end
    end

    def callbacks(hash)
      #changed
      return if hash[:deleted]
      return unless changes = hash[:changes]
      return created(hash) if changes[0][:rev].start_with?('1-')
      #updated
    end
  end
end
