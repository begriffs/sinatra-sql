# Postgres access in Sinatra without an ORM

This is a Sinatra application template that provides lightweight
SQL-only analogues to Rails' database features.

* configure separate databases for each Rack environment
* maintain versioned migrations (in raw SQL)
* easy access to `sql` function in app code to run queries

This template is for competent Postgres users who don't want an
object relational mapper getting between them and their sweet, sweet
SQL.

## How to use

1. clone this repo
1. `bundle`
1. copy `db/config.rb.example` to `db/config.rb`
1. edit it and provide database configuration parameters
1. `rake db:create`

The database is now ready, and at schema version 0. If you run the
application at this point, it will simply output this schema number.

### Creating a migration

1. `rake migration`
1. it creates db/_timestamp_.up.sql and db/_timestamp_.down.sql
1. edit these files to (un)do whatever you want

### Running a migration

Running `rake db:migrate[version, environment]` will execute the
necessary up/down migration sql files to end up at the version
specified. If none is specified, i.e. `rake db:migrate`, it will
default to the newest. The environment defaults to 'development.'

### Executing queries

In your application code use the `sql` function. For an example
look in `app.rb`.

## Contributing

This library would be more flexible as a gem. If anyone wants to
help, your pull requests are welcome.
