DOCKER_TAG ?= docker-duplicity-cron

.PHONY: default
default: build-x86

.PHONY: test
test: test-x86

.PHONY: build-x86
build-x86:
	docker build -f ./Dockerfile.ubuntu -t $(DOCKER_TAG):ubuntu .

.PHONY: build-arm
build-arm:
	docker build -f ./Dockerfile.raspbian -t $(DOCKER_TAG):raspbian .

.PHONY: build-all
build-all: build-x86 build-arm

.PHONY: test-x86
test-x86: build-x86
	./test.sh $(DOCKER_TAG):ubuntu

.PHONY: test-arm
test-arm: build-arm
	./test.sh $(DOCKER_TAG):raspbian

.PHONY: test-all
test-all: test-x86 test-arm

.PHONY: test-s3-x86
test-s3-x86:
	./test-s3.sh ubuntu

.PHONY: test-s3-arm
test-s3-arm:
	./test-s3.sh raspbian

.PHONY: test-s3-all
test-s3-all: test-s3-x86 test-s3-arm

.PHONY: shell-x86
shell-x86: build-x86
	docker run --rm -it $(DOCKER_TAG):ubuntu bash

.PHONY: shell-arm
shell-arm: build-arm
	docker run --rm -it $(DOCKER_TAG):raspbian bash

.PHONY: shell
shell: shell-x86
