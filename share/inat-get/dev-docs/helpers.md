# Спецификация Helper

## 1. Назначение

Helper — абстрактный класс, инкапсулирующий логику работы с условиями поиска для конкретного типа сущностей (observations, taxa, projects, places, users). 

**Главная цель**: абстрагировать чистую алгебру условий (`Condition`) от конкретики полей и типов данных, предоставляя единый интерфейс для валидации, нормализации и трансляции условий во внешние форматы.

## 2. Функции

Helper выполняет четыре связанные функции:

| Функция | Описание | Когда вызывается |
|---------|----------|----------------|
| **Валидация** | Проверка корректности условий: существование полей, типы значений, допустимые комбинации | При создании `Condition::Query` (fail fast) |
| **Нормализация** | Приведение условий к каноническому виду для внутренней алгебры | В `Condition#normalize`, метод `prepare_query` |
| **Трансляция в API** | Преобразование нормализованных условий в параметры HTTP-запроса | В `Condition#to_api` |
| **Трансляция в Sequel** | Преобразование нормализованных условий в SQL-выражения | В `Condition#to_sequel` |

## 3. Интерфейс абстрактного класса

### Абстрактные методы (переопределяются подклассами)

```ruby
def model           # → Class<Sequel::Model>, например Observation
def endpoint      # → Symbol, например :observations
def query_schema    # → Hash<Symbol, QueryDef>, схема полей запроса
```

### Конкретные методы (общая реализация)

```ruby
def validate!(**raw_query)        # → true или исключение
def prepare_query(**raw_query)    # → Hash (нормализованный)
def to_api(**normalized_query)    # → { endpoint:, params: {} }
def to_sequel(**normalized_query) # → Sequel::SQL::Expression
```

## 4. Правила валидации

- **Только экземпляры моделей**: для полей, ссылающихся на сущности (taxon, place, user, project), допустимы только объекты моделей или `Enumerable` над ними. Разрешение строк (slug) или ID в объекты — ответственность Manager, вызываемого пользователем заранее.
- **Неизвестные поля**: исключение `ArgumentError`.
- **Несоответствие типов**: исключение `ArgumentError` с указанием ожидаемого и фактического типа.

## 5. Правила нормализации (prepare_query)

| Исходное значение | Преобразование |
|-------------------|----------------|
| Одиночное значение для set-поля | `Set[value]` |
| `Enumerable` для set-поля | `value.to_set` |
| `Sequel::Dataset` для set-поля | остаётся как есть (специальный случай для подзапросов) |
| `Date` или `Range<Date>` | `Range<DateTime>` (начало дня / начало следующего дня) |
| `Symbol` | `String#freeze` |
| `location: [lat, lon]` | `{ latitude: lat..lat, longitude: lon..lon }` |
| `Rank` или `Range<Rank>` / `Set<Rank>` | остаётся как есть (специальная обработка в to_api/to_sequel) |

## 6. Трансляция в API (to_api)

- Использует `endpoint` для определения endpoint'а.
- Для моделей извлекает ID через `pk`.
- Для `Sequel::Dataset` вызывает `to_a` и материализует в список ID (ограничений на размер пока нет).
- Для Taxon просто перечисляет ID (ancestors обрабатываются сервером iNaturalist).
- Для остальных полей — прямое отображение или через хуки схемы.

## 7. Трансляция в Sequel (to_sequel)

- Для большинства ассоциаций использует стандартный механизм Sequel.
- **Taxon**: формирует подзапрос через таблицу `taxon_ancestors` для включения потомков.
- **Project**: полная трансляция логики umbrella/collection в SQL-условия (переносится из модели).

## 8. Специальная логика Project (ObservationHelper)

### expand_projects(**query) → Array<Hash>

Метод, вызываемый на этапе `expand_references` в цепочке нормализации `Condition`.

| Конфиг `translate_projects` | Поведение |
|-----------------------------|-----------|
| `'none'` или отсутствует | `[{project: Set[...], ...}]` (без изменений) |
| `'umbrella'` | Umbrella-проекты заменяются подпроектами, исходный удаляется |
| `'all'` | Umbrella и collection-проекты заменяются на условия; collection порождает OR из нескольких Hash |

**Важно**: при `'all'` и нескольких collection-проектах результат — массив из нескольких Hash, которые вызывающий (`Condition::Query#expand_references`) преобразует в `OR[Query, Query, ...]`.

Конфиг берётся из глобального `INatGet::Setup::config`.

## 9. Цепочка нормализации Condition

```
normalize:
  expand_references   # новый метод, Query делегирует helper.expand_projects
  flatten
  push_not_down
  flatten
  push_and_down
  flatten
  merge_n_factor
  flatten
```

`expand_references` в базовом `Condition` — исключение (abstract). Составные условия (`AND`, `OR`, `NOT`) рекурсивно пропускают вызов вниз. `Query` возвращает `self` (если один результат) или `OR[Query, ...]` (если несколько).

## 10. Доступ к Helper

Helper доступен через метакласс модели:

```ruby
# В модели
class Observation < Sequel::Model
  def self.manager = Manager::Observations.instance
end

# В base.rb моделей
def self.helper = self.manager.helper
```

`Condition::Query` получает helper через `model.helper`.

## 11. Структура наследования

```
INatGet::Data::Helper (abstract)
├── Helpers::Observations  
├── Helpers::Taxa
├── Helpers::Projects
├── Helpers::Places
└── Helpers::Users
```


## 12. QueryDef

Внутренний класс/структура, описывающий одно поле запроса:

```ruby
class Field
  # target_model — для извлечения id
  # cardinality — :scalar, :set, :range
  # primitive — базовый тип для проверки
  # api_hook, sequel_hook — опциональные переопределения
end
```

Определяется в `query_schema` подкласса Helper.