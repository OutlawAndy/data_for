# ConfigFor::DataModel

A minimal, `ActiveRecord::QueryMethods`-like interface for data models backed by Rails configuration files.

## Motivation

Not all of your application's data must reside in the database.  For example, States & Countries don't change very often and don't need to be editable by users.

Rails provides a mechanism for loading such data from YAML files in your application's config directory:

```ruby
Rails.application.config_for(:filename)
```

This is useful on it's own, but I've found myself abstracting ontop of this Rails feature often enough that I decided to extract it for reuse.

## Usage

Let's say we have a YAML file with Country & State Data like the following.

<details>
  <summary>e.g. /config/countries.yml</summary>

  ```yaml
  shared:
    -
      id: AU
      name: Australia
      states:
        -
          id: ACT
          name: Australian Capital Territory
          country_id: AU
        -
          id: NSW
          name: New South Wales
          country_id: AU
        -
          id: NT
          name: Northern Territory
          country_id: AU
        -
          id: QLD
          name: Queensland
          country_id: AU
        -
          id: SA
          name: South Australia
          country_id: AU
        -
          id: TAS
          name: Tasmania
          country_id: AU
        -
          id: VIC
          name: Victoria
          country_id: AU
        -
          id: WA
          name: Western Australia
          country_id: AU
    -
      id: CA
      name: Canada
      states:
        -
          id: AB
          name: Alberta
          country_id: CA
        -
          id: BC
          name: British Columbia
          country_id: CA
        -
          id: MB
          name: Manitoba
          country_id: CA
        -
          id: NB
          name: New Brunswick
          country_id: CA
        -
          id: NL
          name: Newfoundland
          country_id: CA
        -
          id: NS
          name: Nova Scotia
          country_id: CA
        -
          id: NT
          name: Northwest Territories
          country_id: CA
        -
          id: NU
          name: Nunavut
          country_id: CA
        -
          id: 'ON' # in YAML, unquoted 'ON' is treated as boolean true
          name: Ontario
          country_id: CA
        -
          id: PE
          name: Prince Edward Island
          country_id: CA
        -
          id: QC
          name: Quebec
          country_id: CA
        -
          id: SK
          name: Saskatchewan
          country_id: CA
        -
          id: YT
          name: Yukon
          country_id: CA
    -
      id: US
      name: United States
      states:
        -
          id: AL
          name: Alabama
          country_id: US
        -
          id: AK
          name: Alaska
          country_id: US
        -
          id: AZ
          name: Arizona
          country_id: US
        -
          id: AR
          name: Arkansas
          country_id: US
        -
          id: CA
          name: California
          country_id: US
        -
          id: CO
          name: Colorado
          country_id: US
        -
          id: CT
          name: Connecticut
          country_id: US
        -
          id: DE
          name: Delaware
          country_id: US
        -
          id: DC
          name: District of Columbia
          country_id: US
        -
          id: FL
          name: Florida
          country_id: US
        -
          id: GA
          name: Georgia
          country_id: US
        -
          id: HI
          name: Hawaii
          country_id: US
        -
          id: ID
          name: Idaho
          country_id: US
        -
          id: IL
          name: Illinois
          country_id: US
        -
          id: IN
          name: Indiana
          country_id: US
        -
          id: IA
          name: Iowa
          country_id: US
        -
          id: KS
          name: Kansas
          country_id: US
        -
          id: KY
          name: Kentucky
          country_id: US
        -
          id: LA
          name: Louisiana
          country_id: US
        -
          id: ME
          name: Maine
          country_id: US
        -
          id: MD
          name: Maryland
          country_id: US
        -
          id: MA
          name: Massachusetts
          country_id: US
        -
          id: MI
          name: Michigan
          country_id: US
        -
          id: MN
          name: Minnesota
          country_id: US
        -
          id: MS
          name: Mississippi
          country_id: US
        -
          id: MO
          name: Missouri
          country_id: US
        -
          id: MT
          name: Montana
          country_id: US
        -
          id: NE
          name: Nebraska
          country_id: US
        -
          id: NV
          name: Nevada
          country_id: US
        -
          id: NH
          name: New Hampshire
          country_id: US
        -
          id: NJ
          name: New Jersey
          country_id: US
        -
          id: NM
          name: New Mexico
          country_id: US
        -
          id: NY
          name: New York
          country_id: US
        -
          id: NC
          name: North Carolina
          country_id: US
        -
          id: ND
          name: North Dakota
          country_id: US
        -
          id: OH
          name: Ohio
          country_id: US
        -
          id: OK
          name: Oklahoma
          country_id: US
        -
          id: OR
          name: Oregon
          country_id: US
        -
          id: PA
          name: Pennsylvania
          country_id: US
        -
          id: PR
          name: Puerto Rico
          country_id: US
        -
          id: RI
          name: Rhode Island
          country_id: US
        -
          id: SC
          name: South Carolina
          country_id: US
        -
          id: SD
          name: South Dakota
          country_id: US
        -
          id: TN
          name: Tennessee
          country_id: US
        -
          id: TX
          name: Texas
          country_id: US
        -
          id: UT
          name: Utah
          country_id: US
        -
          id: VT
          name: Vermont
          country_id: US
        -
          id: VA
          name: Virginia
          country_id: US
        -
          id: WA
          name: Washington
          country_id: US
        -
          id: WV
          name: West Virginia
          country_id: US
        -
          id: WI
          name: Wisconsin
          country_id: US
        -
          id: WY
          name: Wyoming
          country_id: US
  ```

