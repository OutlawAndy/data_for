# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'data_for/version'

module DataFor
  class RecordNotFound < StandardError; end

  module Model
    extend ActiveSupport::Concern

    DEFAULT_LOADER = ->(filename) { Rails.application.config_for(filename) }

    included do
      class << self
        attr_accessor :source_data
        attr_writer :primary_key

        def primary_key
          @primary_key ||= :id
        end
      end

      members.each do |member|
        private(define_method(:"cast_#{member}") { it })
      end
    end

    def initialize(**kwargs)
      super(**members.index_with { send(:"cast_#{it}", kwargs[it]) })
    end

    class_methods do
      def config(filename, project: -> { it }, loader: DEFAULT_LOADER)
        self.source_data = project[loader[filename]].freeze
        @all = nil
        @index = nil
        source_data
      end

      def all
        @all ||= source_data.map { new(**it) }
      end

      def find(value)
        index[value]
      end

      def find!(value)
        find(value) or raise RecordNotFound,
                             "Couldn't find #{name} with #{primary_key}=#{value.inspect}"
      end

      def find_by(data)
        all.find { match_all?(data, it) }
      end

      def find_by!(data)
        find_by(data) or raise RecordNotFound,
                               "Couldn't find #{name} matching #{data.inspect}"
      end

      def where(data)
        all.select { match_all?(data, it) }
      end

      def index
        @index ||= all.index_by { it.public_send(primary_key) }
      end

      def match_all?(constraints, resource)
        constraints.all? { |key, value| resource.public_send(key) == value }
      end
    end
  end
end
