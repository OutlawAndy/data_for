# DataFor

> Queryable, read-only Ruby `Data` models backed by Rails config files.

[![Gem Version](https://badge.fury.io/rb/data_for.svg)](https://rubygems.org/gems/data_for)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4-ruby.svg)](https://www.ruby-lang.org/)

```ruby
Country = Data.define(:id, :name) do
  include DataFor::Model
  config :countries
end

Country.find("US")              #=> #<data Country id="US", name="United States">
Country.find!("ZZ")             # raises DataFor::RecordNotFound
Country.find_by(name: "Canada") #=> #<data Country id="CA", name="Canada">
Country.where(name: "Canada")   #=> [#<data Country id="CA", name="Canada">]
```

`DataFor` turns YAML in your Rails config directory into queryable, read-only
models — countries, currencies, plans, and other reference data that rarely
changes and doesn't belong in your database. It's built on Ruby's native
[`Data.define`](https://docs.ruby-lang.org/en/3.4/Data.html) and Rails'
[`config_for`](https://guides.rubyonrails.org/configuring.html#config-for-loading-external-configuration), so the records are immutable value objects and the
storage is a YAML file you already know how to edit.

## Why?

Not all of an application's data must live in the database. Reference data —
countries, currencies, subscription tiers, feature flags, lookup tables — has
a few properties that distinguish it from "real" data:

- It rarely changes (changes are deployments, not user actions).
- It is not user-editable.
- It needs to be versioned alongside the code that depends on it.
- It is small enough to live in memory.

### Database vs. `DataFor`

|                                 | Database | `DataFor`            |
|---------------------------------|----------|----------------------|
| Writeable at runtime            | yes      | no                   |
| Schema migrations required      | yes      | no                   |
| Versioned with application code | no       | yes                  |
| Joins                           | yes      | no                   |
| Editable without a redeploy     | yes      | no                   |
| Cost per query                  | network  | in-memory hash/array |

If your data is on the right-hand side of that table, `DataFor` is probably a
better fit than a table.

## Installation

Add to your `Gemfile`:

```ruby
gem "data_for"
```

Then:

```bash
bundle install
```

`DataFor` requires Ruby `>= 3.4` (for the implicit `it` block parameter) and
Rails `>= 6.1` (for `config_for`).

## Usage

### 1. Put your data in `config/`

Rails' `config_for` reads `config/<name>.yml` files. The top-level key
`shared` provides defaults across environments; per-environment keys
(`development`, `production`, etc.) override them.

Example `config/countries.yml`:

```yaml
shared:
  - id: AU
    name: Australia
    states:
      - { id: ACT, name: "Australian Capital Territory", country_id: AU }
      - { id: NSW, name: "New South Wales",              country_id: AU }
      # ...
  - id: CA
    name: Canada
    states:
      - { id: AB, name: Alberta, country_id: CA }
      # ...
  - id: US
    name: "United States"
    states:
      - { id: AL, name: Alabama, country_id: US }
      # ...
```

### 2. Define a model

Use Ruby's `Data.define` to declare the value object's members, then
`include DataFor::Model` to make it queryable:

```ruby
Country = Data.define(:id, :name, :states) do
  include DataFor::Model
  config :countries
end
```

### 3. Query

```ruby
Country.find("AU")
# => #<data Country id="AU", name="Australia", states=[...]>

Country.find!("ZZ")
# raises DataFor::RecordNotFound

Country.find_by(name: "United States")
# => #<data Country id="US", name="United States", states=[...]>

Country.find_by!(name: "Atlantis")
# raises DataFor::RecordNotFound

Country.where(name: "Canada")
# => [#<data Country id="CA", ...>]

Country.all
# => [#<data Country id="AU", ...>, #<data Country id="CA", ...>, ...]
```

`find` uses a primary-key index and is O(1). `find_by` and `where` scan
linearly across the record set — fine for the size of data that belongs in
`DataFor` in the first place.

### Custom primary keys

The default primary key is `:id`. Override it with `self.primary_key=` when
your data uses a different identifier:

```ruby
Book = Data.define(:isbn, :title, :author) do
  include DataFor::Model
  config :books
  self.primary_key = :isbn
end

Book.find("978-0-13-468599-1")
```

### Casting attributes with `cast_<member>`

For every member of your `Data` class, `DataFor::Model` generates a private
`cast_<member>` method that runs at construction time. The default
implementation is the identity function. Override the cast method to coerce,
parse, or nest:

```ruby
Country = Data.define(:id, :name, :states) do
  include DataFor::Model
  config :countries

  private

  def cast_states(data)
    Array(data).map { State[**it] }
  end
end
```

Now every `Country#states` returns an array of `State` value objects rather
than raw hashes:

```ruby
Country.find("US").states.first
# => #<data State id="AL", name="Alabama", country_id="US">
```

### Reprojecting one config to drive multiple models

`config` accepts a `project:` proc that transforms the loaded data before it
becomes the model's record set. This lets a single YAML file power multiple
query surfaces:

```ruby
State = Data.define(:id, :name, :country_id) do
  include DataFor::Model
  config :countries, project: -> { it.pluck(:states).flatten }
end

State.where(country_id: "US")
# => [#<data State id="AL", ...>, #<data State id="AK", ...>, ...]

Country.find("US").states == State.where(country_id: "US")
# => true
```

### Loading data outside of Rails

By default, `config` reads data via `Rails.application.config_for(filename)`.
Pass a `loader:` proc to load data from somewhere else:

```ruby
Plan = Data.define(:id, :name, :price_cents) do
  include DataFor::Model
  config :plans, loader: ->(name) { YAML.load_file("data/#{name}.yml") }
end
```

## Caching & reloading

`config` reads the file once, applies the `project:` proc, freezes the
result, and caches it in a class instance variable. Subsequent queries hit
in-memory data structures — no file I/O, no parsing.

- **In `production`** (with `config.cache_classes = true`), models load at
  boot and stay until the process restarts.
- **In `development`**, Rails reloads model classes on every request, which
  re-evaluates the `Data.define` block and re-runs `config`. Edits to your
  YAML files take effect on the next request — no server restart.
- **In `test`**, behavior matches `production` by default.

If you call `config` a second time on the same class (rare), the internal
`@all` and `@index` memos are cleared so the new data takes over cleanly.

## Alternatives

`DataFor` is not the first gem in this space. The closest neighbors:

### [`data_for`](https://github.com/OutlawAndy/data_for) *(this gem)*

- **Storage:** Rails `config_for` (YAML)
- **Record type:** Ruby `Data.define` (immutable value object)
- **Distinct features:** idiomatic Rails configuration, immutable records, and
  the `project:` proc reshapes one config file into multiple query surfaces.

### [`frozen_record`](https://github.com/byroot/frozen_record)

- **Storage:** YAML / JSON / custom backends
- **Record type:** ActiveRecord-style class
- **Distinct features:** the most mature gem in this space, broadest query API,
  pluggable backends. Records are AR-style classes, not Ruby `Data`.

### [`active_hash`](https://github.com/active-hash/active_hash)

- **Storage:** in-memory hashes (`active_hash`), YAML (`active_yaml`), JSON, ENUM
- **Record type:** ActiveRecord-style class
- **Distinct features:** AR-compatible API, supports associations to AR models.
  Long-established.

### [`yaml_record`](https://github.com/joshbuddy/yaml_record)

- **Storage:** YAML
- **Record type:** custom class
- **Status:** older, less active.

If you need AR-style associations across both real DB tables and your
reference data, `active_hash` is the best fit. If you want the broadest
query API and don't care about value-object semantics, `frozen_record` is
the most mature option. `DataFor` is the smallest gem of the bunch and the
only one built on native Ruby `Data` objects with Rails-idiomatic
configuration.

## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/OutlawAndy/data_for>.

## License

`DataFor` is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