</details>

We could then make use of this in our app with a simple data model like this:

e.g. app/models/data/country.rb

```ruby
Data::Country = Data.define(:id, :name, :states) do
  include ConfigFor::DataModel
  config :countries
end
```

We could then access our data like:

```ruby
Data::Country.find('AU')
# =>
# #<data Data::Country
#  id="AU",
#  name="Australia",
#  states=
#   [{id: "ACT", name: "Australian Capital Territory", country_id: "AU"},
#    {id: "NSW", name: "New South Wales", country_id: "AU"}, ...
```

Or

```ruby
Data::Country.find_by(name: 'United States')
# =>
# #<data Data::Country
#  id="US",
#  name="United States",
#  states=
#   [{id: "AL", name: "Alabama", country_id: "US"},
#    {id: "AK", name: "Alaska", country_id: "US"}, ...
```

If we want more from the attribute members of our DataModel, we can define `cast_#{member}` methods.

e.g.

```ruby
Data::State = Data.define(:id, :name, :country_id)
Data::Country = Data.define(:id, :name, :states) do
  include ConfigFor::DataModel
  config :countries

  private

  def cast_states(data = nil)
    Array(data).map { Data::State[**it] }
  end
end
```

Now, our data looks like this:

```ruby
Data::Country.find('AU')
# =>
# #<data Data::Country
#  id="AU",
#  name="Australia",
#  states=
#   [#<data Data::State id="ACT", name="Australian Capital Territory", country_id="AU">,
#    #<data Data::State id="NSW", name="New South Wales", country_id="AU">, ...
```

### But what if we want to query State data directly?

Do we need to duplicate and restructure our data into a new YAML file? Actually, No!

In addition to a filename, the `config` class method also accepts a transform proc

e.g.

```ruby
Data::State = Data.define(:id, :name, :country_id) do
  include ConfigFor::DataModel
  config :countries, -> { it.pluck(:states).flatten }
end
```

Now we can query States directly.

e.g.

```ruby
Data::State.where(country_id: 'AU')
# =>
# [#<data Data::State id="ACT", name="Australian Capital Territory", country_id="AU">,
#  #<data Data::State id="NSW", name="New South Wales", country_id="AU">,
#  #<data Data::State id="NT", name="Northern Territory", country_id="AU">,
#  #<data Data::State id="QLD", name="Queensland", country_id="AU">,
#  #<data Data::State id="SA", name="South Australia", country_id="AU">,
#  #<data Data::State id="TAS", name="Tasmania", country_id="AU">,
#  #<data Data::State id="VIC", name="Victoria", country_id="AU">,
#  #<data Data::State id="WA", name="Western Australia", country_id="AU">]

Data::Country.find('US').states == Data::State.where(country_id: 'US')
# => true

Data::State.find_by(name: 'Missouri', country_id: 'US')
# => #<data Data::State id="MO", name="Missouri", country_id="US">

_.in? Data::Country.find('US').states
# => true
```

### Primary Keys

> [!IMPORTANT]
> If your data model does not have an `id` member, you need to provide an alternative `primary_key`

e.g.

```ruby
Data::Book = Data.define(:name, :author, :isbn) do
  include ConfigFor::DataModel
  config :books

  self.primary_key = :isbn
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "config_for-data_model"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install config_for-data_model
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
