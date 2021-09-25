# Precompiled PHP extensions in Docker `scratch` images

On DockerHub: https://hub.docker.com/r/gcanal/php-extra

## How to use precompiled extensions ? 

```Dockerfile
# 1. Choose an official PHP image
FROM php:8.0.10-fpm-alpine3.14 as build

# 2. Extension are stored in "scratch" images with their respective dependencies
COPY --from=gcanal/php-extra:8.0.10-alpine3.14-ext-xdebug / /
COPY --from=gcanal/php-extra:8.0.10-alpine3.14-ext-pcov / /
COPY --from=gcanal/php-extra:8.0.10-alpine3.14-ext-amqp / /
COPY --from=gcanal/php-extra:8.0.10-alpine3.14-ext-memcached / /
COPY --from=gcanal/php-extra:8.0.10-alpine3.14-ext-redis / /

# 3. Add PHP utilities
COPY --from=gcanal/php-extra:composer / /
COPY --from=gcanal/php-extra:symfony / /
COPY --from=gcanal/php-extra:psysh / /

# 4. FLatten the image
FROM scratch
COPY --from=build / /
```

## How to build ?

Running `make` will build each specified `PHP_VERSIONS` 
on each specified `PHP_DISTROS` 
with all the extensions provided in `PHP_EXTS`.

> ⚠ Attention: It will take a while.

Instead, override `PHP_VERSIONS`, `PHP_DISTROS` and `PHP_EXTS` based on your needs.

`DOCKER_REPO=<your docker organization or username> PHP_VERSIONS=8.0.10 PHP_DISTROS=bullseye PHP_EXTS="xdebug intl apcu opcache" make`

## Todo

- [ ] build optimized images from docker's official PHP images
- [ ] build and push images to dockerhub using Github Actions
    - [ ] Monitor new PHP, PHP extensions releases and trigger a build if necessary
- [ ] offer to install PHP utilities such as [PsySH](https://psysh.org) or the [Symfony binary](https://symfony.com/download)

## Credits

- [brefphp/extra-php-extensions](https://github.com/brefphp/extra-php-extensions) for the inspiration.
- [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer) for the script which allow to build most PHP extensions from PHP 5.5 to PHP 8.1.
