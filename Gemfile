# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in data_for.gemspec.
gemspec

# Full Rails is required by the dummy test application.
gem 'rails', '>= 6.1'

gem 'puma'

gem 'sqlite3'

# Pin minitest to 5.x: minitest 6.0 changed Runnable#run's arity in a way
# that current railties (<= 8.x) is not yet compatible with.
gem 'minitest', '~> 6.0'

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem 'rubocop-rails-omakase', require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
