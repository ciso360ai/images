#!/bin/bash

set -eu -o pipefail

: "${BIND_ON_IP:=$(getent hosts "$(hostname)" | awk '{print $1;}')}"
export BIND_ON_IP

if [[ "${BIND_ON_IP}" == "0.0.0.0" || "${BIND_ON_IP}" == "::0" ]]; then
    : "${TEMPORAL_BROADCAST_ADDRESS:=$(getent hosts "$(hostname)" | awk '{print $1;}')}"
    export TEMPORAL_BROADCAST_ADDRESS
fi

# check TEMPORAL_ADDRESS is not empty
if [[ -z "${TEMPORAL_ADDRESS:-}" ]]; then
    echo "TEMPORAL_ADDRESS is not set, setting it to ${BIND_ON_IP}:7233"

    if [[ "${BIND_ON_IP}" =~ ":" ]]; then
        # ipv6
        export TEMPORAL_ADDRESS="[${BIND_ON_IP}]:7233"
    else
        # ipv4
        export TEMPORAL_ADDRESS="${BIND_ON_IP}:7233"
    fi
fi

# Support TEMPORAL_CLI_ADDRESS for backwards compatibility.
# TEMPORAL_CLI_ADDRESS is deprecated and support for it will be removed in the future release.
if [[ -z "${TEMPORAL_CLI_ADDRESS:-}" ]]; then
    export TEMPORAL_CLI_ADDRESS="${TEMPORAL_ADDRESS}"
fi

# === Auto setup defaults ===

: "${DB:=postgres12}"
: "${SKIP_SCHEMA_SETUP:=true}"
: "${SKIP_DB_CREATE:=true}"

# MySQL/PostgreSQL
: "${DBNAME:=temporal}"
: "${VISIBILITY_DBNAME:=temporal_visibility}"
: "${DB_PORT:=3306}"

: "${POSTGRES_SEEDS:=}"
: "${POSTGRES_USER:=}"
: "${POSTGRES_PWD:=}"

: "${POSTGRES_TLS_ENABLED:=false}"
: "${POSTGRES_TLS_DISABLE_HOST_VERIFICATION:=false}"
: "${POSTGRES_TLS_CERT_FILE:=}"
: "${POSTGRES_TLS_KEY_FILE:=}"
: "${POSTGRES_TLS_CA_FILE:=}"
: "${POSTGRES_TLS_SERVER_NAME:=}"

# Server setup
: "${TEMPORAL_ADDRESS:=}"
# TEMPORAL_CLI_ADDRESS is deprecated and support for it will be removed in the future release.
: "${TEMPORAL_CLI_ADDRESS:=}"

: "${SKIP_DEFAULT_NAMESPACE_CREATION:=true}"
: "${DEFAULT_NAMESPACE:=default}"
: "${DEFAULT_NAMESPACE_RETENTION:=24h}"

: "${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES:=true}"

# === Helper functions ===

die() {
    echo "$*" 1>&2
    exit 1
}

# === Main database functions ===

validate_db_env() {
    case ${DB} in
      postgres12 | postgres12_pgx)
          if [[ -z ${POSTGRES_SEEDS} ]]; then
              die "POSTGRES_SEEDS env must be set if DB is ${DB}."
          fi
          ;;
      *)
          die "Unsupported driver specified: 'DB=${DB}'. Valid drivers are: mysql8, postgres12, postgres12_pgx, cassandra."
          ;;
    esac
}

wait_for_postgres() {
    until nc -z "${POSTGRES_SEEDS%%,*}" "${DB_PORT}"; do
        echo 'Waiting for PostgreSQL to startup.'
        sleep 1
    done

    echo 'PostgreSQL started.'
}

wait_for_db() {
    case ${DB} in
      postgres12 | postgres12_pgx)
          wait_for_postgres
          ;;
      *)
          die "Unsupported DB type: ${DB}."
          ;;
    esac
}

