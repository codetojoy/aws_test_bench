#!/bin/bash

docker run \
--network foo-bar-net \
-p 3000:3000 \
-e BAR_SERVICE_URL=http://bar-service:5150 \
codetojoy/foo-service:latest
