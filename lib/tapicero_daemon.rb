#
# This file should not be required directly. Use the wrapper in /bin
# instead or run this using daemons:
#
#  Daemons.run('tapicero_daemon.rb')
#

require 'tapicero'

module Tapicero
  users = CouchRest::Changes.new('users')

  users.created do |hash|
    logger.debug "Created user " + hash['id']
    db = user_database(hash['id'])
    db.create
    db.secure(config.options[:security])
    db.add_design_docs
  end

  users.deleted do |hash|
    logger.debug "Deleted user " + hash['id']
    db = user_database(hash['id'])
    db.destroy
  end

  users.listen
end
