# DSL iNatGet

## Общие принципы

Скрипты `*.inat` (или `*.rb`) представляют собой обычные Ruby-скрипты с предзагруженными методами DSL. Пользователь пишет на полноценном Ruby, но в распоряжении имеет набор специализированных методов для работы с данными iNaturalist.

Основные принципы DSL:

- **Ленивость**: никакие операции не приводят к немедленному обращению к API или БД
- **Композиционность**: сложные запросы строятся из простых через операции над датасетами
- **Непрозрачность кэширования**: пользователь не управляет кэшем явно, система сама решает, когда обновлять данные
- **Изоляция**: прямой доступ к классам моделей и внутренним механизмам не требуется и не предоставляется

---

## Датасеты (Dataset)

Датасет — ленивое представление набора наблюдений или таксонов с прикреплённым условием отбора. Условие не выполняется до тех пор, пока не потребуется доступ к данным.

### Создание датасетов

| Метод | Возвращает | Описание |
|-------|-----------|----------|
| `select_observations(**query)` | `Dataset` | Набор наблюдений по условию |
| `select_taxa(**query)` | `Dataset` | Набор таксонов по условию |
| `select_places(*ids)` | `Array<Place>` | Места по ID или slug |
| `select_projects(*args, **query)` | `Dataset` или `Array<Project>` | Проекты по условию или ID |
| `select_users(*ids)` | `Array<User>` | Пользователи по ID или login |
| `get_observation(id)` | `Observation` \| `nil` | Одно наблюдение по ID или UUID |
| `get_taxon(id)` | `Taxon` \| `nil` | Один таксон по ID |
| `get_place(id)` | `Place` \| `nil` | Одно место по ID, UUID или slug |
| `get_project(id)` | `Project` \| `nil` | Один проект по ID или slug |
| `get_user(id)` | `User` \| `nil` | Один пользователь по ID или login |

### Параметры запроса для select_observations

| Параметр | Тип | Описание |
|----------|-----|----------|
| `taxon` | Taxon, Integer, Set[Taxon], Set[Integer] | Таксон или множество таксонов (включая потомков) |
| `place` | Place, Integer, String, Set[...] | Место по объекту, ID или slug |
| `user` | User, Integer, String, Set[...] | Пользователь по объекту, ID или login |
| `project` | Project, Integer, String, Set[...] | Проект по объекту, ID или slug |
| `rank` | Rank, Range[Rank], Set[Rank] | Ранг таксона (species, genus и т.д.) |
| `quality_grade` | String, Symbol, Set[...] | Качество (research, needs_id, casual) |
| `captive`, `mappable`, `threatened`, `introduced` и др. | Boolean | Флаги наблюдений |
| `observed`, `created` | Time, Date, Range[Time] | Временные диапазоны |
| `latitude`, `longitude` | Float, Range[Float] | Географические координаты |
| `accuracy` | Integer, Range[Integer], nil | Точность геолокации в метрах |
| `license`, `photo_license`, `sound_license` | String, Symbol, Set[...] | Лицензии |
| `geoprivacy`, `taxon_geoprivacy` | String, Symbol, Set[...] | Приватность геоданных |
| `id`, `observed_year`, `observed_month` и др. | Integer, Set[Integer], Range[Integer] | Идентификаторы и временные компоненты |
| `iconic_taxa` | String, Symbol, Set[...] | Иконичные таксоны (Aves, Mammalia и т.д.) |
| `identified`, `verifiable`, `licensed`, `photos`, `sounds`, `popular` | Boolean | Специальные флаги |

Полный список см. в `lib/inat-get/data/helpers/observations.rb`.

### Параметры запроса для select_taxa

| Параметр | Тип | Описание |
|----------|-----|----------|
| `id` | Integer, Set[Integer] | ID таксона |
| `parent` | Taxon, Integer | Родительский таксон |
| `is_active` | Boolean | Активен ли таксон |
| `rank` | Rank, Range[Rank], Set[Rank] | Ранг |

### Переменная `name`

Внутри скрипта доступна переменная `name` — имя файла задачи без расширения. Используется для формирования имён выходных файлов:

```ruby
File.open "#{name}.md", 'w' do |file|
  file.puts "## Отчёт #{name}"
end
```

---

## Операции над датасетами

Все операции требуют совместимости операндов: оба датасета должны иметь один и тот же helper (то есть относиться к одному типу сущностей — observations или taxa). Несовместимые операнды вызывают исключение.

| Оператор | Семантика | Результат |
|----------|-----------|-----------|
| `ds1 + ds2` | Объединение | Датасет с условием ИЛИ |
| `ds1 * ds2` | Пересечение | Датасет с условием И |
| `ds1 - ds2` | Разность | Датасет с условием И-НЕ |

