#
# This file should not be required directly. Use the wrapper in /bin
# instead or run this using daemons:
#
#  Daemons.run('tapicero_daemon.rb')
#

require 'tapicero'

module Tapicero
  puts    " * Tracking #{Config.users_db_name}"
  couch   = CouchStream.new(Config.couch_host + Config.users_db_name)
  changes = CouchChanges.new(couch)

  # fill the pool
  # pool.fill

  # watch for deletions, fill the pool whenever it gets low
  changes.follow do |hash|
    if hash[:created]
      puts " Created #{hash.inspect}"
      # pool.fill
    end
  end
end
