DOCKER=docker-compose --env-file .env --file docker/docker-compose.yaml
DEV_USER:=admin
SERVICES:=

.PHONY: migrate
migrate:
	python manage.py makemigrations
	python manage.py migrate

.PHONY: dev-createsuperuser
dev-createsuperuser:
	DJANGO_SUPERUSER_PASSWORD=${DEV_USER} \
		python manage.py createsuperuser \
		--username ${DEV_USER} \
		--email ${DEV_USER}@opensciencelabs.org \
		--noinput

.PHONY: dev-migrate
dev-migrate: migrate dev-createsuperuser

.PHONY: run-tests
run-tests:
	pytest


.PHONY: run-server
run-server:
	python manage.py runserver


# DOCKER

.PHONY:docker-build
docker-build:
	$(DOCKER) build
	$(DOCKER) pull


.PHONY:docker-start
docker-start:
	$(DOCKER) up -d ${SERVICES}


.PHONY:docker-stop
docker-stop:
	$(DOCKER) stop ${SERVICES}


.PHONY:docker-restart
docker-restart: docker-stop docker-start
	echo "[II] Docker services restarted!"


.PHONY:docker-logs
docker-logs:
	$(DOCKER) logs --follow --tail 100 ${SERVICES}

.PHONY: docker-wait
docker-wait:
	echo ${SERVICES} | xargs -t -n1 ./docker/healthcheck.sh

.PHONY:docker-dev-prepare-db
docker-dev-prepare-db:
	# used for development
	$(DOCKER) exec -T poc-django bash /opt/poc-django/docker/prepare-db.sh

.PHONY:docker-bash
docker-bash:
	$(DOCKER) exec ${SERVICE} bash

.PHONY:docker-run-bash
docker-run-bash:
	$(DOCKER) run --rm ${SERVICE} bash
