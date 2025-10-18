require_relative "lib/config_for/data_model/version"

Gem::Specification.new do |spec|
  spec.name        = "config_for-data_model"
  spec.version     = ConfigFor::DataModel::VERSION
  spec.authors     = [ "Andy Cohen" ]
  spec.email       = [ "outlawandy@gmail.com" ]
  spec.homepage    = "https://github.com/OutlawAndy/config_for-data_model"
  spec.summary     = "A small wrapper around Rails.application.config_for"
  spec.description = "A minimal, ActiveRecord::QueryMethods-like interface for data models backed by Rails configuration files."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] ="https://github.com/OutlawAndy/config_for-data_model"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1"
end
