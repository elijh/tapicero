module Tapicero
  class IntegrationTest < MiniTest::Unit::TestCase

    def create_user
      result = database.save_doc :some => :content
      raise RuntimeError.new(result.inspect) unless result['ok']
      @user_id = result['id']
    end

    def user_database
      host.database(config.options[:db_prefix] + @user_id)
    end

    def database
      @database ||= host.database(database_name)
    end

    def database_name
      config.complete_db_name('users')
    end

    def host
      @host ||= CouchRest.new(config.couch_host)
    end

    def config
      Tapicero.config
    end
  end
end
