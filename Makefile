#!/usr/bin/make

DB_URL="postgresql://root:secret@postgres_go:5432/simple_bank?sslmode=disable"
GO_VERSION=1.18

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

MIGRATE=\
				podman run --rm \
				-v ${ROOT_DIR}/db/migration:/db/migration \
				--network bank-network \
				docker.io/migrate/migrate

postgres:
	podman network create bank-network
	podman run --rm \
		--name postgres_go \
		--network bank-network \
		-p 5432:5432 \
		-e POSTGRES_USER=root \
		-e POSTGRES_PASSWORD=secret \
		-e POSTGRES_DB=simple_bank \
		-d docker.io/postgres:14-alpine

	sleep 5

postgres_stop:
	podman stop postgres_go
	podman network rm -f bank-network

migrate:
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

server:
	go run main.go
