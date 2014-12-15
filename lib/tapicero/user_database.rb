require 'couchrest'
require 'json'
require 'tapicero/replication'

module Tapicero
  class UserDatabase

    def initialize(user_id)
      @db = couch.database(config.options[:db_prefix] + user_id)
    end

    #
    # Create the user db, and keep trying until successful.
    #
    def create
      retry_until "creating database", method(:exists?) do
        begin
          couch.create_db(db.name)
        rescue RestClient::PreconditionFailed
          # silently eat preconditionfailed, since it might be bogus.
          # we will keep trying until db actually exists.
        end
      end
    end

    #
    # upload security document
    #
    def secure(security = nil)
      security ||= config.options[:security]
      # let's not overwrite if we have a security doc already
      return if secured? && !Tapicero::FLAGS.include?('--overwrite-security')
      retry_request_once "Writing security to" do
        ignore_conflicts do
          Tapicero.logger.debug security.to_json
          CouchRest.put security_url, security
        end
      end
    end

    def replicate()
      return unless config.options[:mode] == 'mirror'
      replication = config.options[:replication]
      replication["masters"].each do |key, node|
        node["name"] = name
        retry_request_once "Replicating" do
          Tapicero::Replication.new(node, name).run continuous: true
        end
      end
    end

    def add_design_docs
      pattern = BASE_DIR + 'designs' + '*.json'
      Tapicero.logger.debug "Looking for design docs in #{pattern}"
      Pathname.glob(pattern).each do |file|
        retry_request_once "Uploading design doc to" do
          upload_design_doc(file)
        end
      end
    end

    def upload_design_doc(file)
      old = CouchRest.get design_url(file.basename('.json'))
    rescue RestClient::ResourceNotFound
      ignore_conflicts do
        CouchRest.put design_url(file.basename('.json')), JSON.parse(file.read)
      end
    end

    def destroy
      retry_request_once "Deleting database" do
        ignore_not_found do
          db.delete! if db
        end
      end
    end

    def name
      db.name
    end

    private

    #
    # If at first you don't succeed, try one more time.
    #
    def retry_request_once(action)
      second_try ||= false
      Tapicero.logger.debug "#{action} #{db.name}"
      yield
    rescue RestClient::Exception => exc
      raise exc if Tapicero::RERAISE
      if second_try
        log_error "#{action} #{db.name} failed twice due to: ", exc
      else
        log_info "#{action} #{db.name} failed (trying again soon): ", exc
        sleep 5
        second_try = true
        retry
      end
    end

    #
    # most of the time, we can safely ignore conflicts. It just
    # means that another tapicero daemon beat us to the punch.
    #
    def ignore_conflicts
      yield
    rescue RestClient::Conflict => exc
      raise exc if Tapicero::RERAISE
    end

    def ignore_not_found
      yield
    rescue RestClient::ResourceNotFound
    end

    #
    # captures and logs any uncaught rest client Exceptions
    #
    def log_rest_client_errors(msg)
      yield
    rescue RestClient::Exception => exc
      raise exc if Tapicero::RERAISE
      log_error "#{msg} #{db.name} failed due to: ", exc
    end

    #
    # keeps trying block until method returns true.
    # gives up after 100 tries
    #
    def retry_until(msg, method)
      tries = 0
      while(true)
        tries += 1
        if tries > 100
          Tapicero.logger.error "Gave up: #{msg}"
          break
        else
          log_rest_client_errors msg do
            yield
          end
        end
        if method.call()
          break
        else
          sleep 1
        end
      end
    end

    def log_error(message, exc)
      # warn message is a one liner so nagios can parse it
      Tapicero.logger.warn message.to_s + exc.class.name + ': ' + exc.to_s
      Tapicero.logger.debug exc.backtrace.join("\n")
    end

    def log_info(message, exc)
      Tapicero.logger.info message.to_s + exc.class.name + ': ' + exc.to_s
    end

    def secured?
      retry_request_once "Checking security of" do
        CouchRest.get(security_url).keys.any?
      end
    end

    def exists?
      db.info
      return true
    rescue RestClient::ResourceNotFound
      return false
    end

    def security_url
      db.root + "/_security"
    end

    def design_url(doc_name)
      db.root + "/_design/#{doc_name}"
    end

    attr_reader :db

    def couch
      @couch ||= CouchRest.new(config.couch_host)
    end

    def config
      Tapicero.config
    end

  end
end
