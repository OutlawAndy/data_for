Country = Data.define(:id, :name, :states) do
  include DataFor::Model
  config :countries

  private

  def cast_states(data = nil)
    Array(data).map { State[**it] }
  end
end
