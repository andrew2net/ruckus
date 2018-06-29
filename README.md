#README


## Ruby version

**Ruby 2.1.0**

Using RVM:
```
rvm pkg install openssl
rvm install 2.1.1 -C --with-openssl-dir=$HOME/.rvm/usr
gem install puma -v '2.10.2' -- --with-opt-dir=$HOME/.rvm/usr
sudo pacman -S qt5-webkit # for Arch Linux
bundle install
```

## System dependencies

```bash
apt-get install imagemagick
```


## Configuration

```bash
cp .ruby-version.tt .ruby-version
cp config/analytics.yml.tt config/analytics.yml
cp config/application.yml.tt config/application.yml
cp config/database.yml.tt config/database.yml
cp config/democracy_engine_credentials.yml.tt config/democracy_engine_credentials.yml
cp config/google_map_key.yml.tt config/google_map_key.yml
cp config/oauth_providers.yml.tt config/oauth_providers.yml
cp config/sidekiq.yml.tt config/sidekiq.yml
cp config/newrelic.yml.tt config/newrelic.yml
# then update with your local credentials
```


## Database Creation

We use PostgreSQL. So install PostgreSQL and then
```bash
bundle exec rake db:reset     # development
bundle exec rake test:prepare # test
```


## Database initialization

```bash
bundle exec rake db:seed
```


## How to run the test suite

```bash
bundle exec rspec spec
```


## How to run the application

```bash
bundle exec rails s
```


## Credentials

Admin email/password: `admin@example.com`/`password`

Candidate email/password: `ferrell@example.com`/`password`

Candidate page: http://will-ferrell.lvh.me:3000/

For more informations see `db/seeds.rb` file.


## This README would normally document whatever steps are necessary to get the application up and running.

Things you may want to cover:

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
