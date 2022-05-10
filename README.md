# Pyr-Setup

This is a collection of scripts to assist you in setting up a local instance of Pyr. This
is not a stand-alone project. It is intended to be checked out next to `pyr` and even copied
into your `pyr` directory during the setup process.

It is highly likely this will be a fairly interactive process due to issues with migrations
and gem dependencies. But, the intent is to remove as much of the complexity and as many of
the environmental issues as possible.

## Prerequisites

* Docker >= 20.10.14
* Pyr (this was developed against the 2.3-MNT branch)
* .netrc
  
  If you don't already have one, you need to create a `~/.netrc` file on your host machine.

  [See more...](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html)

  This file will be mapped into the pyr container and is required to pull gem sources from private
  github repos. The file should contain git auth info. Below is a sample file that represents what I have on
  my machine.

  ```bash
  machine github.com
  login joncain
  password my-github-personal-access-token

  machine api.github.com
  login joncain
  password my-github-personal-access-token
  ```

  Alternatively, you could also map your SSH keys into the container if you would rather do that.

## Clone this repo

```bash
git clone git@github.com:joncain/pyr-setup.git
```

## Copy files

Copy the following files from `pyr-setup` into your `pyr` directory.

* Dockerfile
* docker-compose.yml
* up.sh
* entrypoint.sh
* magick-install.sh

## Build Pyr Image

```bash
# execute on: host
cd your-pyr-dir
docker build -t pyr .
```

## Update Pyr config

Since the services will be running in separate containers, you will need to modify the host name for mysql,
mongo, redis, and elasticsearch.

Modify `core/config/config.yml` and use the container names for the host name.

E.g., 

```bash
database_host: db

mongodb_server:
- mongo:27017

elasticsearch:
    host: elasticsearch

redis_server: redis:6379
rails_cache_uri: redis://redis:6379/0/cache
identity_cache_uri: redis://redis:6379/1/cache
```

## Bundle install

Open a bash prompt on the `pyr` container:

```bash
# execute on: host
docker compose run pyr bash
```

```bash
# execute on: pyr container
cd client/monat
bundle install
```

## Create pyr db user

Connect to the db container:

```bash
# execute on: host
# The root password is "pyr"
docker compose up mysql -d
docker exec -it db mysql -u root -p
```

```bash
# execute on: db container
create user 'pyr'@'%' identified by 'pyr';
grant all on *.* to 'pyr'@'%';
```

Leave this connection open, you will need to run more SQL commands
after you create the client db.

## Db setup/migrations

```bash
# run on: pyr container
cd /app/pyr/clients/monat
bundle exec rake rules:disable db:create
```

```bash
# run on: db container
ALTER DATABASE pyr_monat_dev CHARACTER SET utf8 COLLATE utf8_unicode_ci;
```

```bash
# run on: pyr container
SKIP_DB_PATCHES=true bundle exec rake rules:disable db:migrate
bundle exec rake rules:disable pyr:setup
bundle exec rake rules:disable pyr:shop:setup
bundle exec rake db:mongoid:create_indexes
bundle exec rake pyr:security:load
bundle exec rake pyr:sample_data:load
```

## Run pyr
At this point you can exit the pyr & db container terminals. Next run
the pyr stack (it may take a minute or so on the first run as it initializes.)

```bash
# run on: host
docker compose up -d
```

If you're having trouble for some reason, you can view the pyr output by running:

```bash
docker logs -f pyr
```


Confirm in browser: http://lvh.me:3000
