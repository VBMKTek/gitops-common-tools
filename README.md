# Common Tools

This Helm chart provides common tools and utilities for the VBMKTek platform.

## Components

### Currently Available
- **Keycloak** - Identity and Access Management (IAM)

### Future Ready
- **Elasticsearch** - Search and analytics engine
- **Kibana** - Data visualization dashboard
- **Grafana** - Monitoring and observability platform
- **Prometheus** - Metrics collection and monitoring

## Installation

```bash
# Install to common-tools namespace
helm install common-tools . -n common-tools --create-namespace

# Upgrade existing installation
helm upgrade common-tools . -n common-tools
```

## Prerequisites

### Database Setup
Keycloak requires a PostgreSQL database. If you have the `core-infra` chart installed, create the Keycloak database:

```bash
# Create Keycloak database
make create-keycloak-db
```

Or manually:
```bash
kubectl exec -n core-infra deployment/postgres -- psql -U postgres -c "CREATE DATABASE keycloak;"
kubectl exec -n core-infra deployment/postgres -- psql -U postgres -c "CREATE USER keycloak WITH PASSWORD 'changeme';"
kubectl exec -n core-infra deployment/postgres -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;"
```

## Configuration

### Keycloak
```yaml
keycloak:
  enabled: true
  persistence:
    enabled: true
    size: 5Gi
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
  service:
    type: NodePort
    nodePort: 30080
```

## Access URLs

After installation:

- **Keycloak Admin Console**: http://localhost:30080/admin
- **Keycloak**: http://localhost:30080

Default credentials:
- Username: `admin`
- Password: `changeme123`

## Makefile Commands

```bash
# Installation
make install          # Install the chart
make upgrade          # Upgrade the chart
make uninstall        # Uninstall the chart

# Keycloak specific
make logs-keycloak     # Show Keycloak logs
make restart-keycloak  # Restart Keycloak
make keycloak-url      # Get access URLs
make test-keycloak     # Test Keycloak health

# Database
make create-keycloak-db # Create Keycloak database

# Monitoring
make pods             # Show all pods
make services         # Show all services
make events           # Show recent events
```

## Security Notes

⚠️ **Important**: Change default passwords in production!

Update these values in `values.yaml`:
- `secrets.auth.keycloakAdminPassword`
- `secrets.auth.keycloakDbPassword`

## Troubleshooting

### Keycloak won't start
1. Check if PostgreSQL is running in `core-infra` namespace
2. Verify database credentials
3. Check logs: `make logs-keycloak`

### Database connection issues
1. Ensure Keycloak database exists: `make create-keycloak-db`
2. Check network connectivity between namespaces
3. Verify PostgreSQL service is accessible

### Resource issues
1. Check node resources: `kubectl top nodes`
2. Verify PVC is bound: `make pvcs`
3. Scale down if needed: `kubectl scale deployment keycloak --replicas=0 -n common-tools`

## Architecture

```
common-tools/
├── keycloak/           # Identity and Access Management
│   ├── deployment      # Keycloak application
│   ├── service         # HTTP/HTTPS endpoints
│   └── pvc            # Persistent storage
└── secrets/           # Credentials and connection strings
```

## Integration

Keycloak integrates with:
- **PostgreSQL** (core-infra) - Database backend
- **Applications** - OIDC/SAML authentication
- **API Gateway** - Token validation
- **Grafana** (future) - SSO authentication

## Next Steps

1. Configure realm and clients in Keycloak
2. Enable Grafana with Keycloak SSO
3. Add Elasticsearch and Kibana for logging
4. Setup Prometheus for monitoring
