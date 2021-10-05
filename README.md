# Laravel Environemnt

Quickly stand up a dev laravel environment using apache with functioning queues and schdules.

Use the environment var DEV to stop some caching and optimization.

Mount empty folder to /var/www/html to have new project setup.

## Environment Variables

| Env | Description |
| ------------- | ------------- |
| DEV | Stops some caching and optimization, can be any value |
| PUID | Sets UID for www-data to allow editing data |
| PGID | Sets GID for www-data to allow editing data |


## Setup

```yaml
version: '3'

services:
  mariadb:
    image: mariadb:10.6.4
    environment:
      - MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes
      - MARIADB_USER=user
      - MARIADB_DATABASE=db
      - MARIADB_PASSWORD=password

  laravel:
    tty: true
    build: 
      context: .
    environment:
      - DEV=true
      - TZ=Pacific/Auckland
      - DB_HOST=mariadb
      - DB_DATABASE=db
      - DB_USERNAME=user
      - DB_PASSWORD=password
      - PUID=1000
      - PGID=1000
    depends_on:
      - mariadb
    ports:
      - 3456:80
    volumes:
      - ./laravel:/var/www/html
```

## Prod
Building the Dockerfile will create a prod image using everything in ./laravel

```bash
docker build .
```

## License
[MIT](https://choosealicense.com/licenses/mit/)

