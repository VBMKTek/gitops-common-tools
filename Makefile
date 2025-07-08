# Common Tools Makefile
NAMESPACE = common-tools
CHART_NAME = common-tools
RELEASE_NAME = common-tools

.PHONY: help install upgrade uninstall status logs clean test

help:	## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install:	## Install the chart
	helm install $(RELEASE_NAME) . -n $(NAMESPACE) --create-namespace

upgrade:	## Upgrade the chart
	helm upgrade $(RELEASE_NAME) . -n $(NAMESPACE)

uninstall:	## Uninstall the chart
	helm uninstall $(RELEASE_NAME) -n $(NAMESPACE)

status:		## Show release status
	helm status $(RELEASE_NAME) -n $(NAMESPACE)

# Keycloak specific commands
logs-keycloak:	## Show Keycloak logs
	kubectl logs -n $(NAMESPACE) deployment/keycloak -f

restart-keycloak:	## Restart Keycloak deployment
	kubectl rollout restart deployment/keycloak -n $(NAMESPACE)

keycloak-url:	## Get Keycloak URL
	@echo "Keycloak Admin Console: http://localhost:30080/admin"
	@echo "Keycloak URL: http://localhost:30080"

# Database commands
create-keycloak-db:	## Create Keycloak database in PostgreSQL
	kubectl exec -n core-infra deployment/postgres -- psql -U postgres -c "CREATE DATABASE keycloak;"
	kubectl exec -n core-infra deployment/postgres -- psql -U postgres -c "CREATE USER keycloak WITH PASSWORD 'changeme';"
	kubectl exec -n core-infra deployment/postgres -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;"

test-keycloak:	## Test Keycloak connection
	@echo "Testing Keycloak health..."
	curl -f http://localhost:30080/health || echo "Keycloak not ready yet"

# General commands
clean:		## Clean up all resources
	kubectl delete namespace $(NAMESPACE) --ignore-not-found=true

pods:		## Show all pods
	kubectl get pods -n $(NAMESPACE) -o wide

services:	## Show all services
	kubectl get services -n $(NAMESPACE) -o wide

pvcs:		## Show all PVCs
	kubectl get pvc -n $(NAMESPACE)

describe-keycloak:	## Describe Keycloak deployment
	kubectl describe deployment keycloak -n $(NAMESPACE)

events:		## Show namespace events
	kubectl get events -n $(NAMESPACE) --sort-by=.metadata.creationTimestamp
