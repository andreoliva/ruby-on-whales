# ruby_on_whales
A simple Ruby-on-Rails project using Docker.

## docker build
```sh
$ docker build . -t andrestv/ruby-on-whales:latest
```

## docker push
```sh
$ docker push andrestv/ruby-on-whales:latest
```

## docker run
This will not work when using PostgreSQL as your database, because your _ruby-on-whales_ container will need a running _postgresql_ container.
```sh
$ docker run -d -p 3000:3000 --name="ruby-on-whales" andrestv/ruby-on-whales:latest
```

## docker exec
```sh
$ docker exec -i -t ruby-on-whales bash
$ docker exec -i -t ruby-on-whales bin/rails c
```

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
