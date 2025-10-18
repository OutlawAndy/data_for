require "config_for/data_model/version"
require "config_for/data_model/railtie"

module ConfigFor
  module DataModel
    extend ActiveSupport::Concern

    included do
      class_attribute :source_data, instance_writer: false
      class_attribute :primary_key, instance_writer: false, default: :id

      members.each do |member|
        private(define_method(:"cast_#{member}") { it })
      end
    end

    def initialize(**kwargs)
      super(**members.index_with { send(:"cast_#{it}", kwargs[it]) })
    end

    def blank? = send(primary_key).blank?

    class_methods do
      def config(filename, transform = -> { it })
        self.source_data = transform[Rails.application.config_for(filename)].freeze
      end

      def all
        @all ||= source_data.map { new(**it) }
      end

      def find(value)
        find_by(primary_key => value)
      end

      def find_by(data)
        all.find(&method(:match_all?).curry[data])
      end

      def where(data)
        all.select(&method(:match_all?).curry[data])
      end

      def match_all?(constraints, resource)
        constraints.all? { |key, value| resource.public_send(key) == value }
      end
    end
  end
end
