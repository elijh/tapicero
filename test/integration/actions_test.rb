require_relative '../test_helper.rb'

class ActionsTest < Tapicero::IntegrationTest

  def setup
    TapiceroProcess.run_with_config("test/config.yaml")
    create_user
    sleep 0.1
  end

  def teardown
    delete_user(true)
  end

  def test_creates_user_db
    assert_database_exists user_database
    assert user_database.name.start_with?(config.options[:db_prefix])
  end

  def test_configures_security
    assert_equal config.options[:security], user_database.get('_security')
  end

  def test_stores_design_docs
    assert_equal ['_design/docs', '_design/syncs', '_design/transactions'],
      design_docs(user_database).map{|doc| doc["id"]}.sort
  end

  def test_deletes_user_db
    assert_database_exists user_database
    delete_user
    assert !host.databases.include?(user_database.name), 'user db must not exist'
  end

  def design_docs(db)
    db.documents(startkey: '_design', endkey: '_design'.succ)["rows"]
  end
end
