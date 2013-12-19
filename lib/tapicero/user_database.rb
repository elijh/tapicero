require 'couchrest'
require 'json'

module Tapicero
  class UserDatabase

    def initialize(host, name)
      @host = host
      @name = name
    end

    def create
      CouchRest.new(host).create_db(name)
      Tapicero.logger.debug "database created successfully."
    rescue RestClient::PreconditionFailed  # database already existed
    end

    def secure(security)
      # let's not overwrite if we have a security doc already
      return if secured?
      Tapicero.logger.info "Writing Security to #{security_url}"
      Tapicero.logger.debug security.to_json
      CouchRest.put security_url, security
    end

    def add_design_docs
      pattern = BASE_DIR + 'designs' + '*.json'
      Tapicero.logger.debug "looking for design docs in #{pattern}"
      Pathname.glob(pattern).each do |file|
        upload_design_doc(file)
      end
    end

    def upload_design_doc(file)
      url = design_url(file.basename)
      Tapicero.logger.debug "uploading design doc #{file.basename} to #{url}"
      CouchRest.put url, JSON.parse(file.read)
    end


    def destroy
      db = CouchRest.new(host).database(name)
      db.delete! if db
      Tapicero.logger.debug "database deleted successfully."
    rescue RestClient::ResourceNotFound  # no database found
    end

    protected

    def secured?
      CouchRest.get(security_url).keys.any?
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
