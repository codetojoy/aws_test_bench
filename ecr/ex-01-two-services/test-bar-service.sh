#!/bin/bash

curl http://$1:5150/api/message | jq

echo ""
echo "Ready."
