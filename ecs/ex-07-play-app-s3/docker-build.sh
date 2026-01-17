#!/bin/bash

# Build the fat JAR first
./build-fat-jar.sh

# Build the Docker image
docker build -t $DOCKER_TAG .

