# Precompiled PHP extensions in Docker `scratch` images

## Todo

- [ ] build optimized images from docker's official PHP images
- [ ] build and push images to dockerhub using gitlab actions
- [ ] write better documentation

## How to build ?

Running `make` will build each specified `PHP_VERSIONS` 
on each specified `PHP_DISTROS` 
with all the extensions provided in `PHP_EXTS`.

> ⚠ Attention: It will take a while.

Instead, override `PHP_VERSIONS`, `PHP_DISTROS` and `PHP_EXTS` based on your needs.

`PHP_VERSIONS=8.0.10 PHP_DISTROS=alpine3.14 PHP_EXTS="composer xdebug" make`

## How to use precompiled extensions ? 

```Dockerfile
# 1. Choose an official PHP image
FROM php:8.0.10-fpm-alpine3.14

# 2. Extension are stored in "scratch" images with their respective dependencies
COPY --from=username/php:8.0.10-alpine3.14-ext-xdebug / /
COPY --from=username/php:8.0.10-alpine3.14-ext-pcov / /
COPY --from=username/php:8.0.10-alpine3.14-ext-amqp / /
COPY --from=username/php:8.0.10-alpine3.14-ext-memcached / /
COPY --from=username/php:8.0.10-alpine3.14-ext-redis / /
```

## Credits

- [brefphp/extra-php-extensions](https://github.com/brefphp/extra-php-extensions) for the inspiration.
- [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer) for the script which allow to build most PHP extensions from PHP 5.5 to PHP 8.1.
