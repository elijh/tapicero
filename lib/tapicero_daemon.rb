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
    user_database(hash['id']).prepare(config)
  end

  # Sometimes changes log starts with rev 2. So the
  # detection of is currently not working properly
  # Working around this until a new version of
  # couchrest changes takes this into account.
  users.updated do |hash|
    logger.debug "Updated user " + hash['id']
    user_database(hash['id']).prepare(config)
  end

  users.deleted do |hash|
    logger.debug "Deleted user " + hash['id']
    user_database(hash['id']).destroy
  end

  users.listen
end
