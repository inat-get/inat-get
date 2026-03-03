# DSL iNatGet

## General Principles

Scripts `*.inat` (or `*.rb`) are regular Ruby scripts with preloaded DSL methods. Users write in full Ruby, but have access to a specialized set of methods for working with iNaturalist data.

Core DSL principles:

- **Laziness**: no operations trigger immediate API or database access
- **Composability**: complex queries are built from simple ones through dataset operations
- **Caching transparency**: users don't manage the cache explicitly, the system decides when to update data
- **Isolation**: direct access to model classes and internal mechanisms is neither required nor provided

---

## Datasets

A dataset is a lazy representation of a set of observations or taxa with an attached selection condition. The condition is not executed until data access is required.

### Creating Datasets

| Method | Returns | Description |
|--------|---------|-------------|
| `select_observations(**query)` | `Dataset` | Set of observations by condition |
| `select_taxa(**query)` | `Dataset` | Set of taxa by condition |
| `select_places(*ids)` | `Array<Place>` | Places by ID or slug |
| `select_projects(*args, **query)` | `Dataset` or `Array<Project>` | Projects by condition or ID |
| `select_users(*ids)` | `Array<User>` | Users by ID or login |
| `get_observation(id)` | `Observation` \| `nil` | Single observation by ID or UUID |
| `get_taxon(id)` | `Taxon` \| `nil` | Single taxon by ID |
| `get_place(id)` | `Place` \| `nil` | Single place by ID, UUID or slug |
| `get_project(id)` | `Project` \| `nil` | Single project by ID or slug |
| `get_user(id)` | `User` \| `nil` | Single user by ID or login |

### Query Parameters for select_observations

| Parameter | Type | Description |
|-----------|------|-------------|
| `taxon` | Taxon, Integer, Set[Taxon], Set[Integer] | Taxon or set of taxa (including descendants) |
| `place` | Place, Integer, String, Set[...] | Place by object, ID or slug |
| `user` | User, Integer, String, Set[...] | User by object, ID or login |
| `project` | Project, Integer, String, Set[...] | Project by object, ID or slug |
| `rank` | Rank, Range[Rank], Set[Rank] | Taxon rank (species, genus, etc.) |
| `quality_grade` | String, Symbol, Set[...] | Quality (research, needs_id, casual) |
| `captive`, `mappable`, `threatened`, `introduced`, etc. | Boolean | Observation flags |
| `observed`, `created` | Time, Date, Range[Time] | Time ranges |
| `latitude`, `longitude` | Float, Range[Float] | Geographic coordinates |
| `accuracy` | Integer, Range[Integer], nil | Location accuracy in meters |
| `license`, `photo_license`, `sound_license` | String, Symbol, Set[...] | Licenses |
| `geoprivacy`, `taxon_geoprivacy` | String, Symbol, Set[...] | Geodata privacy |
| `id`, `observed_year`, `observed_month`, etc. | Integer, Set[Integer], Range[Integer] | Identifiers and time components |
| `iconic_taxa` | String, Symbol, Set[...] | Iconic taxa (Aves, Mammalia, etc.) |
| `identified`, `verifiable`, `licensed`, `photos`, `sounds`, `popular` | Boolean | Special flags |

Full list see in `lib/inat-get/data/helpers/observations.rb`.

### Query Parameters for select_taxa

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | Integer, Set[Integer] | Taxon ID |
| `parent` | Taxon, Integer | Parent taxon |
| `is_active` | Boolean | Whether taxon is active |
| `rank` | Rank, Range[Rank], Set[Rank] | Rank |

### The `name` Variable

Inside the script, the variable `name` is available — the task filename without extension. Used for forming output filenames:

```ruby
File.open "#{name}.md", 'w' do |file|
  file.puts "## Report #{name}"
end
```

---

## Dataset Operations

All operations require operand compatibility: both datasets must have the same helper (i.e., belong to the same entity type — observations or taxa). Incompatible operands raise an exception.

