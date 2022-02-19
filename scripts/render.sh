#!/bin/sh

TEMPLATE_FILE=$1

write_approle_credentials() {
    vault read -field=role_id auth/approle/role/${ROLE_NAME}/role-id > /tmp/role-id
    vault write -field=secret_id -f auth/approle/role/${ROLE_NAME}/secret-id > /tmp/secret-id
}

write_approle_credentials
vault agent -log-level=trace -config=/app/templates/${TEMPLATE_FILE}
