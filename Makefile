DB_URL=postgresql://root:secret@postgres_go:5432/simple_bank?sslmode=disable

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

MIGRATE=docker run --rm -v ${ROOT_DIR}/db/migration:/db/migration --network bank-network migrate/migrate

network:
	docker network create bank-network

postgres:
	docker run --rm --name postgres_go --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:14-alpine

postgres_stop:
	docker stop postgres_go

create_db:
	docker exec -it postgres_go createdb --username=root --owner=root simple_bank

drop_db:
	docker exec -it postgres dropdb simple_bank

migrate_up:
	$(MIGRATE) -path db/migration -database "$(DB_URL)" -verbose up

migrate_down:
	$(MIGRATE) -path db/migration -database "$(DB_URL)" -verbose down

sqlc_generate:
	echo ${ROOT_DIR}
	docker run --rm -v ${ROOT_DIR}:/src -w /src kjconroy/sqlc generate