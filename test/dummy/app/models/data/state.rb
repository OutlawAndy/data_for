Data::State = Data.define(:id, :name, :country_id) do
  include ConfigFor::DataModel
  config :countries, -> { it.pluck(:states).flatten }
end
