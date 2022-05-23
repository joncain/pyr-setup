# Pyr-Setup

This is a collection of scripts to assist you in setting up a local instance of Pyr. This
is not a stand-alone project. It is intended to be cloned into your `pyr` directory. I
recommend that you add `pyr-setup` to your .gitignore file.

It is highly likely this will be an interactive process due to issues with migrations
and gem dependencies. But, the intent is to remove as much of the complexity and as many of
the environmental issues as possible.

NOTE: References to `pyr` as a directory represent your local pyr repo. If you have named it
something else, adjust the instructions accordingly.

## Prerequisites

* Docker >= 20.10.14
* Pyr (this was developed against the 2.3-MNT branch)
* .netrc
  
  If you don't already have one, you need to create a `~/.netrc` file on your machine.

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

  Alternatively, you could map your SSH keys into the container.

## Clone this repo

```bash
# execute in your "pyr" directory
git clone git@github.com:joncain/pyr-setup.git
```

## Update Pyr config

Since the services will be running in separate containers, you will need to modify the host name for mysql,
mongo, redis, and elasticsearch.

Modify `pyr/core/config/config.yml` and use the container names for the host name.

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

## Build Pyr Image

```bash
# execute on host machine in your pyr/pyr-setup directory
docker build -t pyr .
```

## Bundle install

```bash
# execute on host machine in your pyr/pyr-setup directory
docker compose run pyr bash
```

You should now have a bash prompt on the `pyr` container.

```bash
# execute within the pyr container in the /app/pyr/clients/monat directory
bundle install
```

If you have errors, make the required changes to your code like you normally
would (on the host machine) and then re-run the bundle commands within the `pyr`
container.

## Create pyr db user

In a new terminal:

```bash
# execute on host machine in the pyr/pyr-setup directory
# The root password is "pyr"
docker compose up mysql -d
docker exec -it db mysql -u root -p
```

You should now have a mysql CLI prompt:

```bash
# execute within the db container at the mysql CLI prompt
CREATE USER 'pyr'@'%' IDENTIFIED BY 'pyr';
GRANT ALL ON *.* TO 'pyr'@'%';
```

Leave this connection open, you will need to run more SQL commands
after you create the client db.

## Db setup/migrations

```bash
# execute within the pyr container in the /app/pyr/clients/monat directory
bundle exec rake rules:disable db:create
```

```bash
# execute within the db container at the mysql CLI prompt
ALTER DATABASE pyr_monat_dev CHARACTER SET utf8 COLLATE utf8_unicode_ci;
```

```bash
# execute within the pyr container in the /app/pyr/clients/monat directory
SKIP_DB_PATCHES=true bundle exec rake rules:disable db:migrate
bundle exec rake rules:disable pyr:setup
bundle exec rake rules:disable pyr:shop:setup
bundle exec rake db:mongoid:create_indexes
bundle exec rake pyr:security:load
bundle exec rake pyr:sample_data:load

# optional
bundle exec rake rules:disable pyr:createvibeaccounts
```

## Run pyr
At this point you can exit the pyr & db container terminals. Next, run
the pyr stack (it may take a minute or so on the first run as it initializes.)

```bash
# execute on host machine in the pyr/pyr-setup directory
docker compose up -d
```

If you're having trouble for some reason, you can view the pyr output by running:

```bash
docker logs -f pyr
```

Confirm in browser: http://lvh.me:3000
