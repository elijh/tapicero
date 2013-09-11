#
# This file should not be required directly. Use the wrapper in /bin
# instead or run this using daemons:
#
#  Daemons.run('tapicero_daemon.rb')
#

require 'tapicero'

module Tapicero
  puts    " * Observing #{Config.couch_host}"
  puts    " * Tracking #{Config.users_db_name}"
  stream   = CouchStream.new(Config.couch_host + Config.users_db_name)
  users = CouchChanges.new(stream)
  creator = CouchDatabaseCreator.new(Config.couch_host)
  users.created do |hash|
    puts "Created user " + hash[:id]
    creator.create(Config.db_prefix + hash[:id], Config.security)
  end

  users.listen
end
