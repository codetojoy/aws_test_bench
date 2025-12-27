#!/bin/bash

set -e

echo "Building application..."
./gradlew clean build

echo "Creating deployment package..."
DEPLOY_DIR="deploy"
DEPLOY_ZIP="hello-world-app.zip"

# Clean up any previous deployment directory
rm -rf $DEPLOY_DIR
rm -f $DEPLOY_ZIP

# Create deployment directory
mkdir -p $DEPLOY_DIR

# Copy the JAR file
cp build/libs/hello-world-api-1.0.0.jar $DEPLOY_DIR/

# Copy Procfile only
cp Procfile $DEPLOY_DIR/

# Create the zip file
cd $DEPLOY_DIR
zip -r ../$DEPLOY_ZIP .
cd ..

# Clean up deployment directory
rm -rf $DEPLOY_DIR

echo "Deployment package created: $DEPLOY_ZIP"
echo "Upload this file to AWS Elastic Beanstalk"
