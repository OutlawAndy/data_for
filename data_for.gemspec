require_relative "lib/data_for/version"

Gem::Specification.new do |spec|
  spec.name        = "data_for"
  spec.version     = DataFor::VERSION
  spec.authors     = [ "Andy Cohen" ]
  spec.email       = [ "outlawandy@gmail.com" ]
  spec.homepage    = "https://github.com/OutlawAndy/data_for"
  spec.summary     = "Queryable, read-only Ruby Data models backed by Rails config files."
  spec.description = "DataFor turns YAML in your Rails config directory into " \
                     "queryable, read-only models -- countries, currencies, " \
                     "plans, and other reference data that rarely changes and " \
                     "doesn't belong in your database. Built on Ruby's Data.define " \
                     "and Rails' config_for, with a familiar find, find_by, and " \
                     "where API, plus a transform proc that lets one config file " \
                     "power multiple query surfaces."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/**/*", "MIT-LICENSE", "README.md", "CHANGELOG.md"]
  end

  spec.add_dependency "railties", ">= 6.1"
  spec.add_dependency "activesupport", ">= 6.1"
end
