KEYCLOAK_COMPOSE := tests/keycloak-smoke/docker-compose.yml
KEYCLOAK_TEST_DIRS := tests/keycloak-smoke tests/keycloak-advanced tests/keycloak-empty

.PHONY: keycloak-up keycloak-down wait-keycloak test-keycloak

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

test-keycloak:
	@set -e; \
	trap '$(MAKE) keycloak-down >/dev/null 2>&1 || true' EXIT; \
	$(MAKE) keycloak-down >/dev/null 2>&1 || true; \
	$(MAKE) keycloak-up; \
	$(MAKE) wait-keycloak; \
	for dir in $(KEYCLOAK_TEST_DIRS); do \
		echo "=== Running $$dir ==="; \
		rm -rf $$dir/.terraform $$dir/terraform.tfstate $$dir/terraform.tfstate.backup $$dir/.terraform.lock.hcl; \
		bash scripts/wunder-devtools-ee.sh terraform -chdir=$$dir init -input=false || exit $$?; \
		bash scripts/wunder-devtools-ee.sh terraform -chdir=$$dir apply -auto-approve -input=false || exit $$?; \
	done
