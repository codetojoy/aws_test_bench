#!/bin/bash

set -e

check_env_var() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    if [[ -n "$var_value" && "$var_value" != "CHANGE_ME" ]]; then
        return 0
    else
        echo "$var_name is not set"
        exit 1
    fi
}

check_env_var "AWS_ACCESS_KEY_ID"
check_env_var "AWS_SECRET_ACCESS_KEY"

# -------------------------------------------
# main

terraform destroy 
