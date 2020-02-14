DOCKER_TAG ?= docker-duplicity-cron

.PHONY: default
default: build-amd64

.PHONY: all
all: build-all test-all test-s3-all

.PHONY: test
test: test-amd64

.PHONY: check
check:
	pre-commit run --all-files

.PHONY: build-amd64
build-amd64:
	docker build --build-arg REPO=library -f ./Dockerfile -t $(DOCKER_TAG):amd64 .

.PHONY: build-arm
build-arm:
	docker build --build-arg REPO=arm32v7 -f ./Dockerfile -t $(DOCKER_TAG):arm .

.PHONY: build-all
build-all: build-amd64 build-arm

.PHONY: test-amd64
test-amd64: build-amd64
	cd tests && ./test.sh $(DOCKER_TAG):amd64
	cd tests && ./test-pre-scripts.sh $(DOCKER_TAG):amd64

.PHONY: test-arm
test-arm: build-arm
	cd tests && ./test.sh $(DOCKER_TAG):arm
	cd tests && ./test-pre-scripts.sh $(DOCKER_TAG):arm

.PHONY: test-all
test-all: test-amd64 test-arm

.PHONY: test-s3-amd64
test-s3-amd64: build-amd64 clean-minio
	cd tests && ./test-compose.sh s3 $(DOCKER_TAG):amd64

.PHONY: test-s3-arm
test-s3-arm: build-arm clean-minio
	cd tests && ./test-compose.sh s3 $(DOCKER_TAG):arm

.PHONY: test-s3-all
test-s3-all: test-s3-amd64 test-s3-arm

.PHONY: shell-amd64
shell-amd64: build-amd64
	docker run --rm -it $(DOCKER_TAG):amd64 bash

.PHONY: shell-arm
shell-arm: build-arm
	docker run --rm -it $(DOCKER_TAG):arm bash

.PHONY: shell
shell: shell-amd64

# Installs pre-commit hooks
.PHONY: install-hooks
install-hooks:
	pre-commit install --install-hooks

.PHONY: clean
clean: clean-minio

.PHONY: clean-minio
clean-minio:
	docker-compose -f tests/docker-compose-test-s3.yml down -v
