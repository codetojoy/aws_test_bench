#!/bin/bash

set -e

if [[ -n "$AWS_ACCESS_KEY_ID" && "$AWS_ACCESS_KEY_ID" != "CHANGE_ME" ]]; then
    echo ""
else
    echo "AWS_ACCESS_KEY_ID is not set"
    exit -1
fi

if [[ -n "$AWS_SECRET_ACCESS_KEY" && "$AWS_SECRET_ACCESS_KEY" != "CHANGE_ME" ]]; then
    echo ""
else
    echo "AWS_SECRET_ACCESS_KEY is not set"
    exit -1
fi

aws s3 ls

echo "Ready."
