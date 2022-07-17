#!/usr/bin/make

DB_URL="postgresql://root:secret@postgres_go:5432/simple_bank?sslmode=disable"
GO_VERSION=1.18

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

MIGRATE=\
				podman run --rm \
				-v ${ROOT_DIR}/db/migration:/db/migration \
				--network bank-network \
				docker.io/migrate/migrate

network:
	podman network create bank-network

postgres:
	podman run --rm \
		--name postgres_go \
		--network bank-network \
		-p 5432:5432 \
		-e POSTGRES_USER=root \
		-e POSTGRES_PASSWORD=secret \
		-d docker.io/postgres:14-alpine

postgres_stop:
	podman stop postgres_go
	podman network rm bank-network

create_db:
	podman exec -it postgres_go createdb \
		--username=root \
		--owner=root \
		simple_bank

drop_db:
	podman exec -it docker.io/postgres \
		dropdb \
		simple_bank

migrate_up:
	$(MIGRATE) \
		-path db/migration \
		-database "$(DB_URL)" \
		-verbose up

migrate_down:
	$(MIGRATE) \
		-path db/migration \
		-database "$(DB_URL)" \
		-verbose down \
		-all

test:
	go test -v -cover ./...

sqlc_generate:
	podman run --rm \
		-v ${ROOT_DIR}:/src \
		-w /src \
		docker.io/kjconroy/sqlc \
		generate

