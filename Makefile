COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_DIR := $(shell awk -F= '/^DATA_DIR=/{print $$2}' srcs/.env)

all: up

up:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@$(COMPOSE) up -d --build | cat

down:
	@$(COMPOSE) down

logs:
	@$(COMPOSE) logs -f | cat

clean:
	@$(COMPOSE) down -v

fclean:
	@$(COMPOSE) down -v --rmi local || true
	@rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

re: fclean up

.PHONY: all up down clean fclean re logs