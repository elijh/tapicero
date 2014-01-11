require 'couchrest'
require 'json'

module Tapicero
  class UserDatabase

    def initialize(host, name)
      @host = host
      @name = name
    end

    def prepare(config)
      db.create
      db.secure(config.options[:security])
      db.add_design_docs
      logger.info "Prepared storage " + name
    end

    def create
      retry_request_once "Creating database" do
        create_db
      end
    end

    def secure(security)
      # let's not overwrite if we have a security doc already
      return if secured? && !Tapicero::FLAGS.include?('--overwrite-security')
      retry_request_once "Writing security to" do
        Tapicero.logger.debug security.to_json
        CouchRest.put security_url, security
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
      url = design_url(file.basename('.json'))
      CouchRest.put url, JSON.parse(file.read)
    rescue RestClient::Conflict
    end


    def destroy
      retry_request_once "Deleting database" do
        delete_db
      end
    end

    protected

    def create_db
      CouchRest.new(host).create_db(name)
    rescue RestClient::PreconditionFailed  # database already existed
    end

    def delete_db
      db = CouchRest.new(host).database(name)
      db.delete! if db
    rescue RestClient::ResourceNotFound  # no database found
    end

    def retry_request_once(action)
      second_try ||= false
      Tapicero.logger.debug "#{action} #{name}"
      yield
    rescue RestClient::Exception => exc
      if second_try
        log_error "#{action} #{name} failed twice due to:", exc
      else
        log_error "#{action} #{name} failed due to:", exc
        sleep 5
        second_try = true
        retry
      end
    end

    def log_error(message, exc)
      Tapicero.logger.warn message if message
      Tapicero.logger.warn exc.class.name + ': ' + exc.to_s
      Tapicero.logger.debug exc.backtrace.join("\n")
    end

    def secured?
      retry_request_once "Checking security of" do
        CouchRest.get(security_url).keys.any?
      end
    end

    def security_url
      "#{host}/#{name}/_security"
    end

    def design_url(doc_name)
      "#{host}/#{name}/_design/#{doc_name}"
    end

    attr_reader :host, :name
  end
end
