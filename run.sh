#!/bin/bash

docker run -ti --rm -v $(pwd)/init:/docker-entrypoint-initdb.d:Z -v $(pwd):/foo:Z -p 3306:3306  --name some-mariadb -e MYSQL_DATABASE=game -e MYSQL_ROOT_PASSWORD=my-secret-pw mariadb:10.1
