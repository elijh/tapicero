require 'net/http'
require 'uri'
require 'yajl'

# UNUSED: We're currently using couchrest instead as that is what we use all
#         over the place. It internally uses curl to fetch the stream.
#
# Since Yajl HTTP Stream will go a way in version 2.0 here's a simple substitude.
#
module Tapicero
  class JsonStream

    def self.get(url, options, &block)
      uri = URI(url)
      parser = Yajl::Parser.new(options)
      parser.on_parse_complete = block
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri.request_uri


        http.request request do |response|
          response.read_body do |chunk|
            parser << chunk
          end
        end
      end

    end
  end
end

