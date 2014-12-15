require_relative '../test_helper.rb'

class FailureTest < Tapicero::IntegrationTest

  def setup
  end

  def teardown
  end

  def test_couchdb_not_running_and_then_running_again
    TapiceroProcess.run_with_config('test/badconfig.yaml')
    create_user
    assert_raises RestClient::ResourceNotFound do
      user_database.info
    end
    TapiceroProcess.run_with_config('test/config.yaml')
    # it would be nice if we could signal tapicero to ask if it is idle.
    # instead, we wait.
    sleep 0.5
    assert_database_exists user_database
  end

end
