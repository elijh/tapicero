#
# UNUSED: we currently use CouchRest's streamer instead. Still keeping this
#         around because it's a simple alternative that works.
#

module Tapicero
  class CouchStream
    def initialize(database_url)
      @database_url = database_url
    end

    def get(path, options)
      url = url_for(path, options)
      # puts url
      Tapicero::JsonStream.get(url, :symbolize_keys => true) do |hash|
        yield(hash)
      end
    end

    protected

    def url_for(path, options = {})
      url = [@database_url, path].join('/')
      url += '?' if options.any?
      url += options.map {|k,v| "#{k}=#{v}"}.join('&')
    end
  end
end
