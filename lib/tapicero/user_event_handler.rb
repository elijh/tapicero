require 'tapicero/user_database'
module Tapicero
  class UserEventHandler
    def initialize(users)
      users.created do |hash|
        logger.debug "Created user " + hash['id']
        user_database(hash['id']).prepare
      end

      # Sometimes changes log starts with rev 2. So the
      # detection of is currently not working properly
      # Working around this until a new version of
      # couchrest changes takes this into account.
      users.updated do |hash|
        logger.debug "Updated user " + hash['id']
        user_database(hash['id']).prepare
      end

      users.deleted do |hash|
        logger.debug "Deleted user " + hash['id']
        user_database(hash['id']).destroy
      end
    end

    def logger
      Tapicero.logger
    end

    def user_database(id)
      UserDatabase.new(id)
    end
  end
end
