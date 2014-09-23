#
# This file should not be required directly. Use the wrapper in /bin
# instead or run this using daemons:
#
#  Daemons.run('tapicero_daemon.rb')
#
require 'tapicero'
require 'extends/couchrest'
require 'tapicero/user_event_handler'

module Tapicero
  module Daemon
    while true
      users = CouchRest::Changes.new('users')
      UserEventHandler.new(users)
      users.listen
      Tapicero.logger.info('Lost contact with couchdb, will try again in 10 seconds')
      sleep 10
    end
  end
end
