require File.expand_path('../../test_helper.rb', __FILE__)
require 'tapicero/couch_stream'

# we'll mock this
module Yajl
  class HttpStream
  end
end

class CouchStreamTest < MiniTest::Unit::TestCase

  def setup
    @root = "http://server/database"
    @stream = Tapicero::CouchStream.new(@root)
    @url = @root + "/_changes?a=b&c=d"
    @path = "_changes"
    @options = {:a => :b, :c => :d}
  end

  def test_get
    Yajl::HttpStream.expects(:get).
      with(@url, :symbolize_keys => true).
      yields(stub_hash = stub)
    @stream.get(@path, @options) do |hash|
      assert_equal stub_hash, hash
    end
  end

  # internal
  def test_url_creation
    assert_equal "http://server/database/", @stream.send(:url_for, "")
    assert_equal @url, @stream.send(:url_for, @path, @options)
  end

end
