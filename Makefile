COREPATH ?= ./node_modules/brigadehub-core
PACKAGENAME ?= admin-gateway

start:
	node app.js

start/develop:
	@echo make install
	@$(MAKE) install
	yarn run nodemon -- app.js

start/develop/mongo:
	@echo make install
	@$(MAKE) install
	mongod -d
	yarn run nodemon -- app.js

lint:
	yarn run standard

link:
	yarn link brigadehub-public-c4sf
	yarn link brigadehub-admin-c4sf
	yarn link brigadehub-core

upstream/set:
	git remote add upstream https://github.com/brigadehub/$(PACKAGENAME).git

upstream/sync:
	git fetch upstream
	git checkout master
	git merge upstream/master

test:
	@echo make lint
	@$(MAKE) lint
	@echo make test/unit
	@$(MAKE) test/unit
	@echo make test/e2e
	@$(MAKE) test/e2e

test/unit:
	echo 'no unit tests available.'

test/e2e:
	# @echo make test/e2e/selenium/install
	# @$(MAKE) test/e2e/selenium/install
	# @echo make test/e2e/selenium/start
	# @$(MAKE) test/e2e/selenium/start
	echo 'no end-to-end tests available.'

test/e2e/selenium/install:
	yarn run selenium-standalone install

test/e2e/selenium/start:
	yarn run selenium-standalone start&

test/e2e/selenium/stop:
	pkill -f selenium-standalone

db/clear:
	$(COREPATH)/scripts/database-clear

db/seed:
	@echo make db/bootstrap
	@$(MAKE) db/bootstrap
	$(COREPATH)/scripts/database-seed

db/bootstrap:
	$(COREPATH)/scripts/database-bootstrap

db/migrate/up:
	@echo make db/bootstrap
	@$(MAKE) db/bootstrap
	yarn run db-migrate -- --config $(COREPATH)/config/database.json --migrations-dir $(COREPATH)/migrations up

db/migrate/down:
	@echo make db/bootstrap
	@$(MAKE) db/bootstrap
	yarn run db-migrate -- --config $(COREPATH)/config/database.json --migrations-dir $(COREPATH)/migrations down

install: .env
	yarn install
	@echo make db/migrate/up
	@$(MAKE) db/migrate/up

.env:
	cp .env.example .env

install/clean:
	rm -rf node_modules
	@echo make install
	@$(MAKE) install

build/docker:
	docker build -t brigadehub/$(PACKAGENAME) .

build/docker/run:
	docker run -d --name brigadehub -p 80:5465 -e MONGODB=mongodb://192.168.99.100:27017/brigadehub-docker brigadehub/$(PACKAGENAME)

build/docker/images:
	docker images brigadehub/$(PACKAGENAME)

build/docker/tag:
	echo "docker tag hash brigadehub/$(PACKAGENAME):release"

build/docker/push:
	docker push brigadehub/$(PACKAGENAME)

build/docker/untag:
	echo "docker rmi brigadehub/$(PACKAGENAME):release"

.PHONY: start lint test db install build link upstream
