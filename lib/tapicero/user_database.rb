require 'couchrest'
require 'json'

module Tapicero
  class UserDatabase

    def initialize(host, name)
      @host = host
      @name = name
    end

    def create
      retry_request_once "Creating database" do
        create_db
      end
    end

    def secure(security)
      # let's not overwrite if we have a security doc already
      return if secured? && !Tapicero::FLAGS.include?('--overwrite-security')
      Tapicero.logger.info "Writing Security to #{security_url}"
      Tapicero.logger.debug security.to_json
      retry_request_once "Writing security" do
        CouchRest.put security_url, security
      end
    end

    def add_design_docs
      pattern = BASE_DIR + 'designs' + '*.json'
      Tapicero.logger.debug "looking for design docs in #{pattern}"
      Pathname.glob(pattern).each do |file|
        retry_request_once "Uploading design doc" do
          upload_design_doc(file)
        end
      end
    end

    def upload_design_doc(file)
      url = design_url(file.basename('.json'))
      CouchRest.put url, JSON.parse(file.read)
      Tapicero.logger.debug "uploaded design doc #{file.basename} to #{url}"
    rescue RestClient::Conflict
    end


    def destroy
      retry_request_once "Deleting Database" do
        delete_db
      end
    end

    protected

    def create_db
      CouchRest.new(host).create_db(name)
      Tapicero.logger.debug "database created successfully."
    rescue RestClient::PreconditionFailed  # database already existed
    end

    def delete_db
      db = CouchRest.new(host).database(name)
      db.delete! if db
      Tapicero.logger.debug "database deleted successfully."
    rescue RestClient::ResourceNotFound  # no database found
    end

    def retry_request_once(action)
      second_try ||= false
      yield
    rescue RestClient::Exception => e
      if second_try
        log_error action + " failed twice due to:", e
      else
        log_error action + " failed due to:", e
        second_try = true
        retry
      end
    end

    def log_error(message, e)
      Tapicero.logger.warn message if message
      Tapicero.logger.warn e.to_s
      Tapicero.logger.debug e.backtrace
    end

    def secured?
      retry_request_once "Checking security" do
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
