require_relative '../test_helper.rb'

class TapiceroTest < Tapicero::IntegrationTest

  def test_creates_user_db
    create_user
    sleep 1
    assert user_database
    assert user_database.name.start_with?(config.options[:db_prefix])
    assert user_database.info
  end

  def test_configures_security
    create_user
    sleep 1
    assert_equal config.options[:security], user_database.get('_security')
  end

  def test_stores_design_docs
    create_user
    sleep 1
    assert_equal ['_design/docs', '_design/syncs', '_design/transactions'],
      design_docs(user_database).map{|doc| doc["id"]}.sort
  end

  def design_docs(db)
    db.documents(startkey: '_design', endkey: '_design'.succ)["rows"]
  end
end
