# inet-get

## Usage


<pre>$ bundle exec inat-get --help
🌿 <b>iNatGet v0.9.0:</b> iNaturalist API query builder and analytics tool
          License: GNU GPLv3+ (https://github.com/inat-get/inat-get/blob/main/LICENSE)
           Author: Ivan Shikhalev (https://github.com/shikhalev)
         Homepage: https://github.com/inat-get/inat-get

   Usage: inat-get [options] ‹task› [‹task› ...]

   Info Options:
    -h, --help                       Show this help and exit.
        --version                    Show version and exit.
    -i, --info                       Show information about DB status and API connection. Then exit.
        --show-config                Show current configuration and exit.

   Main Options:
    -c, --config FILE                Use this file as config (must be YAML) [default: ~/.config/inat-get.yml].
    -l, --log-level LEVEL            Log level (fatal, error, warn, info or debug) [default: warn].
        --debug                      Set log level to debug.
    -o, --offline                    Offline mode: no updates, use local database only.
    -O, --online                     Online mode [default], use this flag to cancel 'offline: true' in config.

   DB Maintenance:
    -C, --db-check                   Check DB version and exit.
    -U, --db-update                  Migrate to latest DB version and exit.
    -M, --db-migrate VER             Migrate to DB version VER and exit.
        --db-create                  Create database (error if exists).
        --db-reset                   Drop (if exists) and recreate database. All fetched data will be lost.

   File Arguments:
        ‹task› [‹task› ...]          One or more names of task files or list files with '@' prefix (one task file per line).
                                     If task name has not extension try to read '‹task›' than '‹task›.inat' than '‹task›.rb'.
</pre>