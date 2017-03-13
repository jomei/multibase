# Multibase [![Build Status](https://travis-ci.org/jomei/multibase.svg?branch=master)](https://travis-ci.org/jomei/multibase)   [![Coverage Status](https://coveralls.io/repos/github/jomei/multibase/badge.svg?branch=master)](https://coveralls.io/github/jomei/multibase?branch=master) [![Code Climate](https://lima.codeclimate.com/github/jomei/multibase/badges/gpa.svg)](https://lima.codeclimate.com/github/jomei/multibase)
Multiple database support for Rails
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multibase-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multibase-rails

## Usage

### database.yml 
Change config/database.yml so that settings for every database are placed under the following root key:
```yaml
# config/database.yml
---
default: # default key for the default database
  test:
    adapter: sqlite3
    url:     ./base/test.sqlite3
  development:
    adapter: sqlite3
    url:     ./base/development.sqlite3
  production:
    adapter: postgresql
    url:     <%= ENV['DEFAULT_BASE_URL'] %>
custom_db: # the unique name for another database
  test:
    adapter: sqlite3
    url:     ./custom_db/test.sqlite3
  development:
    adapter: sqlite3
    url:     ./custom_db/development.sqlite3
  production:
    adapter: postgresql
    url:     <%= ENV['PERSONAL_BASE_URL'] %>
```
### Configurations
You can define your own default database key in `config/application.rb`
```
config.multibase.default_key # Default: 'default'
```

### Rake tasks
All `db:` rake tasks defined for each database as `db:your_database_name:command`, e.g. `rake db:cusom_db:create`

### Rails Generators
#### Migrations
Use `multibase:migration` to generate migration for specific database
```
rails g multibase:migration <migration_name> <database_name> <options>
```
Example
```ruby
rails g multibase:migration CreateMyTable custom_db foo:integer baz:string 
```
### Rails models
All models should be inherit from `Multibase::Base`.
Use `using` method to specify database connection 
Example
```ruby
class Comment < Multibase::Base
  using :my_not_default_connection
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

