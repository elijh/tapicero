require File.expand_path('../../test_helper.rb', __FILE__)

class TapiceroTest < MiniTest::Unit::TestCase

  def test_loads_config
    assert_equal "tapicero_test", config.connection[:prefix]
    assert_equal "debug", config.send(:log_level)
  end

  def test_database_exists
    assert database
    assert_equal "tapicero_test_users", database.name
  end

  def test_creates_user_db_fast
    user_id = create_user['id']
    database.save_doc :id => user_id
    assert user_database(user_id)
  end

  def test_creates_user_db_slow
    user_id = create_user['id']
    sleep 1
    assert user_database(user_id)
  end

  def test_configures_security
    user_id = create_user['id']
    sleep 1
    assert_equal config.options[:security], user_database(user_id).get('_security')
  end

  def create_user
    database.save_doc :some => :content
  end

  def user_database(name)
    host.database(config.options[:db_prefix] + name)
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
