Tapicero - Creating per user databases on the couch for soledad
------------------------------------------------------------

``tapicero`` is a daemon that creates per user databases when users are added to the LEAP Platform. It watches the changes made to the users database and creates new databases accordingly. This way soledad does not need admin privileges.

"Tapicero" is spanish for upholsterer - the person who creates your couch.

This program is written in Ruby and is distributed under the following license:

> GNU Affero General Public License
> Version 3.0 or higher
> http://www.gnu.org/licenses/agpl-3.0.html

Installation
---------------------

Prerequisites:

    sudo apt-get install ruby ruby-dev couchdb
    # for development, you will also need git, bundle, and rake.

From source:

    git clone git://leap.se/tapicero
    cd tapicero
    bundle
    rake build
    sudo rake install

From gem:

    sudo gem install tapicero

Running
--------------------

Run once:

    tapicero --run-once
    This will create per user databases for all users created since
    the last run.

Run in foreground to see if it works:

    tapicero run -- test/config/config.yaml
    browse to http://localhost:5984/_utils

How you would run normally in production mode:

    tapicero start
    tapicero stop

See ``tapicero --help`` for more options.


Configuration
---------------------

``tapicero`` reads the following configurations files, in this order:

* ``$(tapicero_source)/config/default.yaml``
* ``/etc/leap/tapicero.yaml``
* Any file passed to ARGV like so ``tapicero start -- /etc/tapicero.yaml``

For development on a couch with admin party you can probably leave all other options at their default values. For production you will need to set the credentials to an admin user so tapicero can create databases.

The default options are:

    # Database
    #
    users_db_name: "users"
    db_prefix: "user-"
    couch_connection:
      protocol: "http"
      host: "localhost"
      port: 5984
      username: ~
      password: ~
      prefix: ""
      suffix: ""

Rake Tasks
----------------------------

    rake -T
    rake build      # Build tapicero-x.x.x.gem into the pkg directory
    rake install    # Install tapicero-x.x.x.gem into either system-wide or user gems
    rake test       # Run tests
    rake uninstall  # Uninstall tapicero-x.x.x.gem from either system-wide or user gems

Development
--------------------

For development and debugging you might want to run the programm directly without
the deamon wrapper. You can do this like this:

    ruby -I lib lib/tapicero.rb

