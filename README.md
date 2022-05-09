# Copy Files

Copy these files into your pyr project directory

# Build Pyr Image

```bash
# run on: host
docker build -t pyr .
```

# Create a .netrc

[See more...](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html)

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

You could also map your SSH keys into the container if you would rather do that.

# Pyr prerequisites

Run the pyr container. This will run the entrypoint script and do the following:

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

# Db setup

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
the pyr stack (it may take a minute or so on the first run as it init-
ializes.)

```bash
# run on: host
docker compose up -d
```

Confirm in browser: http://lvh.me:3000
