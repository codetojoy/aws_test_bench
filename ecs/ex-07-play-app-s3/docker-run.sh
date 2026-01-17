#!/bin/bash

docker run --rm \
-p 9000:9000 \
-e APPLICATION_SECRET=$APPLICATION_SECRET \
-e MY_FOOBAR="TRACER 5150" \
play-ecs-ex-07

