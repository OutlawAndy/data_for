require "test_helper"

class DataFor::ModelTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert DataFor::VERSION
  end

  test "find returns a record by primary key" do
    assert_equal "Mexico", Country.find("MX").name
    assert_equal "Canada", Country.find("CA").name
  end

  test "find returns nil for unknown primary key" do
    assert_nil Country.find("ZZ")
  end

  test "find! raises RecordNotFound for unknown primary key" do
    assert_raises(DataFor::RecordNotFound) { Country.find!("ZZ") }
  end

  test "find_by matches arbitrary attributes" do
    assert_equal "US", Country.find_by(name: "United States").id
  end

  test "find_by returns nil when nothing matches" do
    assert_nil Country.find_by(name: "Atlantis")
  end

  test "find_by! raises RecordNotFound when nothing matches" do
    assert_raises(DataFor::RecordNotFound) { Country.find_by!(name: "Atlantis") }
  end

  test "where returns all matching records" do
    matches = Country.where(name: "United States")
    assert_equal [ "US" ], matches.map(&:id)
  end

  test "cast_<member> hooks transform nested data into Data instances" do
    us = Country.find("US")

    assert_equal 52, us.states.size
    us.states.each { assert_instance_of State, it }
  end

  test "project: reshapes one config to drive a second model" do
    assert_equal Country.find("GB").states, State.where(country_id: "GB")
  end
end
