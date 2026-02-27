# inat-get

## Что это и зачем?

`inat-get` — это утилита для получения и анализа данных с **[iNaturalist](https://www.inaturalist.org/)**.

Базовый подход заключается в том, чтобы максимально декларативно формировать запросы и получать очеты,
не отказываясь при этом от расширенных возможностей. Что приводит нас к понятию DSL — Domain Specific Language —
и пользовательским скриптам с его использованием.

Второй важнейший аспект — это кэширование, задуманное таким образом, чтобы минимизировать дублирование
запрашиваемых данных не в ущерб актуальности. Для кэширования используется локальная база данных, 
которая потенциально может быть из довольно широкого набора поддерживаемых СУБД: SQLite, PostgreSQL, MySQL 
и не только.

*Впрочем, нужно сделать оговорку, что верия 0.9.0 тестировалась только на SQLite3, полноценное тестирование
с различными СУБД запланировано только на версию 0.9.4...*

Третий ключевой момент — это параллельный запуск нескольких пользовательских скриптов

## Командная строка

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

## Примеры

### Простой отчет для пользователя — [user_stat.rb](share/inat-get/demo/01_user_stat.rb)

```ruby
# Сформируем простой отчет по таксонам, которые наблюдал пользователь с начала года.
# Отчет будет выведен в текущий каталог с именем user_stat.md (формат Markdown)

year = today.year

usr = user 'shikhalev'      # Здесь указываем ID или логин пользователя, я указал свой

# Получаем наблюдения
obs = observations user: usr, observed: range(year: year), quality_grade: 'research'

by_taxon = obs % :taxon

File::open 'user_stat.md', 'w' do |file|
  file.puts '## Отчет для пользователя ' + usr.login + (usr.name ? " (#{ usr.name })" : '')
  file.puts ''
  by_taxon.each do |ds|
    # Здесь ds.key — это объект Taxon
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ obs.count }** наблюдений"
end
```

### Демонстрация вычитания списков — [underbound.rb](share/inat-get/demo/02_underfound.rb)

```ruby
# А здесь мы реализуем следуеющее: по некоторому району найдем список таксонов,
#  которых данный пользователь не наблюдал (а другие наблюдали).

usr = user 'shikhalev'
plc = place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

obs_full = observations place: plc, quality_grade: 'research', rank: (.. Rank.complex)
lst_full = obs_full % :taxon

obs_user = observations place: plc, quality_grade: "research", rank: (.. Rank.complex), user: usr
lst_user = obs_user % :taxon

lst_other = lst_full - lst_user
lst_other.sort! { |ds| -ds.count }

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Недонайденные'
  file.puts ''
  lst_other.each do |ds|
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ lst_other.count }** таксонов."
end
```

### Фильтрация списка и диапазон дат — [newcomers.rb](share/inat-get/demo/03_newcomers.rb)

```ruby
# Новички предыдущего месяца. Максимально просто: те, кто сделал наблюдение в течение
#  предыдущего месяца, и зарегистрировался в нем же. Естестаенно, в рамках некоторого
#  проекта, чтобы не тащить слишком много.

prj = project 'bioraznoobrazie-rayonov-sverdlovskoy-oblasti'

month = today.month - 1
year = if month == 0
  month = 12
  today.year - 1
else
  today.year
end

period = range(year: year, month: month)
obs = observations project: prj, created: period

lst = obs % :user
lst.filter! { |ds| period === ds.key.created }
lst.sort! { |ds| ds.key.created }

File.open "#{ name }.md", 'w' do |file|
  file.puts "\#\# Новички проекта «#{ prj.title }»"
  file.puts "*#{ period.begin.to_date } — #{ period.end.to_date - 1 }*"
  file.puts ''
  lst.each do |ds|
    file.puts "+ #{ ds.key.login } (#{ ds.key.created.to_date }) — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего #{ lst.count } пользователей"
end
```