| Operator | Semantics | Result |
|----------|-----------|--------|
| `ds1 + ds2` | Union | Dataset with OR condition |
| `ds1 * ds2` | Intersection | Dataset with AND condition |
| `ds1 - ds2` | Difference | Dataset with AND-NOT condition |

Algebraic properties:
- `+` is commutative and associative
- `*` is commutative and associative  
- `-` is not commutative
- Priority: standard Ruby (`*` higher than `+`)

### Splitting Operation

`ds % field` — splits a dataset into subsets by field value.

Returns a `List` — container of datasets, where each dataset has a `key` (the field value).

```ruby
# Split bird observations by users
by_user = select_observations(taxon: taxon_birds) % :user

# Iterate over datasets, access key via ds.key
by_user.each do |ds|
  user = ds.key
  puts "#{user.login}: #{ds.count} observations"
end
```

Splitting works with any model fields:
- Associations (`:user`, `:taxon`, `:place`)
- Time components (`:observed_year`, `:created_month`, etc.)
- Other fields (`:quality_grade`, `:license`, etc.)

**Current limitation**: splitting materializes the full list of keys on creation. Lazy splitting is planned for the future.

---

## Lists

`List` — container for a set of datasets with homogeneous keys. Not to be confused with Ruby Array.

### List Operations

| Operator | Semantics | Description |
|----------|-----------|-------------|
| `list + other` | Union | By keys: key present if in any list; datasets for common keys are merged |
| `list * other` | Intersection | By keys: key present if in both lists; datasets for common keys are also merged |
| `list - other` | Difference | By keys: keys from other are removed with their datasets |
| `list.to_dataset` | Folding | Merges all list datasets into one via OR |

Homogeneous keys requirement: operations on lists with mismatched key types raise an exception.

### List Methods

| Method | Description |
|--------|-------------|
| `list.keys` | Array of keys |
| `list[key]` | Dataset by key or `nil` |
| `list.count`, `list.size` | Number of keys |
| `list.empty?` | Empty check |
| `list.filter { \|ds\| ... }` | Filter by condition on dataset |
| `list.filter_keys { \|key\| ... }` | Filter by condition on key |
| `list.sort { \|ds\| ... }` | Sort by block |
| `list.sort!` | Sort by key (in-place) |

---

## Materialization and Iteration

A dataset becomes "materialized" on first data access:

| Method | Action |
|--------|--------|
| `ds.each { \|item\| ... }` | Iterate over records |
| `ds.count` | Count records (SQL-optimized) |
| `ds.first` | First record |
| `ds.to_a` | Array of all records (caution with large sets!) |

On materialization:
1. `update!` is called — check if API data update is needed
2. Condition is translated to SQL via Sequel
3. Query is executed against local database

**Important**: materializing one dataset does not affect others, even if they overlap by condition. Each dataset is independent.

---

## Caching and Data Updates

Users don't manage the cache explicitly. The system automatically determines whether to access the iNaturalist API.

### Automatic Behavior

- On first dataset materialization, data freshness is checked per rules in `caching.md`
- If data is stale — API query is executed with respect to cached previous queries
- Within a single script execution, cache is considered immutable

### Explicit Methods (rarely used)

| Method | Action |
|--------|--------|
| `ds.update!` | Forces check if data update is needed. Doesn't always trigger API request — only if data is stale per caching rules |
| `ds.reset!` | Resets dataset materialization state. Next iteration will call `update!` again |

There is no way to forcefully ignore local cache. For debugging or obtaining "clean" data, use `--db-reset` or delete the database file.

---

## Edge Cases and Limitations

### API-Unsupported Conditions

iNaturalist API has limited filter support. In particular, negations (NOT) are not directly supported.

During condition normalization:
- Negations are maximally reduced and pushed to leaves
- Remaining negations are ignored when forming API requests
- Data is loaded in extended volume, final filtering is done in database

Example:
```ruby
# All bird observations are loaded, filtered during iteration
select_observations(taxon: taxon_birds) - select_observations(user: current_user)
```

### Critical Limitation: Unbounded Queries

