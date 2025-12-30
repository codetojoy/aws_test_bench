#!/bin/bash

docker run --name bar-service --network foo-bar-net -p 5150:5150 codetojoy/bar-service:latest 
