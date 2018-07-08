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
```sh
$ docker run -d -p 3000:3000 --name="ruby-on-whales" andrestv/ruby-on-whales:latest
```

## docker exec
```sh
$ docker exec -i -t ruby-on-whales bash
$ docker exec -i -t ruby-on-whales bin/rails c
```
