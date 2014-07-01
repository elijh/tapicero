require 'couchrest'
require 'json'

module Tapicero
  class Replication

    attr_reader :source, :target

    LocalEndpoint = Struct.new(:name) do
      def key; name; end
      def url; name; end
      def save_url; name; end
    end

    RemoteEndpoint = Struct.new(:remote, :credentials) do
      def key;        domain; end
      def url;       "http://#{creds}@#{domain}:#{port}/#{name}"; end
      def save_url;  "http://#{username}@#{domain}:#{port}/#{name}"; end
      def domain;    remote["domain_internal"]; end
      def port;      remote["couch_port"]; end
      def name;      remote["name"]; end
      def creds;     username + ':' + credentials["password"]; end
      def username;  credentials["username"]; end
    end

    def initialize(source, target)
      @source = endpoint_for(source)
      @target = endpoint_for(target)
    end

    def run(options)
      Tapicero.logger.info "Replicating from #{source.save_url} to #{target.save_url}."
      replication_db.save_doc replication_doc.merge(options)
    end

    def replication_doc
      {
        "_id"      => source.domain.gsub('.', '_'),
        "source"   => source.url,
        "target"   => target.url,
        "user_ctx" => {
          name: replication_credentials["username"],
          roles: [replication_credentials["role"]]
        }
      }
    end

    protected

    def endpoint_for(hash_or_string)
      hash_or_string.respond_to?(:keys) ?
        RemoteEndpoint.new(hash_or_string, replication_credentials) :
        LocalEndpoint.new(hash_or_string)
    end

    def replication_credentials
      config.options[:replication].select do |k,v|
        %w/username password role/.include? k
      end
    end

    def replication_db
      @replication_db ||= couch.database('_replicator')
    end

    def couch
      @couch ||= CouchRest.new(config.couch_host)
    end

    def config
      Tapicero.config
    end

  end
end
