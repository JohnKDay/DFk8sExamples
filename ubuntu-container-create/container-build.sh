#!/usr/bin/env bash 

docker build -t johnkday/counter:1.0 .
docker push johnkday/counter:1.0
