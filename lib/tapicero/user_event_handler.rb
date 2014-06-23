require 'tapicero/user_database'
module Tapicero
  class UserEventHandler
    def initialize(users)
      users.created do |hash|
        prepare_db(hash['id'])
      end

      # Sometimes changes log starts with rev 2. So the
      # detection of is currently not working properly
      # Working around this until a new version of
      # couchrest changes takes this into account.
      users.updated do |hash|
        prepare_db(hash['id'])
      end

      users.deleted do |hash|
        destroy_db(hash['id'])
      end
    end

    protected

    def prepare_db(id)
      db = user_database(id)
      db.create
      db.secure
      db.add_design_docs
      db.replicate
      logger.info "Prepared storage " + db.name
    end

    def destroy_db(id)
      user_database(id).destroy
    end

    def logger
      Tapicero.logger
    end

    def user_database(id)
      UserDatabase.new(id)
    end
  end
end
