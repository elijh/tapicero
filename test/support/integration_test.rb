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

    def assert_tapicero_running
      return if $tapicero_running
      pid_file = '/tmp/tapicero.pid'
      unless File.exists?(pid_file)
        puts 'Tapicero must be running. Run `bin/tapicero run -- test/config.yaml`'
        exit(1)
      end
      pid = File.read(pid_file).strip
      if pid !~ /^\d+/
        puts "Bad #{pid_file}: Remove the file and try again.";
        exit(1)
      else
        pid = pid.to_i
      end
      begin
        Process.kill(0, pid)
        puts "OK, tapicero is running with process id #{pid}."
        $tapicero_running = true
      rescue Errno::EPERM
        puts "Failed to test tapicero pid: No permission to query #{pid}!"
        exit(1)
      rescue Errno::ESRCH
        puts "Bad #{pid_file}: #{pid} is NOT running. Remove the file and try again.";
        exit(1)
      rescue
        puts "Unable to determine status for tapicero process #{pid} : #{$!}"
        exit(1)
      end
    end

  end
end
