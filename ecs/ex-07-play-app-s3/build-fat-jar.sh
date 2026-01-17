#!/bin/bash

set -e

echo "Building fat JAR with sbt assembly..."
sbt clean assembly

echo "Creating deployment package..."
JAR_FILE=target/scala-2.13/$FAT_JAR_NAME

if [ ! -f "$JAR_FILE" ]; then
    echo "Error: JAR file not found at $JAR_FILE"
    exit 1
fi

# For Beanstalk Java platform, we can deploy the JAR directly
# or create a zip with a Procfile
cp $JAR_FILE ./$FAT_JAR_NAME

echo "Ready."
echo "JAR size: $(ls -lh $FAT_JAR_NAME | awk '{print $5}')"
