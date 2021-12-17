
DAGSTER_VERSION=0.13.11
DOCKER_BASE_IMAGE_VERSION=python:3.7.8-slim

.PHONY: docker_build
docker_build:
	docker build -t project-example --build-arg BASE_IMAGE=$(DOCKER_BASE_IMAGE_VERSION) --build-arg DAGSTER_VERSION=$(DAGSTER_VERSION) .
