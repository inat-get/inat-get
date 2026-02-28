# 🌿 inat-get

[![GitHub License](https://img.shields.io/github/license/inat-get/inat-get)](LICENSE)
[![Gem Version](https://badge.fury.io/rb/inat-get.svg?icon=si%3Arubygems&d=1)](https://badge.fury.io/rb/inat-get)
[![Ruby](https://github.com/inat-get/inat-get/actions/workflows/ruby.yml/badge.svg)](https://github.com/inat-get/inat-get/actions/workflows/ruby.yml) 
![Coverage](coverage-badge.svg)

## What is this and why?

`inat-get` is a utility for fetching and analyzing data from **[iNaturalist](https://www.inaturalist.org/)**.

The basic approach is to form queries as *declaratively* as possible and get reports,
without giving up advanced capabilities. This leads us to the concept of **DSL** — Domain Specific Language —
and user scripts using it. It is assumed that the user will need a *minimal*
familiarity with Ruby syntax, but if desired, they can use the full power of the language.

The second crucial aspect is **caching**, designed to minimize duplication of
requested data without compromising freshness. For caching, a local database is used,
which potentially can be from a fairly wide range of supported DBMS: SQLite, PostgreSQL, MySQL
and others.

*However, it should be noted that version 0.9.0 was tested only on SQLite3, full testing
with various DBMS is planned for version 0.9.4...*

The third key point is **parallel execution** of multiple user scripts: first,
almost all computers are multi-core now, and second, while one is waiting for a response from the API, others can
calmly do processing. At the same time, the API requests themselves go through a single synchronous point to strictly
comply with the restrictions imposed by the iNaturalist API itself, and not get banned for incorrect use.

### What is not and will not be

+ *Authorization and data submission.* This is a tool for analysis, not for automating any actions
  with iNaturalist.

+ *Neural network integration.* Strict analytics and neural networks should not be mixed. Of course, integration
  "from the other side" is possible, i.e., fetching data and then using them with neural networks.

+ *Native versions for other systems.* Currently the script works only on Linux (though possibly under
  other unix-like systems, not checked). Native cross-platform support is not planned, but containerization
  is planned (though not soon), which will allow expanding usage.

## Current status and plans

+ **v0.8.x**

  Outdated versions. Due to poorly thought-out architecture, it works very slowly and caches very poorly.
  Can be used, but shouldn't be.

+ **[v0.9.0](https://github.com/inat-get/inat-get/milestone/4)** *(current development)*

  Architectural problems are solved, but because of them the project had to be rewritten almost from scratch, and a lot remains
  to be done.

  *This is more of a beta than an alpha, but a very early beta.*

  The main unfinished piece is the absence of a report formatting system. Below in the [Examples](#examples) section you can
  see how this is worked around... Besides, not all query types are implemented and caching is unfinished
  in terms of updating *old* data.

+ **[v0.9.2](https://github.com/inat-get/inat-get/milestone/5)**

  Planning to add ERB support for reports. It's not a huge step forward compared to
  direct file writing, but it will add some convenience.

+ **[v0.9.4](https://github.com/inat-get/inat-get/milestone/6)**

  Planning to conduct extensive load testing on different DBMS (at least SQLite and PostgreSQL),
  followed by corrections and optimizations.

  That is, version 0.9.4 is planned as a strictly corrective and optimizing release without adding new functionality.

+ **[v0.9.6](https://github.com/inat-get/inat-get/milestone/7)**

  Here the completion of work with queries is planned — implementation of missing ones, finalization of the caching system, etc.

+ **[v0.9.8](https://github.com/inat-get/inat-get/milestone/8)**

  This version is planned for the development and debugging of a general reporting system. It's not yet entirely clear what exactly
  it will be, the task is in `research` status...

+ **[v1.0](https://github.com/inat-get/inat-get/milestone/9)** <u>(release)</u>

  Basically, everything above, refactored and polished. Of the serious changes visible to the user,
  only *containerization* and, through it, cross-platform support is planned.

+ **[v1.2](https://github.com/inat-get/inat-get/milestone/10)** 

  Plans are not yet fully formed and will change. In versions after 1.0, advanced
  capabilities are planned to be added, the exact composition of which will become clearer in the process of real usage.

+ **v2.0**

  Very uncertain future, by that time the iNaturalist API will likely have changed, and completely
  new needs will have appeared...

## Installation and usage

### Installation

The project is packaged as a Ruby Gem, so it is installed accordingly:
```shell
$ gem install inat-get
```

However, if you want to use the current version "from sources", you can simply clone the repository
and run `bundle install`:
```shell
$ git clone https://github.com/inat-get/inat-get.git
$ cd inat-get
$ bundle install
```

And then run via `bundle exec`:
```shell
$ bundle exec inat-get [options] ‹task› [‹task› ...]
```

### Command line parameters

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

### DSL

So, in scripts you can (and should) use specially prepared DSL methods and objects
responsible for data.

First of all, these are **models**, documentation for which can be found at
<https://inat-get.github.io/inat-get/INatGet/Data/Model.html>. In general, these are simply data
objects linked to each other. The key ones are probably:
[`Observation`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Observation.html),
[`Taxon`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Taxon.html),
[`Project`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Project.html),
[`Place`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Place.html)
and [`User`](https://inat-get.github.io/inat-get/INatGet/Data/Model/User.html).

The main work is built on the arithmetic of **datasets** and **lists**. Datasets are data
selections, manipulations with which happen without real access to the API and DB until
it becomes necessary. Lists are datasets split by some key field.
Documentation is at <https://inat-get.github.io/inat-get/INatGet/Data/DSL/Dataset.html>
for `Dataset` and <https://inat-get.github.io/inat-get/INatGet/Data/DSL/List.html> for `List`.
Both classes implement the `Enumerable` module, each in its own way...

At the beginning of each script we make observation selections (usually) via the `select_observations` method.
In general, `select_*` and `get_*` methods for different object types are described in the DSL module documentation —
<https://inat-get.github.io/inat-get/INatGet/Data/DSL.html>. In user scripts this
module is initially included in the context, so its methods are available directly.

*Unfortunately, the fields of selections are not yet documented.* Will be soon.

Below are simple examples of user scripts. It is recommended to pay attention
to "arithmetic" operations: `+`, `-`, `*` and `%`. The last one performs splitting and turns
a dataset into a list.

## Examples

### Simple report for a user — [user_stat.rb](share/inat-get/demo/01_user_stat.rb)

```ruby
# Let's make a simple report on taxa observed by the user since the beginning of the year.
# The report will be output to the current directory with the name user_stat.md (Markdown format)

year = today.year

user = get_user 'shikhalev'      # Here specify the user ID or login, I specified my own

# Get observations
observations = select_observations user: user, observed: time_range(year: year), quality_grade: 'research'

by_taxon = observations % :taxon

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Report for user ' + user.login + (user.name ? " (#{ user.name })" : '')
  file.puts ''
  by_taxon.each do |ds|
    # Here ds.key is a Taxon object
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } obs."
  end
  file.puts ''
  file.puts "Total **#{ observations.count }** observations"
end
```

### Demonstration of list subtraction — [underbound.rb](share/inat-get/demo/02_underfound.rb)

```ruby
# And here we implement the following: for a certain area, find a list of taxa
#  that the given user has not observed (but others have).

user = get_user 'shikhalev'
place = get_place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

all_observations = select_observations place: place, quality_grade: 'research', rank: (.. Rank.complex)
full_list = all_observations % :taxon

user_observations = select_observations place: place, quality_grade: "research", rank: (.. Rank.complex), user: user
user_list = user_observations % :taxon

others_list = full_list - user_list
others_list.sort! { |ds| -ds.count }

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Not found by you'
  file.puts ''
  others_list.each do |ds|
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } obs."
  end
  file.puts ''
  file.puts "Total **#{ others_list.count }** taxa."
end
```

### List filtering and date range — [newcomers.rb](share/inat-get/demo/03_newcomers.rb)

```ruby
# Newcomers of the previous month. As simple as possible: those who made an observation during
#  the previous month, and registered in it as well. Naturally, within some
#  project, so as not to pull too much.

project = get_project 'bioraznoobrazie-rayonov-sverdlovskoy-oblasti'

month = today.month - 1
year = if month == 0
  month = 12
  today.year - 1
else
  today.year
end

period = time_range year: year, month: month
observations = select_observations project: project, created: period

list = observations % :user
list.filter! { |ds| period === ds.key.created }
list.sort! { |ds| ds.key.created }

File.open "#{ name }.md", 'w' do |file|
  file.puts "\#\# Newcomers of project «#{ project.title }»"
  file.puts "*#{ period.begin.to_date } — #{ period.end.to_date - 1 }*"
  file.puts ''
  list.each do |ds|
    file.puts "+ #{ ds.key.login } (#{ ds.key.created.to_date }) — #{ ds.count } obs."
  end
  file.puts ''
  file.puts "Total #{ list.count } users"
end
```
