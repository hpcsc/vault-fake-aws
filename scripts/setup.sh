#!/bin/sh

TIMEOUT_PERIOD=30
DELAY=2

rm -rf /app/tmp && mkdir -p /app/tmp

function wait_for() {
    set +e
    local service=$1
    shift
    local cmd=$@
    local t=$TIMEOUT_PERIOD

    eval "${cmd}"
    until [ $? = 0 ]  ; do
        t=$((t - DELAY))
        if [[ $t -eq 0 ]]; then
            echo "=== ${service} is not up after $TIMEOUT_PERIOD seconds"
            set -e
            exit 1
        fi

        echo "=== ${service} is not up yet, remaining time: $t seconds"
        sleep $DELAY
        eval "${cmd}"
    done

    echo "=== ${service} is up"
    set -e
}

setup_approle_auth() {
    local role_name=$1
    local aws_role_name=$2
    if [ -z "$(vault auth list | grep approle)" ]; then
        vault auth enable approle
    fi

    vault policy write ${role_name} - <<EOF
path "awskv/sts/${AWS_ROLE_NAME}" {
    capabilities = ["read"]
}
path "awsmoto/sts/${AWS_ROLE_NAME}" {
    capabilities = ["read", "update"]
}
EOF

    vault write auth/approle/role/${ROLE_NAME} \
        secret_id_ttl=10m \
        token_num_uses=10 \
        token_ttl=20m \
        token_max_ttl=30m \
        secret_id_num_uses=40 \
        policies=${ROLE_NAME}
}

setup_fake_aws_by_kv1() {
    if [ -z "$(vault secrets list | grep awskv)" ]; then
        vault secrets enable -version=1 -path=awskv kv
    fi

    vault kv put awskv/sts/${AWS_ROLE_NAME} access_key=test secret_key=test security_token=test
}

setup_fake_aws_by_moto() {
    if [ -z "$(vault secrets list | grep awsmoto)" ]; then
        vault secrets enable -path=awsmoto aws
    fi

    vault write awsmoto/config/root \
        access_key=test \
        secret_key=test \
        region=us-east-1 \
        iam_endpoint=http://moto:5000 \
        sts_endpoint=http://moto:5000

    vault write awsmoto/roles/${AWS_ROLE_NAME} \
        role_arns=arn:aws:iam::000000000000:role/${AWS_ROLE_NAME} \
        credential_type=assumed_role
}

wait_for vault "vault status"
setup_approle_auth cli my-aws-role
setup_fake_aws_by_kv1 my-aws-role
setup_fake_aws_by_moto my-aws-role
