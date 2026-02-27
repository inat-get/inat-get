# inet-get

[![GitHub License](https://img.shields.io/github/license/inat-get/inat-get)](LICENSE)
[![Gem Version](https://badge.fury.io/rb/inat-get.svg?icon=si%3Arubygems&d=1)](https://badge.fury.io/rb/inat-get)
[![Ruby](https://github.com/inat-get/inat-get/actions/workflows/ruby.yml/badge.svg)](https://github.com/inat-get/inat-get/actions/workflows/ruby.yml) 
![Coverage](coverage-badge.svg)

## Usage

<pre><b>$</b> bundle exec inat-get --help
🌿 <b>iNatGet v0.9.0:</b> iNaturalist API query builder and analytics tool
          License: <b>GNU GPLv3+</b> (https://github.com/inat-get/inat-get/blob/main/LICENSE)
           Author: <b>Ivan Shikhalev</b> (https://github.com/shikhalev)
         Homepage: <b>https://github.com/inat-get/inat-get</b>

   <b>Usage:</b> inat-get [options] ‹task› [‹task› ...]

   <b>Info Options:</b>
    -h, --help                       Show this help and exit.
        --version                    Show version and exit.
    -i, --info                       Show information about DB status and API connection. 
                                       Then exit.
        --show-config                Show current configuration and exit.

   <b>Main Options:</b>
    -c, --config FILE                Use this file as config (must be YAML) 
                                       [default: ~/.config/inat-get.yml].
    -l, --log-level LEVEL            Log level (fatal, error, warn, info or debug) 
                                       [default: warn].
        --debug                      Set log level to debug.
    -o, --offline                    Offline mode: no updates, use local database only.
    -O, --online                     Online mode [default], use this flag to cancel 
                                       'offline: true' in config.

   <b>DB Maintenance:</b>
    -C, --db-check                   Check DB version and exit.
    -U, --db-update                  Migrate to latest DB version and exit.
    -M, --db-migrate VER             Migrate to DB version VER and exit.
        --db-create                  Create database (error if exists).
        --db-reset                   Drop (if exists) and recreate database. All fetched 
                                       data will be lost.

   <b>File Arguments:</b>
        ‹task› [‹task› ...]          One or more names of task files or list files with '@' 
                                      prefix (one task file per line). If task name has not 
                                      extension try to read '‹task›' than '‹task›.inat' than 
                                      '‹task›.rb'.
</pre>