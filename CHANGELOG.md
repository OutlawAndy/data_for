## Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Initial pre-release. The gem has not yet been published to RubyGems.

### Added

- `DataFor::Model` concern for read-only `Data.define` models backed by Rails config files.
- `find`, `find!`, `find_by`, `find_by!`, and `where` query methods.
- O(1) primary-key lookup for `find` and `find!` via a lazily-built index.
- `DataFor::RecordNotFound` raised by bang variants.
- `self.primary_key=` for non-`:id` primary keys.
- `cast_<member>` hooks for typed attribute casting (including nested Data models).
- `project:` keyword on `config` for reshaping the source data before it becomes the model's record set, letting a single YAML file drive multiple query surfaces.
- `loader:` keyword on `config` for loading source data outside of Rails.
