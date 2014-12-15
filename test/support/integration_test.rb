module Tapicero
  class IntegrationTest < MiniTest::Test

    #
    # create a dummy record for the user
    # so that tapicero will get a new user event
    #
    def create_user(fast = false)
      result = database.save_doc :some => :content
      raise RuntimeError.new(result.inspect) unless result['ok']
      sleep 1 unless fast # allow tapicero to do its job
      @user = {'_id' => result["id"], '_rev' => result["rev"]}
    end

    def delete_user(fast = false)
      return if @user.nil? or @user['_deleted']
      result = database.delete_doc @user
      raise RuntimeError.new(result.inspect) unless result['ok']
      @user['_deleted'] = true
      sleep 1 unless fast # allow tapicero to do its job
    end

    def user_database
      host.database(config.options[:db_prefix] + @user['_id'])
    rescue RestClient::ResourceNotFound
      puts 'failed to find per user db'
    end

    def database
      @database ||= host.database!(database_name)
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

    def assert_database_exists(db)
      db.info
    rescue RestClient::ResourceNotFound
      assert false, "Database #{db} should exist."
    end

  end
end
