require "test_helper"

class ConfigFor::DataModelTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert ConfigFor::DataModel::VERSION
  end

  test "it loads countries from config" do
    assert_equal 'Mexico', Data::Country.find('MX').name
    assert_equal 'Canada', Data::Country.find('CA').name
  end

  test "it supports casting members into other Data models" do
    us = Data::Country.find('US')

    assert_equal 52, us.states.size
    us.states.each { assert_instance_of Data::State, it }
  end

  test "supports filtering with where" do
    assert_equal Data::Country.find('GB').states, Data::State.where(country_id: 'GB')
  end
end
