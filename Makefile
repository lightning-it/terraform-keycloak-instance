KEYCLOAK_COMPOSE := tests/keycloak-local/docker-compose.yml
KEYCLOAK_TEST_DIR := tests/keycloak-local

.PHONY: keycloak-up keycloak-down wait-keycloak test-local

keycloak-up:
	docker compose -f $(KEYCLOAK_COMPOSE) up -d

keycloak-down:
	docker compose -f $(KEYCLOAK_COMPOSE) down -v

wait-keycloak:
	@echo "Waiting for Keycloak to become ready on http://localhost:9000/health/ready..."
	@until curl -sf http://localhost:9000/health/ready > /dev/null; do \
		printf "."; \
		sleep 3; \
	done; \
	echo " Keycloak is ready."

test-local: keycloak-up wait-keycloak
	# Terraform init + apply using wunder-devtools-ee
	bash scripts/wunder-devtools-ee.sh terraform -chdir=$(KEYCLOAK_TEST_DIR) init -input=false
	bash scripts/wunder-devtools-ee.sh terraform -chdir=$(KEYCLOAK_TEST_DIR) apply -auto-approve -input=false
	$(MAKE) keycloak-down
