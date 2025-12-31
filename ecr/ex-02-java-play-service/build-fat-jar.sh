#!/bin/bash

set -e

echo "Building fat JAR with sbt assembly..."
sbt clean assembly

echo "Creating deployment package..."
JAR_FILE=target/scala-2.13/play-ex-02.jar

if [ ! -f "$JAR_FILE" ]; then
    echo "Error: JAR file not found at $JAR_FILE"
    exit 1
fi

# For Beanstalk Java platform, we can deploy the JAR directly
# or create a zip with a Procfile
cp $JAR_FILE ./play-ex-02.jar

echo "Ready."
echo "JAR size: $(ls -lh play-ex-02.jar | awk '{print $5}')"
