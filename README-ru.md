# 🌿 inat-get

[![GitHub License](https://img.shields.io/github/license/inat-get/inat-get)](LICENSE)
[![Gem Version](https://badge.fury.io/rb/inat-get.svg?icon=si%3Arubygems&d=1)](https://badge.fury.io/rb/inat-get)
[![Ruby](https://github.com/inat-get/inat-get/actions/workflows/ruby.yml/badge.svg)](https://github.com/inat-get/inat-get/actions/workflows/ruby.yml) 
![Coverage](coverage-badge.svg)

## Что это и зачем?

`inat-get` — это утилита для получения и анализа данных с **[iNaturalist](https://www.inaturalist.org/)**.

Базовый подход заключается в том, чтобы максимально *декларативно* формировать запросы и получать очеты,
не отказываясь при этом от расширенных возможностей. Что приводит нас к понятию [**DSL** — Domain Specific Language](DSL-ru.md) —
и пользовательским скриптам с его использованием. Предполагается, что от пользователя потребуется *минимальное*
знакомство с синтаксисом Ruby, но при желании он сможет использовать и всю мощь языка.

Второй важнейший аспект — это **кэширование**, задуманное таким образом, чтобы минимизировать дублирование
запрашиваемых данных не в ущерб актуальности. Для кэширования используется локальная база данных, 
которая потенциально может быть из довольно широкого набора поддерживаемых СУБД: SQLite, PostgreSQL, MySQL 
и не только.

*Впрочем, нужно сделать оговорку, что верия 0.9.0 тестировалась только на SQLite3, полноценное тестирование
с различными СУБД запланировано на версию 0.9.4...*

Третий ключевой момент — это **параллельный запуск** нескольких пользовательских скриптов: во-первых, сейчас 
практически все компьютеры многоядерные, а во-вторых, пока один ждет ответа от API, другие могут спокойно
заниматься обработкой. При этом сами запросы к API проходят через одну синхронную точку, чтобы строго
соблюдать ограничения, налагаемые самим API iNaturalist, и не быть забаненным за некорректное использование.

### Чего нет и не будет

+ *Авторизации и отправки данных.* Это инструмент для анализа, а не для автоматизации каких-то действий
  с iNaturalist.

+ *Интеграции с нейросетями.* Не нужно смешивать строгую аналитику и нейросети. Разумеется, возможна 
  интеграция «с той стороны», т.е. получение данных и использование их затем нейросетями.

+ *Нативной версии под другие системы.* Сейчас скрипт работает только на Linux (впрочем, возможно, и под 
  другими unix-like системами, не проверял). Нативной кроссплатформенности не предполагается, но планируется
  (хоть и не скоро) контейнеризация, что позволит расширить использование.

## Текущий статус и планы

+ **v0.8.x**

  Устаревшие версии. В силу недопродуманной архитектуры работает очень медленно и очень плохо кэширует.
  Использовать можно, но не стоит.

+ **[v0.9.0](https://github.com/inat-get/inat-get/milestone/4)** *(текущая разработка)*

  Архитектурные проблемы решены, но из-за них пришлось переписать проект практически с нуля, и очень многое еще
  предстоит доделать.

  *Это скорее бета-версия, чем альфа, но очень ранняя бета.*

  Главная недоделка — это отсутствие системы форматирования отчетов. Ниже в разделе [Примеры](#примеры) можно
  посмотреть, как это обходится... Кроме того, реализованы не все виды запросов и недоделано кэширование
  в части актуализации *старых* данных.

+ **[v0.9.2](https://github.com/inat-get/inat-get/milestone/5)**

  Планируется добавить поддержку ERB для отчетов. Нельзя сказать, что это будет большим шагом вперед по сравнению
  с прямой записью в файл, но все же некоторого удобства добавит.

+ **[v0.9.4](https://github.com/inat-get/inat-get/milestone/6)**

  Планируется провести большое нагрузочное тестирование на разных СУБД (как минимум, SQLite и PostgreSQL),
  по итогам которого внестии исправления и оптимизации.

  То есть, версия 0.9.4 запланирована как строго корректирующий и оптимизирующий выпуск без добавления новой функциональности.

+ **[v0.9.6](https://github.com/inat-get/inat-get/milestone/7)**

  Здесь планируется завершение работы с запросами — реализация недостающих, финализация системы кэширования и т.д.

+ **[v0.9.8](https://github.com/inat-get/inat-get/milestone/8)**

  На эту версию планируется разработка и отладка общей системы отчетов. Пока не вполне ясно, какой именно она
  будет, задача стоит в статусе `research`...

+ **[v1.0](https://github.com/inat-get/inat-get/milestone/9)** <u>(релиз)</u>

  Собственно, все предыдущее, отрефакторенное и прилизанное. Из серьезных изменений, видимых для пользователя,
  запланирована только *контейнеризация* и, через нее, кроссплатформенность.

+ **[v1.2](https://github.com/inat-get/inat-get/milestone/10)** 

  Планы пока не вполне сформированы и будут меняться. В версиях после 1.0 планируется добавление расширенных
  возможностей, сам состав которых будет проясняться в процессе реального использования.

+ **v2.0**

  Совсем неопределенное будущее, к тому времени, вероятно, и API iNaturalist изменится, и потребности совершенно
  новые появятся...

## Установка и использование

### Установка

Проект пакетируется в Ruby Gem, соответственно и устанавливается:
```shell
$ gem install inat-get
```

Впрочем, если есть желание использовать текущую версию «из исходников», можно просто склонировать репозиторий
и выполнить `bundle install`:
```shell
$ git clone https://github.com/inat-get/inat-get.git
$ cd inat-get
$ bundle install
```

И затем запускать через `bundle exec`:
```shell
$ bundle exec inat-get [options] ‹task› [‹task› ...]
```

### Параметры командной строки

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

Итак, в скриптах можно (и нужно) использовать специально подготовленные DSL-методы и объекты,
отвечающие за данные.

Это, во-первых, **модели**, документацию по которым можно найти по адресу 
<https://inat-get.github.io/inat-get/INatGet/Data/Model.html>. В целом это просто объекты
данных, связанные друг с другом. Ключевыми из них будут, пожалуй: 
[`Observation`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Observation.html),
[`Taxon`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Taxon.html),
[`Project`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Project.html),
[`Place`](https://inat-get.github.io/inat-get/INatGet/Data/Model/Place.html)
и [`User`](https://inat-get.github.io/inat-get/INatGet/Data/Model/User.html).

Основная работа построена на арифметике **датасетов** и **списков**. Датасеты — это выборки
данных, манипуляции с которыми происходят без реального обращения к API и БД до того момента,
когда это становится необходимым. Списки — это датасеты, разбитые по некоторому полю-ключу.
Документация находится по адресу <https://inat-get.github.io/inat-get/INatGet/Data/DSL/Dataset.html>
для `Dataset` и <https://inat-get.github.io/inat-get/INatGet/Data/DSL/List.html> для `List`.
Оба этих класса реализуют модуль `Enumerable`, каждый своим способом...

В начале каждого скрипта мы делаем выборки наблюдений (как правило) через метод `select_observations`.
Вообще методы `select_*` и `get_*` для разных типов объектов описаны в документации модуля DSL —
<https://inat-get.github.io/inat-get/INatGet/Data/DSL.html>. В пользовательских скриптах этот 
модуль изначально включен в контекст, соответственно, его методы доступны непосредственно.

*К сожалению, пока не документированы поля выборок.* Скоро будет.

Ниже приведены простые примеры пользовательских скриптов. Рекомендуется обратить внимание
на «арифметические» действия: `+`, `-`, `*` и `%`. Последний выполняет разбиение и превращает
датасет в список.

## Примеры

### Простой отчет для пользователя — [user_stat.rb](share/inat-get/demo/01_user_stat.rb)

```ruby
# Сформируем простой отчет по таксонам, которые наблюдал пользователь с начала года.
# Отчет будет выведен в текущий каталог с именем user_stat.md (формат Markdown)

year = today.year

user = get_user 'shikhalev'      # Здесь указываем ID или логин пользователя, я указал свой

# Получаем наблюдения
observations = select_observations user: user, observed: time_range(year: year), quality_grade: 'research'

by_taxon = observations % :taxon

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Отчет для пользователя ' + user.login + (user.name ? " (#{ user.name })" : '')
  file.puts ''
  by_taxon.each do |ds|
    # Здесь ds.key — это объект Taxon
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ observations.count }** наблюдений"
end
```

### Демонстрация вычитания списков — [underbound.rb](share/inat-get/demo/02_underfound.rb)

```ruby
# А здесь мы реализуем следуеющее: по некоторому району найдем список таксонов,
#  которых данный пользователь не наблюдал (а другие наблюдали).

user = get_user 'shikhalev'
place = get_place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

all_observations = select_observations place: place, quality_grade: 'research', rank: (.. Rank.complex)
full_list = all_observations % :taxon

user_observations = select_observations place: place, quality_grade: "research", rank: (.. Rank.complex), user: user
user_list = user_observations % :taxon

others_list = full_list - user_list
others_list.sort! { |ds| -ds.count }

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Недонайденные'
  file.puts ''
  others_list.each do |ds|
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ others_list.count }** таксонов."
end
```

### Фильтрация списка и диапазон дат — [newcomers.rb](share/inat-get/demo/03_newcomers.rb)

```ruby
# Новички предыдущего месяца. Максимально просто: те, кто сделал наблюдение в течение
#  предыдущего месяца, и зарегистрировался в нем же. Естестаенно, в рамках некоторого
#  проекта, чтобы не тащить слишком много.

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
  file.puts "\#\# Новички проекта «#{ project.title }»"
  file.puts "*#{ period.begin.to_date } — #{ period.end.to_date - 1 }*"
  file.puts ''
  list.each do |ds|
    file.puts "+ #{ ds.key.login } (#{ ds.key.created.to_date }) — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего #{ list.count } пользователей"
end
```
