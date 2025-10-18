Data::Country = Data.define(:id, :name, :states) do
  include ConfigFor::DataModel
  config :countries

  private

  def cast_states(data = nil)
    Array(data).map { Data::State[**it] }
  end
end
