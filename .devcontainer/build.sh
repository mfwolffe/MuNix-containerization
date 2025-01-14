#!/bin/sh

export DOCKER_BUILDKIT=1

docker buildx create --name mubuilda --driver docker-container --use

docker build -t mudev .

