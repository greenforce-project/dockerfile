IMAGE ?= mhmmdfdlyas/dockerfile
PLATFORM ?= linux/amd64

.PHONY: build build-kernel build-rom build-toolchain verify

build: build-kernel build-rom build-toolchain

build-kernel:
	docker build --platform $(PLATFORM) -f ubuntu/kernel/Dockerfile -t $(IMAGE):k-ubuntu .

build-rom:
	docker build --platform $(PLATFORM) -f ubuntu/rom/Dockerfile -t $(IMAGE):r-ubuntu .

build-toolchain:
	docker build --platform $(PLATFORM) -f ubuntu/toolchain/Dockerfile -t $(IMAGE):t-ubuntu .

verify:
	./scripts/verify.sh $(IMAGE)
