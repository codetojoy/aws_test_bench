#!/bin/bash

docker run --rm -p 9000:9000 -e APPLICATION_SECRET=$APPLICATION_SECRET play-ex-02