A dataset with condition equivalent to "everything" (ANYTHING) cannot be materialized — an exception is raised. This protects against attempts to load the entire iNaturalist database.

Invalid constructs:
```ruby
select_observations  # empty query
select_observations(taxon: taxon_birds) + select_observations  # OR with anything = anything
```

Valid empty results:
```ruby
select_observations(taxon: taxon_birds) * select_observations(taxon: taxon_mammals)  # NOTHING
```
Result is an empty dataset, no error.

---

## Usage Examples

### Example 1: Simple User Report

From `share/inat-get/demo/01_user_stat.rb`:

```ruby
year = today.year
user = get_user 'shikhalev'

# Get observations
observations = select_observations user: user, observed: time_range(year: year), quality_grade: 'research'

by_taxon = observations % :taxon

File.open "#{name}.md", 'w' do |file|
  file.puts '## Report for user ' + user.login + (user.name ? " (#{user.name})" : '')
  file.puts ''
  by_taxon.each do |ds|
    # ds.key is a Taxon object
    file.puts "+ #{ds.key.common_name} *(#{ds.key.name})* — #{ds.count} obs."
  end
  file.puts ''
  file.puts "Total **#{observations.count}** observations"
end
```

### Example 2: List Subtraction

From `share/inat-get/demo/02_underfound.rb`:

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
  file.puts '## Not found by you'
  file.puts ''
  others_list.each do |ds|
    file.puts "+ #{ds.key.common_name} *(#{ds.key.name})* — #{ds.count} obs."
  end
  file.puts ''
  file.puts "Total **#{others_list.count}** taxa."
end
```

### Example 3: Time-based Filtering

From `share/inat-get/demo/03_newcomers.rb`:

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
  file.puts "## Newcomers of project «#{project.title}»"
  file.puts "*#{period.begin.to_date} — #{period.end.to_date - 1}*"
  file.puts ''
  list.each do |ds|
    file.puts "+ #{ds.key.login} (#{ds.key.created.to_date}) — #{ds.count} obs."
  end
  file.puts ''
  file.puts "Total #{list.count} users"
end
```

### Example 4: Combining Conditions

```ruby
# Birds or mammals, but research grade only
birds = select_observations(taxon: get_taxon(3))      # Aves
mammals = select_observations(taxon: get_taxon(40151)) # Mammalia
research = select_observations(quality_grade: 'research')

target = (birds + mammals) * research
```

### Example 5: Splitting and Aggregation

```ruby
# Top-10 users by bird observation count in a project
project = get_project 'some-project'
taxon_birds = get_taxon(3)  # Aves

by_user = select_observations(project: project, taxon: taxon_birds) % :user

# Sort by descending count
sorted = by_user.sort { |ds| -ds.count }

sorted.first(10).each do |ds|
  puts "#{ds.key.login}: #{ds.count}"
end
```

---

## Additional DSL Features

### Time Utilities

| Method | Description |
|--------|-------------|
| `today` | Current date (`Date.today`) |
| `now` | Current time (`Time.now`) |
| `time_range(...)` | Time range by various parameters |
| `start_time(...)`, `finish_time(...)` | Period start and end |

Supported parameters for `time_range`: `date`, `century`, `decade`, `year`, `quarter`, `season` (`:winter`, `:spring`, `:summer`, `:autumn`), `month`, `week`, `day`.

### Version

| Method | Description |
|--------|-------------|
| `version` | Gem version (`Gem::Version`) |
| `version_alias` | Version codename |
| `version?(*requirements)` | Check against requirements |
| `version!(*requirements)` | Check or raise exception |

### Enumerations

`Rank` and `Iconic` are directly available in DSL:

```ruby
# Taxon ranks
Rank.species      # species
Rank.genus       # genus
Rank.family      # family
# ... etc., see lib/inat-get/data/types/rank.rb

# Iconic taxa
Iconic.Aves           # birds
Iconic.Mammalia       # mammals
Iconic.Plantae        # plants
# ... etc., see lib/inat-get/data/types/iconic.rb
```
