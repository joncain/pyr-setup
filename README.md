# Copy Files

Copy the following files from this repo into your pyr project directory.

* Dockerfile
* docker-compose.yml
* up.sh
* entrypoint.sh
* magick-install.sh

# Build Pyr Image

```bash
# run on: host
docker build -t pyr .
```

# Create a .netrc file

This file will be mapped from the host machine (`~/.netrc`) to the pyr container. It is required
to pull gem sources from github. The file should contain git auth info. Below is a sample file
that represents what I have.

```text
machine github.com
login joncain
password my-github-personal-access-token

machine api.github.com
login joncain
password my-github-personal-access-token
```

[See more...](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html)

You could also map your SSH keys into the container if you would rather do that.

# Update Pyr config

Since the services will be running in containers, you will need to modify the host names for mysql,
mongo, and elasticsearch. Modify `core/config/config.yml` and use the container names as the host
name.

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

# Bundle install

This will run the entrypoint script and do the following:

* Install Nokogiri & Rails (one-time only)
* Add `/app/pyr` to git safe dirs
* Modify `/etc/hosts`
* Leave you at a bash prompt for the next step...

```bash
# run on: host
docker compose run pyr bash
```

```bash
# run on: pyr container
cd client/monat
bundle install
```

# Create pyr db user

Open a new terminal to connect to the mysql container.
The root password for the mysql instance is `pyr`.

```bash
# run on: host
docker compose up mysql -d
docker exec -it db mysql -u root -p
```

```bash
# run on: db container
create user 'pyr'@'%' identified by 'pyr';
grant all on *.* to 'pyr'@'%';
```

Leave this terminal open, you will need to run more SQL commands.

# Db setup/migrations

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

# Run pyr
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
