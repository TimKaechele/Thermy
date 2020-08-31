# README

Manage all your thermostat readings

## Dependencies

- Ruby Version (MRI) 2.7.1
- Postgresql 12.3
- Redis 6.0.5

## Setup

Install the correct ruby version

```shell
$ rvm install 2.7.1
```

Install the ruby dependencies

```shell
$ bundle install --jobs=64
```

Create your database file and fill in your username/password

```shell
$ cp config/database.yml.example config/database.yml
```

Setup the database

```shell
$ bundle exec rails db:setup
```

Run the test suite

```shell
$ bundle exec rspec
```

Start a server

```shell
$ bundle exec rails server
```
