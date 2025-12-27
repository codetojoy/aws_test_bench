# Fat JAR Deployment for AWS Beanstalk

## Overview
This approach uses sbt-assembly to create a fat JAR that can be deployed directly to AWS Beanstalk Java platform.

## Prerequisites
- sbt installed and available in PATH

## Build Steps

### 1. Build the fat JAR
```bash
./build-fat-jar.sh
```

Or manually:
```bash
sbt clean assembly
```

This will create: `target/scala-2.13/play-hello-world.jar`

### 2. Deploy to Beanstalk

The fat JAR can be deployed directly to AWS Beanstalk Java platform:

- Upload `target/scala-2.13/play-hello-world.jar` directly to Beanstalk

### 3. Configure Beanstalk Environment

You'll need to set environment variables in Beanstalk:

- `SERVER_PORT=5000` (Beanstalk expects port 5000)

Optionally create a `Procfile` to customize the startup:
```
web: java -Dhttp.port=5000 -Dplay.server.http.address=0.0.0.0 -jar play-hello-world.jar
```

## Files Modified

- `project/plugins.sbt` - Added sbt-assembly plugin
- `build.sbt` - Added assembly configuration with merge strategies
- `build-fat-jar.sh` - Build script for creating the fat JAR

## Notes

- The fat JAR includes all dependencies
- No need for `Buildfile`, `.ebextensions`, or complex setup
- Works directly with Java platform on Beanstalk
- Simpler deployment than the zip-based approach