setup_postgres_schema() {
    # TODO (alex): Remove exports
    export SQL_PASSWORD=${POSTGRES_PWD}

    POSTGRES_VERSION_DIR=v12
    SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/${POSTGRES_VERSION_DIR}/temporal/versioned
    # Create database only if its name is different from the user name. Otherwise PostgreSQL container itself will create database.
    if [[ ${DBNAME} != "${POSTGRES_USER}" && ${SKIP_DB_CREATE} != true ]]; then
        temporal-sql-tool \
            --plugin ${DB} \
            --ep "${POSTGRES_SEEDS}" \
            -u "${POSTGRES_USER}" \
            -p "${DB_PORT}" \
            --db "${DBNAME}" \
            --tls="${POSTGRES_TLS_ENABLED}" \
            --tls-disable-host-verification="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" \
            --tls-cert-file "${POSTGRES_TLS_CERT_FILE}" \
            --tls-key-file "${POSTGRES_TLS_KEY_FILE}" \
            --tls-ca-file "${POSTGRES_TLS_CA_FILE}" \
            --tls-server-name "${POSTGRES_TLS_SERVER_NAME}" \
            create
    fi
    temporal-sql-tool \
        --plugin ${DB} \
        --ep "${POSTGRES_SEEDS}" \
        -u "${POSTGRES_USER}" \
        -p "${DB_PORT}" \
        --db "${DBNAME}" \
        --tls="${POSTGRES_TLS_ENABLED}" \
        --tls-disable-host-verification="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" \
        --tls-cert-file "${POSTGRES_TLS_CERT_FILE}" \
        --tls-key-file "${POSTGRES_TLS_KEY_FILE}" \
        --tls-ca-file "${POSTGRES_TLS_CA_FILE}" \
        --tls-server-name "${POSTGRES_TLS_SERVER_NAME}" \
        setup-schema -v 0.0
    temporal-sql-tool \
        --plugin ${DB} \
        --ep "${POSTGRES_SEEDS}" \
        -u "${POSTGRES_USER}" \
        -p "${DB_PORT}" \
        --db "${DBNAME}" \
        --tls="${POSTGRES_TLS_ENABLED}" \
        --tls-disable-host-verification="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" \
        --tls-cert-file "${POSTGRES_TLS_CERT_FILE}" \
        --tls-key-file "${POSTGRES_TLS_KEY_FILE}" \
        --tls-ca-file "${POSTGRES_TLS_CA_FILE}" \
        --tls-server-name "${POSTGRES_TLS_SERVER_NAME}" \
        update-schema -d "${SCHEMA_DIR}"

    # Only setup visibility schema if ES is not enabled
    if [[ ${ENABLE_ES} == false ]]; then
      VISIBILITY_SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/${POSTGRES_VERSION_DIR}/visibility/versioned
      if [[ ${VISIBILITY_DBNAME} != "${POSTGRES_USER}" && ${SKIP_DB_CREATE} != true ]]; then
          temporal-sql-tool \
              --plugin ${DB} \
              --ep "${POSTGRES_SEEDS}" \
              -u "${POSTGRES_USER}" \
              -p "${DB_PORT}" \
              --db "${VISIBILITY_DBNAME}" \
              --tls="${POSTGRES_TLS_ENABLED}" \
              --tls-disable-host-verification="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" \
              --tls-cert-file "${POSTGRES_TLS_CERT_FILE}" \
              --tls-key-file "${POSTGRES_TLS_KEY_FILE}" \
              --tls-ca-file "${POSTGRES_TLS_CA_FILE}" \
              --tls-server-name "${POSTGRES_TLS_SERVER_NAME}" \
              create
      fi
      temporal-sql-tool \
          --plugin ${DB} \
          --ep "${POSTGRES_SEEDS}" \
          -u "${POSTGRES_USER}" \
          -p "${DB_PORT}" \
          --db "${VISIBILITY_DBNAME}" \
          --tls="${POSTGRES_TLS_ENABLED}" \
          --tls-disable-host-verification="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" \
          --tls-cert-file "${POSTGRES_TLS_CERT_FILE}" \
          --tls-key-file "${POSTGRES_TLS_KEY_FILE}" \
          --tls-ca-file "${POSTGRES_TLS_CA_FILE}" \
          --tls-server-name "${POSTGRES_TLS_SERVER_NAME}" \
          setup-schema -v 0.0
      temporal-sql-tool \
          --plugin ${DB} \
          --ep "${POSTGRES_SEEDS}" \
          -u "${POSTGRES_USER}" \
          -p "${DB_PORT}" \
          --db "${VISIBILITY_DBNAME}" \
          --tls="${POSTGRES_TLS_ENABLED}" \
          --tls-disable-host-verification="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" \
          --tls-cert-file "${POSTGRES_TLS_CERT_FILE}" \
          --tls-key-file "${POSTGRES_TLS_KEY_FILE}" \
          --tls-ca-file "${POSTGRES_TLS_CA_FILE}" \
          --tls-server-name "${POSTGRES_TLS_SERVER_NAME}" \
          update-schema -d "${VISIBILITY_SCHEMA_DIR}"
    fi
}

setup_schema() {
    case ${DB} in
      postgres12 | postgres12_pgx)
          echo 'Setup PostgreSQL schema.'
          setup_postgres_schema
          ;;
      *)
          die "Unsupported DB type: ${DB}."
          ;;
    esac
}

# === Server setup ===

register_default_namespace() {
    echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
    if ! temporal operator namespace describe "${DEFAULT_NAMESPACE}"; then
        echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
        temporal operator namespace create --retention "${DEFAULT_NAMESPACE_RETENTION}" --description "Default namespace for Temporal Server." "${DEFAULT_NAMESPACE}"
        echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
    else
        echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
    fi
}

add_custom_search_attributes() {
    until temporal operator search-attribute list --namespace "${DEFAULT_NAMESPACE}"; do
      echo "Waiting for namespace cache to refresh..."
      sleep 1
    done
    echo "Namespace cache refreshed."

    echo "Adding Custom*Field search attributes."
    # TODO: Remove CustomStringField
# @@@SNIPSTART add-custom-search-attributes-for-testing-command
    temporal operator search-attribute create --namespace "${DEFAULT_NAMESPACE}" \
        --name CustomKeywordField --type Keyword \
        --name CustomStringField --type Text \
        --name CustomTextField --type Text \
        --name CustomIntField --type Int \
        --name CustomDatetimeField --type Datetime \
        --name CustomDoubleField --type Double \
        --name CustomBoolField --type Bool
# @@@SNIPEND
}

setup_server(){
    echo "Temporal CLI address: ${TEMPORAL_ADDRESS}."

    until temporal operator cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    if [[ ${SKIP_DEFAULT_NAMESPACE_CREATION} != true ]]; then
        register_default_namespace
        if [[ ${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES} != true ]]; then
            add_custom_search_attributes
        fi
    fi
}

# === Main ===

if [[ ${SKIP_SCHEMA_SETUP} != true ]]; then
    validate_db_env
    wait_for_db
    setup_schema
fi

# Run this func in parallel process. It will wait for server to start and then run required steps.
setup_server &

exec temporal-server --env docker start