Алгебраические свойства:
- `+` коммутативен и ассоциативен
- `*` коммутативен и ассоциативен  
- `-` не коммутативен
- Приоритет: стандартный для Ruby (`*` выше `+`)

### Операция разбиения

`ds % field` — разбивает датасет на подмножества по значению поля.

Возвращает `List` — контейнер датасетов, где каждый датасет имеет `key` (значение поля разбиения).

```ruby
# Разбиение наблюдений птиц по пользователям
by_user = select_observations(taxon: taxon_birds) % :user

# Итерация по датасетам, доступ к ключу через ds.key
by_user.each do |ds|
  user = ds.key
  puts "#{user.login}: #{ds.count} наблюдений"
end
```

Разбиение работает по любым полям модели:
- Ассоциации (`:user`, `:taxon`, `:place`)
- Временные компоненты (`:observed_year`, `:created_month` и т.д.)
- Прочие поля (`:quality_grade`, `:license` и т.д.)

**Ограничения текущей реализации**: разбиение материализует полный список ключей при создании. Ленивое разбиение запланировано на будущее.

---

## Списки (List)

`List` — контейнер для набора датасетов с однородными ключами. Не путать с Ruby Array.

### Операции над списками

| Оператор | Семантика | Описание |
|----------|-----------|----------|
| `list + other` | Объединение | По ключам: ключ присутствует, если есть в любом списке; датасеты для общих ключей объединяются |
| `list * other` | Пересечение | По ключам: ключ присутствует, если есть в обоих списках; датасеты для общих ключей также объединяются |
| `list - other` | Разность | По ключам: ключи из other удаляются вместе с датасетами |
| `list.to_dataset` | Свертка | Объединяет все датасеты списка в один через ИЛИ |

Требование однородности ключей: операции над списками с несовпадающими типами ключей вызывают исключение.

### Методы List

| Метод | Описание |
|-------|----------|
| `list.keys` | Массив ключей |
| `list[key]` | Датасет по ключу или `nil` |
| `list.count`, `list.size` | Количество ключей |
| `list.empty?` | Проверка на пустоту |
| `list.filter { \|ds\| ... }` | Фильтрация по условию на датасет |
| `list.filter_keys { \|key\| ... }` | Фильтрация по условию на ключ |
| `list.sort { \|ds\| ... }` | Сортировка по блоку |
| `list.sort!` | Сортировка по ключу (in-place) |

---

## Материализация и итерация

Датасет становится "материализованным" при первом обращении к данным:

| Метод | Действие |
|-------|----------|
| `ds.each { \|item\| ... }` | Итерация по записям |
| `ds.count` | Подсчёт записей (оптимизированно на уровне SQL) |
| `ds.first` | Первая запись |
| `ds.to_a` | Массив всех записей (осторожно с большими наборами!) |

При материализации:
1. Вызывается `update!` — проверка необходимости обновления данных из API
2. Условие транслируется в SQL через Sequel
3. Выполняется запрос к локальной БД

**Важно**: материализация одного датасета не влияет на другие, даже если они перекрываются по условиям. Каждый датасет независим.

---

## Кэширование и обновление данных

Пользователь не управляет кэшем явно. Система автоматически определяет, нужно ли обращаться к API iNaturalist.

### Автоматическое поведение

- При первой материализации датасета проверяется актуальность данных по правилам, описанным в `caching.md`
- Если данные устарели — выполняется запрос к API с учётом кэшированных предыдущих запросов
- В рамках одного выполнения скрипта кэш считается неизменным

### Явные методы (используются редко)

| Метод | Действие |
|-------|----------|
| `ds.update!` | Форсирует проверку необходимости обновления данных. Не всегда приводит к API-запросу — только если данные устарели по правилам кэширования |
| `ds.reset!` | Сбрасывает состояние материализации датасета. Следующая итерация снова вызовет `update!` |

Нет способа принудительно игнорировать локальный кэш. Для отладки или получения "чистых" данных следует использовать `--db-reset` или удалить файл БД.

---

## Граничные случаи и ограничения

### Неподдерживаемые в API условия

iNaturalist API имеет ограниченный набор фильтров. В частности, отрицания (NOT) напрямую не поддерживаются.

При нормализации условий:
- Отрицания максимально сокращаются и проталкиваются к листьям
- Оставшиеся отрицания игнорируются при формировании API-запроса
- Данные загружаются в расширенном объёме, финальная фильтрация выполняется в БД

Пример:
```ruby
# Загружаются все наблюдения птиц, при итерации фильтруются
select_observations(taxon: taxon_birds) - select_observations(user: current_user)
```

### Критическое ограничение: неограниченные запросы

Датасет с условием, эквивалентным "всё" (ANYTHING), не может быть материализован — генерируется исключение. Это защита от попыток загрузить всю базу iNaturalist.

