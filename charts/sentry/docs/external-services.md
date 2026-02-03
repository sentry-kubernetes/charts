# External Services Configuration

As the Sentry chart moves away from bundled dependencies (due to upstream deprecations and maintenance overhead), using external services is becoming the standard for production deployments.

This guide outlines how to configure the various external services required by Sentry.

## ClickHouse

**Status: REQUIRED**

The bundled ClickHouse chart has been removed. You must provide an external ClickHouse endpoint.

- [ClickHouse Setup Guide](external-clickhouse.md)

## Kafka

**Status: Recommended**

Sentry relies heavily on Kafka. While a bundled Kafka is available, managed Kafka services (like Confluent or MSK) or a dedicated Kafka operator (like Strimzi) are recommended for production.

See `externalKafka` in `values.yaml` for configuration options.

## PostgreSQL

**Status: Recommended**

Sentry uses PostgreSQL as its primary datastore. A bundled PostgreSQL is available for convenience, but an external database (e.g., RDS, Cloud SQL) is strongly recommended for production data integrity and management.

See `externalPostgresql` in `values.yaml` for configuration options.

## Redis

**Status: Recommended**

Redis is used for caching and queuing.

See `externalRedis` in `values.yaml` for configuration options.
