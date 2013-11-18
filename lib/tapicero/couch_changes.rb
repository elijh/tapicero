require 'couchrest'
require 'fileutils'

module Tapicero
  class CouchChanges

    attr_accessor :db

    def initialize(db, seq_filename)
      @db = db
      @seq_filename = seq_filename
      read_seq(seq_filename)
    end

    def created(hash = {}, &block)
      if block_given?
        @created = block
      else
        @created && @created.call(hash)
      end
    end

    def deleted(hash = {}, &block)
      if block_given?
        @deleted = block
      else
        @deleted && @deleted.call(hash)
      end
    end

    def listen
      Tapicero.logger.info "listening..."
      Tapicero.logger.debug "Starting at sequence #{since}"
      db.changes :feed => :continuous, :since => since, :heartbeat => 1000 do |hash|
        callbacks(hash)
        store_seq(hash["seq"])
      end
    end

    protected

    def since
      @since ||= 0  # fetch_last_seq
    end

    def callbacks(hash)
      #changed callback
      return unless changes = hash["changes"]
      return deleted(hash) if hash["deleted"]
      created(hash) if changes[0]["rev"].start_with?('1-')
      #updated callback
    end

    def read_seq(seq_filename)
      Tapicero.logger.debug "Looking up sequence here: #{seq_filename}"
      FileUtils.touch(seq_filename)
      unless File.writable?(seq_filename)
        raise StandardError.new("Can't access sequence file")
      end
      @since = File.read(seq_filename).to_i
      Tapicero.logger.debug "Found sequence: #{@since}"
    rescue Errno::ENOENT => e
      Tapicero.logger.warn "No sequence file found. Starting from scratch"
    end

    def store_seq(seq)
      File.write(@seq_filename, seq)
    end

    #
    # UNUSED: this is useful for only following new sequences.
    #
    def fetch_last_seq
      hash = db.changes :limit => 1, :descending => true
      Tapicero.logger.info "starting at seq: " + hash["last_seq"]
      return hash["last_seq"]
    end

  end
end
