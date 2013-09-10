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
  couch   = CouchStream.new(Config.couch_host + Config.users_db_name)
  users = CouchChanges.new(couch)
  users.created do |hash|
    puts "Created user " + hash[:id]
  end

  users.listen
end
