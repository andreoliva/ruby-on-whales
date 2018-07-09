# ruby_on_whales
A simple Ruby-on-Rails project using Docker.

# Docker Images
## docker build
```sh
# create a image using your Dockerfile as its recipe
$ docker build . -t andrestv/ruby-on-whales:latest
```

## docker push & pull
```sh
# send your image to your hub, here we're using DockerHub (https://hub.docker.com/)
$ docker push andrestv/ruby-on-whales:latest

# you can also pull images in the same way
$ docker pull postgres:9.6
```

## docker image ls & rm
```sh
# lists all images saved at your host machine
$ docker image ls
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
andrestv/ruby-on-whales    latest              694dcfbe9fdd        2 hours ago         1.01GB
ruby                       2.5.1-slim          428990e7b23b        11 days ago         178MB
phusion/passenger-ruby25   0.9.34              0fdb938b8d30        12 days ago         676MB
postgres                   9.6                 80e563dfecd8        6 weeks ago         235MB
schickling/mailcatcher     latest              7cfb685ea602        6 weeks ago         84.4MB

# you can remove images that you're not using anymore by their names or ids
$ docker image rm postgres:9.6 428990e7b23b
$ docker image ls
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
andrestv/ruby-on-whales    latest              694dcfbe9fdd        2 hours ago         1.01GB
phusion/passenger-ruby25   0.9.34              0fdb938b8d30        12 days ago         676MB
schickling/mailcatcher     latest              7cfb685ea602        6 weeks ago         84.4MB
```

# Docker Containers
## connecting multiple containers through docker network and volumes
```sh
# creating a network
$ docker network create --driver bridge whales_net

# creating volumes that'll be used by the containers
$ docker volume create psql_run_volume
$ docker volume create psql_data_volume

# downloading postgres image
$ docker pull postgres:9.6

# starting postgres container
$ docker run -d \
  -p 5432:5432 \
  -v psql_run_volume:/var/run/postgresql \
  -v psql_data_volume:/var/lib/postgresql/data \
  --network=whales_net \
  --name="postgresql" \
  postgres:9.6

# starting rails container
$ docker run -d \
  -p 3000:3000 \
  -v psql_run_volume:/var/run/postgresql \
  --network=whales_net \
  --name="ruby-on-whales" \
  andrestv/ruby-on-whales:latest
```

## docker exec
```sh
# to run commands inside your containers
$ docker exec -i -t ruby-on-whales bin/rails c
$ docker exec -i -t ruby-on-whales bash
```

## docker stop & rm
```sh
# when you stop a running container all your changes made inside it
# will still be in place when you restart it
$ docker stop ruby-on-whales

# but not when you remove it...
$ docker rm ruby-on-whales
```

# Docker Compose
## using only one docker-compose.yml file
```sh
# starting in background mode
$ docker-compose up -d
```

## docker-compose with multiple configuration files
```sh
# firstly we run a docker-compose config to see the result of the merged files
$ docker-compose -f docker-compose.yml -f docker-compose.dev.yml config

# then we start everything in background mode
$ docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

## running commands inside containers through docker-compose
```sh
# using docker-compose exec everything you'd normally do at
# your project's directory you can do inside the container
$ docker-compose exec ruby-on-whales bin/rails c
$ docker-compose exec ruby-on-whales bundle install
$ docker-compose exec ruby-on-whales bin/rails routes

# the same works for interactions with the PostgreSQL container
$ docker-compose exec postgres psql -U postgres
$ docker-compose exec postgres pg_dump -U postgres row_dev > dump.sql

# you can also access the console for each container and do your operations inside it
$ docker-compose exec ruby-on-whales bash
root@7b0891c8272e:/home/app#
```

## to deploy from CI...
```sh
# we build our image using the --build-arg option, so we can
# pass data to be used by our image at the production environment.
# $RAILS_MASTER_KEY and $PRODUCTION_DATABASE_PASSWORD are env vars saved at our CI
$ docker build -t andrestv/ruby-on-whales:latest \
  --build-arg rails_master_key=$RAILS_MASTER_KEY \
  --build-arg production_database_password=$PRODUCTION_DATABASE_PASSWORD \
  --build-arg rails_env=production .

# and then we push it to our hub
$ docker push andrestv/ruby-on-whales:latest
```

## at production environment...
At your production machine you only need the docker-compose files and the folder structure where you'll keep your persistent data - at out exemple we commited it to the repository, so we don't have to worry about creating it. Then you only need to run the `docker-compose` command using the production yml - Compose will download all the images you need and set everything up for you!
```sh
# stopping all running containers
$ docker stop $(docker ps -aq)

# removing all running containers
$ docker rm $(docker ps -aq)

# cleaning volume cache - we're only doing this because WE KNOW that our database is saved
# at the host machine, and not at a docker managed volume
$ docker volume prune

# pulling the updated image - this step is not really necessary
# because docker-compose will do it for us
$ docker pull andrestv/ruby-on-whales:latest

# starting everything in background mode
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
It's important to remember that you'll have to daemonize it so your service can start up with your machine.
