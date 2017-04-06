# Docker MariaDB

This is images based on `alpine` linux

### Connecting guide
To connect the MariaDB to yours compose, you just need to add following lines to yours compose file

```
intvoice-www:
  intvoice-mysql:
    hostname: intvoice-mysql
    image: innolend/docker-mariadb
    environment:
      DB_DATABASE: innolend
      DB_USERNAME: homestead
      DB_PASSWORD: secret
      DB_ROOT_PASSWORD: supersecret
    privileged: true
    volumes:
      - mysql:/var/lib/mysql
```