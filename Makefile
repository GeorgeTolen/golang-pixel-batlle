include .env
export

SHELL := C:/Program Files/Git/bin/bash.exe
.SHELLFLAGS := -c

DB_URL := postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@battle-postgres:5432/$(POSTGRES_DB)?sslmode=disable

.PHONY: env-up env-down env-cleanup env-logs env-psql env-port-forward env-port-close migrate-create migrate-up migrate-down migrate-version migrate-action

env-up:
	docker compose up -d battle-postgres

env-down:
	docker compose down

env-logs:
	docker compose logs -f battle-postgres

env-psql:
	docker compose exec battle-postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

env-cleanup:
	@read -p "Ebanet po DB? are you sure? [y/N] " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down -v && \
		rm -rf out/pgdata && \
		echo "DB dropped and data removed."; \
	else \
		echo "Aborting."; \
	fi

env-port-forward:
	-docker rm -f battle-env-port-forwarding 2>/dev/null
	docker compose run -d --rm --service-ports --name battle-env-port-forwarding port-forwarder

env-port-close:
	-docker rm -f battle-env-port-forwarding

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Error: seq variable is not set. Usage: make migrate-create seq=your_migration_name"; \
		exit 1; \
	fi
	docker compose run --rm battle-postgres-migrate \
		create -ext sql -dir //migrations -seq "$(seq)"

migrate-up:
	@$(MAKE) migrate-action action=up

migrate-down:
	@$(MAKE) migrate-action action="down 1"

migrate-version:
	docker compose run --rm battle-postgres-migrate \
		-path=//migrations -database "$(DB_URL)" version

migrate-force:
	@if [ -z "$(v)" ]; then \
		echo "Error: v variable is not set. Usage: make migrate-force v=0"; \
		exit 1; \
	fi
	docker compose run --rm battle-postgres-migrate \
		-path=//migrations -database "$(DB_URL)" force $(v)

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Error: action variable is not set. Usage: make migrate-action action=up"; \
		exit 1; \
	fi
	docker compose run --rm battle-postgres-migrate \
		-path=//migrations \
		-database "$(DB_URL)" \
		$(action)