Недопустимые конструкции:
```ruby
select_observations  # пустой запрос
select_observations(taxon: taxon_birds) + select_observations  # OR с чем угодно = что угодно
```

Допустимые пустые результаты:
```ruby
select_observations(taxon: taxon_birds) * select_observations(taxon: taxon_mammals)  # NOTHING
```
Результат — пустой датасет, ошибки нет.

---

## Примеры использования

### Пример 1: Простой отчёт по пользователю

Из `share/inat-get/demo/01_user_stat.rb`:

```ruby
year = today.year
user = get_user 'shikhalev'

# Получаем наблюдения
observations = select_observations user: user, observed: time_range(year: year), quality_grade: 'research'

by_taxon = observations % :taxon

File.open "#{name}.md", 'w' do |file|
  file.puts '## Отчет для пользователя ' + user.login + (user.name ? " (#{user.name})" : '')
  file.puts ''
  by_taxon.each do |ds|
    # ds.key — объект Taxon
    file.puts "+ #{ds.key.common_name} *(#{ds.key.name})* — #{ds.count} набл."
  end
  file.puts ''
  file.puts "Всего **#{observations.count}** наблюдений"
end
```

### Пример 2: Вычитание списков

Из `share/inat-get/demo/02_underfound.rb`:

```ruby
user = get_user 'shikhalev'
place = get_place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

all_observations = select_observations place: place, quality_grade: 'research', rank: (.. Rank.complex)
full_list = all_observations % :taxon

user_observations = select_observations place: place, quality_grade: "research", rank: (.. Rank.complex), user: user
user_list = user_observations % :taxon

others_list = full_list - user_list
others_list.sort! { |ds| -ds.count }

File.open "#{name}.md", 'w' do |file|
  file.puts '## Недонайденные'
  file.puts ''
  others_list.each do |ds|
    file.puts "+ #{ds.key.common_name} *(#{ds.key.name})* — #{ds.count} набл."
  end
  file.puts ''
  file.puts "Всего **#{others_list.count}** таксонов."
end
```

### Пример 3: Фильтрация по времени

Из `share/inat-get/demo/03_newcomers.rb`:

```ruby
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

File.open "#{name}.md", 'w' do |file|
  file.puts "## Новички проекта «#{project.title}»"
  file.puts "*#{period.begin.to_date} — #{period.end.to_date - 1}*"
  file.puts ''
  list.each do |ds|
    file.puts "+ #{ds.key.login} (#{ds.key.created.to_date}) — #{ds.count} набл."
  end
  file.puts ''
  file.puts "Всего #{list.count} пользователей"
end
```

### Пример 4: Комбинирование условий

```ruby
# Птицы или млекопитающие, но только исследовательского качества
birds = select_observations(taxon: get_taxon(3))      # Aves
mammals = select_observations(taxon: get_taxon(40151)) # Mammalia
research = select_observations(quality_grade: 'research')

target = (birds + mammals) * research
```

### Пример 5: Разбиение и агрегация

```ruby
# Топ-10 пользователей по количеству наблюдений птиц в проекте
project = get_project 'some-project'
taxon_birds = get_taxon(3)  # Aves

by_user = select_observations(project: project, taxon: taxon_birds) % :user

# Сортировка по убыванию количества
sorted = by_user.sort { |ds| -ds.count }

sorted.first(10).each do |ds|
  puts "#{ds.key.login}: #{ds.count}"
end
```

---

## Дополнительные возможности DSL

### Утилиты времени

| Метод | Описание |
|-------|----------|
| `today` | Текущая дата (`Date.today`) |
| `now` | Текущее время (`Time.now`) |
| `time_range(...)` | Диапазон времени по различным параметрам |
| `start_time(...)`, `finish_time(...)` | Начало и конец периода |

Поддерживаемые параметры для `time_range`: `date`, `century`, `decade`, `year`, `quarter`, `season` (`:winter`, `:spring`, `:summer`, `:autumn`), `month`, `week`, `day`.

### Версия

| Метод | Описание |
|-------|----------|
| `version` | Версия гема (`Gem::Version`) |
| `version_alias` | Кодовое имя версии |
| `version?(*requirements)` | Проверка соответствия требованиям |
| `version!(*requirements)` | Проверка или исключение |

### Перечисления

`Rank` и `Iconic` доступны напрямую в DSL:

```ruby
# Ранги таксонов
Rank.species      # вид
Rank.genus       # род
Rank.family      # семейство
# ... и др., см. lib/inat-get/data/types/rank.rb

# Иконичные таксоны
Iconic.Aves           # птицы
Iconic.Mammalia       # млекопитающие
Iconic.Plantae        # растения
# ... и др., см. lib/inat-get/data/types/iconic.rb
```
