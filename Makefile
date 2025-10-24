USER_LOGIN = $(shell whoami)
USER_HOME = $(HOME)
DOMAIN_NAME = $(USER_LOGIN).42.fr

SECRETS_DIR = ./secrets
DATA_DIR = $(HOME)/data
COMPOSE_FILE = ./srcs/docker-compose.yml

# Secret files
DB_ROOT_PASS = $(SECRETS_DIR)/db_root_password.txt
DB_PASS = $(SECRETS_DIR)/db_password.txt
WP_ADMIN_PASS = $(SECRETS_DIR)/wp_admin_password.txt
WP_USER_PASS = $(SECRETS_DIR)/wp_user_password.txt
FTP_USER_PASS = $(SECRETS_DIR)/ftp_user_password.txt
REDIS_PASS = $(SECRETS_DIR)/redis_password.txt

all: setup build up

setup: env-file secrets data-dirs

env-file:
	@if [ ! -f ./srcs/.env ]; then \
		echo "DOMAIN_NAME=$(DOMAIN_NAME)" > ./srcs/.env; \
		echo "MYSQL_HOST=mariadb" >> ./srcs/.env; \
		echo "MYSQL_DATABASE=wordpress" >> ./srcs/.env; \
		echo "MYSQL_USER=wordpress_user" >> ./srcs/.env; \
		echo "WP_ADMIN_USER=$(USER_LOGIN)" >> ./srcs/.env; \
		echo "WP_ADMIN_EMAIL=$(USER_LOGIN)@42.fr" >> ./srcs/.env; \
		echo "WP_USER=wpuser" >> ./srcs/.env; \
		echo "WP_USER_EMAIL=wpuser@42.fr" >> ./srcs/.env; \
		echo "WP_TITLE=Inception" >> ./srcs/.env; \
		echo "WP_URL=https://$(DOMAIN_NAME)" >> ./srcs/.env; \
		echo "FTP_USER=$(USER_LOGIN)" >> ./srcs/.env; \
		echo "Generated .env file";\
	fi

secrets:
	@mkdir -p $(SECRETS_DIR)
	@if [ ! -f $(DB_ROOT_PASS) ]; then \
		openssl rand -base64 32 > $(DB_ROOT_PASS); \
		echo "Generated db_root_password"; \
	fi
	@if [ ! -f $(DB_PASS) ]; then \
		openssl rand -base64 32 > $(DB_PASS); \
		echo "Generated db_password"; \
	fi
	@if [ ! -f $(WP_ADMIN_PASS) ]; then \
		openssl rand -base64 32 > $(WP_ADMIN_PASS); \
		echo "Generated wp_admin_password"; \
	fi
	@if [ ! -f $(WP_USER_PASS) ]; then \
		openssl rand -base64 32 > $(WP_USER_PASS); \
		echo "Generated wp_user_password"; \
	fi
	@if [ ! -f $(FTP_USER_PASS) ]; then \
		openssl rand -base64 32 > $(FTP_USER_PASS); \
		echo "Generated ftp_user_password"; \
	fi
	@if [ ! -f $(REDIS_PASS) ]; then \
		openssl rand -base64 32 > $(REDIS_PASS); \
		echo "Generated redis_password"; \
	fi

data-dirs:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/redis
	@mkdir -p $(DATA_DIR)/netdata/lib
	@mkdir -p $(DATA_DIR)/netdata/cache
	@mkdir -p $(DATA_DIR)/netdata/config

build:
	docker-compose -f $(COMPOSE_FILE) build

up:
	docker-compose -f $(COMPOSE_FILE) up -d

down:
	docker-compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -af
	docker volume prune -f

fclean: clean
	@docker run --rm -v $(DATA_DIR):/data alpine sh -c "chmod -R 777 /data && rm -rf /data/*" 2>/dev/null || true
	@rm -rf $(DATA_DIR)
	@docker volume rm inception_mariadb-data 2>/dev/null || true
	@docker volume rm inception_wordpress-data 2>/dev/null || true
	@docker volume rm inception_redis-data 2>/dev/null || true
	@docker volume rm inception_netdatacache 2>/dev/null || true
	@docker volume rm inception_netdataconfig 2>/dev/null || true
	@docker volume rm inception_netdatalib 2>/dev/null || true
	@rm -rf $(SECRETS_DIR)
	@rm -rf ./srcs/.env
	@echo "Full clean complete"

re: fclean all

logs:
	docker-compose logs -f

.PHONY: all setup env-file secrets data-dirs build up down clean fclean re logs
