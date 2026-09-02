# SecureDelivery

Plataforma de monitoramento da qualidade de entregas. Delivery-quality monitoring platform.

## Documentação / Documentation

- [Português (Brasil)](docs/pt-BR/README.md)
- [English](docs/en/README.md)
- [Contratos canônicos](docs/contracts/README.md)
- [Glossário bilíngue](docs/terminology.md)

## CI

```bash
npm ci
npm run ci
```

[Guia simples de CI/CD](docs/pt-BR/ci-cd.md) · [Simple CI/CD guide](docs/en/ci-cd.md)

## Repositories

- `securedelivery-server` — NestJS backend and central source of truth.
- `securedelivery-mobile` — Mobile application acting as the MVP IoT device.
- `securedelivery-dashboard` — Management and monitoring dashboard.

## Repository-specific architecture

- `securedelivery-server/docs/architecture.md`
- `securedelivery-mobile/docs/architecture.md`
- `securedelivery-dashboard/docs/architecture.md`

## Desenvolvimento local / Local development

The local environment is orchestrated through:

`docker-compose.local.yml`
