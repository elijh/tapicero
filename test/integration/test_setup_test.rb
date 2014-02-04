require_relative '../test_helper.rb'

class TestSetupTest < Tapicero::IntegrationTest

  def test_loads_config
    assert_equal "tapicero_test", config.connection[:prefix]
    assert_equal "debug", config.send(:log_level)
  end

  def test_database_exists
    assert database
    assert_equal "tapicero_test_users", database.name
  end

end
