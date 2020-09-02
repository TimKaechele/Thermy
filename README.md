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

Generate some thermostats for your application

```shell
$ bundle exec rails r 'ThermostatDemoDataSeeder.new.call'
```

## Docs

You can find the api documentation under public/api_docs.yml.
It is an OpenAPIv3 file that can be displayed in any open api compatible editor or viewer

## Performance Evaluation

The current performance of the POST /api/v1/thermostat_readings endpoint is as follows:

### Test Machine

- MacBook Pro (16 Zoll, 2019)
- CPU: 2,4 GHz 8-Core Intel Core i9
- RAM: 32 GB 2667 MHz DDR4

### Setup

- Run rails in production mode with `bundle exec rails s -e production`
- No tweaks to puma configuration (used the config/puma.rb file)
- No reverse proxy
- PostgreSQL 12.3
- Redis server v=6.0.5 sha=00000000:0 malloc=libc bits=64 build=eb61fd90f5227f4d
- Sidekiq 6.1.1

### Test

The test was performed with [Bombardier](https://github.com/codesenberg/bombardier).

```sh
$ bombardier-darwin-amd64 -H 'X-Household-Token: 7d2f8344-fafc-4ab1-bfeb-158d5933cf68' -H 'Content-Type: application/json' -b '{"humidity":40,"temperature":2.3,"battery_charge":59.3}' -m POST http://localhost:3000/api/v1/thermostat_readings -d 120s  -c 50
```

### Findings

```
./bombardier-darwin-amd64 -H 'X-Household-Token: 7d2f8344-fafc-4ab1-bfeb-158d5933cf68' -H 'Content-Type: application/json' -b '{"humidity":40,"temperature":2.3,"battery_charge":59.3}' -m POST http://localhost:3000/api/v1/thermostat_readings -d 120s  -c 50

Bombarding http://localhost:3000/api/v1/thermostat_readings for 2m0s using 50 connection(s)
[=========================================================================] 2m0s
Done!
Statistics        Avg      Stdev        Max
  Reqs/sec       286.10      71.44    2007.95
  Latency      178.19ms      2.14s     38.94s
  HTTP codes:
    1xx - 0, 2xx - 34287, 3xx - 0, 4xx - 0, 5xx - 0
    others - 171
  Errors:
    dial tcp [::1]:3000: connect: connection refused - 171
  Throughput:   235.14KB/s
```

Performance is okayish in my opinion. By tweaking puma and redis (e.g. bigger connection pool),
a higher throughput could be achieved. Later on one could streamline the statistics implementation
to reduce the workload for inserting new entries.

Other performance gains could be achieved by not hitting the db for authentication as described in
https://github.com/TimKaechele/Thermy/issues/5

### Real world implications

The results from above are quite synthetic findings and need to be evaluated
in the real world, an APM (e.g. Scout, New Relic) should be used to evaluate
the real world performance.

Given the api would have the same performance as in the benchmark, the system could
handle 17.166 thermostat reading entries per minute. With some client side help, e.g
batching of readings in one request even more throughput could be achieved.

By adding jittering to the client later on an DDoS scenario could be prevented
where all thermostats call the endpoint at exactly the same time.
