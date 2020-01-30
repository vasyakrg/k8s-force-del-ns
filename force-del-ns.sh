#!/bin/bash

set -eo pipefail

function die() {
    echo "$*" 1>&2
    exit 1
}

function need() {
    which "$1" &>/dev/null || die "Binary app '$1' is missing but required"
}

function killproxy () {
    kill $PROXY_PID
}

# checking pre-reqs

need "jq"
need "curl"
need "kubectl"

# ENVs
# ================ #
# Example = "rancher.domain.com/k8s/clusters/c-fpbch"
SERVER=

# Example 'default'
NS=$1

# From '~/.kube/config', Example 'kubeconfig-user-bmtpd.c-fpbch:b6wjrdltp5qxrg5h6zrn479grmmf666d49w8gtq8sg4twz8wxrcbkh'
TOKEN=
# ================ #

test -n "$SERVER" || die "Missing arguments: kill-ns <server>"
test -n "$NS" || die "Missing arguments: kill-ns <namespace>"
test -n "$TOKEN" || die "Missing arguments: kill-ns <token>"

kubectl proxy &>/dev/null &
PROXY_PID=$!

trap killproxy EXIT

sleep 1

kubectl get namespace "$NS" 2> /dev/null || die "Namespace '$NS' not found or already deleted"

kubectl get namespace "$NS" -o json > out.log

kubectl get namespace "$NS" -o json | jq 'del(.spec.finalizers[] | select("kubernetes"))' | \
    curl -s -k -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -X PUT --data-binary @- https://$SERVER/api/v1/namespaces/$NS/finalize && echo "Killed namespace: $NS"
