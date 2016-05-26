.SILENT:
.PHONY: help

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

###############
# Environment #
###############

## Setup environment & Install & Build application
setup:
	vagrant up --no-provision
	vagrant provision
	vagrant ssh -- "cd /srv/app && make install build"

## Update environment
update:
	vagrant provision --provision-with update

## Provision environment
provision:
	vagrant provision --provision-with provision

###########
# Install #
###########

## Install application
install:
	# Composer
	composer --no-progress --no-interaction install
	# Db
	bin/console doctrine:database:create --if-not-exists
	bin/console doctrine:schema:update --force
	# Db - Test
	bin/console doctrine:database:create --if-not-exists --env=test
	bin/console doctrine:schema:update --force --env=test
	# Db - Fixtures
	#bin/console doctrine:fixtures:load -n
	# Db - Fixtures - Test
	#bin/console doctrine:fixtures:load -n --env=test
	# Npm
	npm --no-spin install

install@test:
	# Composer
	SYMFONY_ENV=test composer --no-progress --no-interaction install
	# Db
	bin/console doctrine:database:create --if-not-exists --env=test
	bin/console doctrine:schema:update --force --env=test
	# Db - Fixtures
	#bin/console doctrine:fixtures:load -n --env=test
	# Npm
	npm --no-spin install

install@prod: install-dep
	# Composer
	#composer --no-progress --no-interaction install
	# Npm
	npm --no-spin install

#########
# Build #
#########

## Build application
build:
	#gulp --dev

build@prod:
	#gulp

########
# Lint #
########

## Run lint tools
lint:
    phpcs src --standard=PSR2

########
# Test #
########

## Run tests
test:
	# PHPUnit
	vendor/bin/phpunit
	# Behat
	bin/console cache:clear --env=test && vendor/bin/behat

test@test:
	# PHPUnit
	rm -Rf build/phpunit && mkdir -p build/phpunit
	stty cols 80 && vendor/bin/phpunit --log-junit build/phpunit/junit.xml --coverage-clover build/phpunit/clover.xml --coverage-html build/phpunit/coverage
	# Behat
	rm -Rf build/behat && mkdir -p build/behat
	bin/console cache:clear --env=test && vendor/bin/behat --format=junit --out=build/behat --no-interaction

##########
# Deploy #
##########

## Deploy application (demo)
deploy@demo:

## Deploy application (prod)
deploy@prod:

##########
# Custom #
##########
