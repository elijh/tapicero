#
# This file should not be required directly. Use the wrapper in /bin
# instead or run this using daemons:
#
#  Daemons.run('tapicero_daemon.rb')
#

require 'tapicero'

module Tapicero
  Tapicero.logger.info "Observing #{Config.couch_host_without_password}"
  Tapicero.logger.info "Tracking #{Config.users_db_name}"
  # stream   = CouchStream.new(Config.couch_host + '/' + Config.users_db_name)
  db = CouchRest.new(Config.couch_host).database(Config.users_db_name)
  users = CouchChanges.new(db, Config.seq_file)

  users.created do |hash|
    Tapicero.logger.debug "Created user " + hash['id']
    db = UserDatabase.new(Config.couch_host, Config.db_prefix + hash['id'])
    db.create
    db.secure(Config.security)
  end

  users.deleted do |hash|
    Tapicero.logger.debug "Deleted user " + hash['id']
    db = UserDatabase.new(Config.couch_host, Config.db_prefix + hash['id'])
    db.destroy
  end

  users.listen
end
