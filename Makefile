DOCKER_REPO?=$(USER)

PHP_VERSIONS?=\
	8.1.0RC1\
	8.0.10\
	7.4.23\
	7.3.30\

# @FIXME Not every PHP version are compatible with every Linux distros
PHP_DISTROS?=\
	alpine3.14\
	bullseye\

PHP_EXTS?=\
	composer\
	amqp\
	apcu\
	apcu_bc\
	ast\
	bcmath\
	blackfire\
	bz2\
	calendar\
	cmark\
	csv\
	dba\
	decimal\
	ds\
	enchant\
	ev\
	event\
	excimer\
	exif\
	ffi\
	gd\
	gearman\
	geoip\
	geospatial\
	gettext\
	gmagick\
	gmp\
	gnupg\
	grpc\
	http\
	igbinary\
	imagick\
	imap\
	inotify\
	interbase\
	intl\
	ioncube_loader\
	jsmin\
	json_post\
	ldap\
	lzf\
	mailparse\
	maxminddb\
	mcrypt\
	memcache\
	memcached\
	mongo\
	mongodb\
	mosquitto\
	msgpack\
	mssql\
	mysql\
	mysqli\
	oauth\
	oci8\
	odbc\
	opcache\
	opencensus\
	parallel\
	pcntl\
	pcov\
	pdo_dblib\
	pdo_firebird\
	pdo_mysql\
	pdo_oci\
	pdo_odbc\
	pdo_pgsql\
	pdo_sqlsrv\
	pgsql\
	propro\
	protobuf\
	pspell\
	pthreads\
	raphf\
	rdkafka\
	recode\
	redis\
	seaslog\
	shmop\
	smbclient\
	snmp\
	snuffleupagus\
	soap\
	sockets\
	solr\
	spx\
	sqlsrv\
	ssh2\
	stomp\
	swoole\
	sybase_ct\
	sysvmsg\
	sysvsem\
	sysvshm\
	tensor\
	tidy\
	timezonedb\
	uopz\
	uploadprogress\
	uuid\
	vips\
	wddx\
	xdebug\
	xhprof\
	xlswriter\
	xmldiff\
	xmlrpc\
	xsl\
	yac\
	yaml\
	yar\
	zip\
	zookeeper\
	zstd\

DOCKER_BUILD=docker build \
	--build-arg PHP_VERSION=$(PHP_VERSION) \
	--build-arg PHP_DISTRO=$(PHP_DISTRO) \
	--build-arg DOCKER_REPO=$(DOCKER_REPO) \
	--build-arg PHP_EXT=$(PHP_EXT) \
	-t $(DOCKER_REPO)/php:$* \
	-f $(DOCKERFILE) \
	.

IMAGES_CLEAN=$(foreach v, $(PHP_VERSIONS), $(foreach d, $(PHP_DISTROS), .build/$v-$d))
IMAGES_EXT=$(foreach c, $(IMAGES_CLEAN), $(foreach e, $(PHP_EXTS), $c-ext-$e))
IMAGES_BUILD=$(IMAGES_CLEAN:%=%-build)
IMAGES_ALL=$(IMAGES_BUILD) $(IMAGES_EXT)

$(IMAGES_ALL): PHP_VERSION=$(word 1,$(subst -, ,$*))
$(IMAGES_ALL): PHP_DISTRO=$(word 2,$(subst -, ,$*))
$(IMAGES_ALL): PHP_EXT=

# @TODO Run builds in parallel
.PHONY: all
all: $(IMAGES_ALL)

# @TODO Remove build dependendies from PHP official images
$(IMAGES_CLEAN): DOCKERFILE=Dockerfile.clean
$(IMAGES_CLEAN): .build/%: Dockerfile.clean
	@mkdir -p .build; touch $@

$(IMAGES_BUILD): DOCKERFILE=Dockerfile.build
$(IMAGES_BUILD): .build/%: Dockerfile.build
	@$(DOCKER_BUILD)
	@mkdir -p .build; touch $@

$(IMAGES_EXT): DOCKERFILE=Dockerfile.ext
$(IMAGES_EXT): PHP_EXT_RAW=$(word 4,$(subst -, ,$*))
$(IMAGES_EXT): PHP_EXT=$(if $(PHP_EXT_RAW:composer=),$(PHP_EXT_RAW),@composer)
$(IMAGES_EXT): .build/%: Dockerfile.build Dockerfile.ext
	@$(DOCKER_BUILD)
	@mkdir -p .build; touch $@
