#
# This file should not be required directly. Use the wrapper in /bin
# instead or run this using daemons:
#
#  Daemons.run('tapicero_daemon.rb')
#
require 'tapicero'
require 'extends/couchrest'

module Tapicero
  module Daemon
    require 'tapicero/user_event_handler'
    users = CouchRest::Changes.new('users')
    UserEventHandler.new(users)
    users.listen

  end
end
