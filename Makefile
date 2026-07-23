IMAGE ?= mhmmdfdlyas/dockerfile
PLATFORM ?= linux/amd64

.PHONY: \
	build build-ubuntu build-debian \
	build-kernel build-rom build-toolchain \
	build-debian-kernel build-debian-rom build-debian-toolchain \
	verify lint

build: build-ubuntu build-debian

build-ubuntu: build-kernel build-rom build-toolchain

build-debian: build-debian-kernel build-debian-rom build-debian-toolchain

build-kernel:
	docker build --platform $(PLATFORM) -f ubuntu/kernel/Dockerfile -t $(IMAGE):k-ubuntu -t $(IMAGE):k-ubuntu24.04 .

build-rom:
	docker build --platform $(PLATFORM) -f ubuntu/rom/Dockerfile -t $(IMAGE):r-ubuntu -t $(IMAGE):r-ubuntu22.04 .

build-toolchain:
	docker build --platform $(PLATFORM) -f ubuntu/toolchain/Dockerfile -t $(IMAGE):t-ubuntu -t $(IMAGE):t-ubuntu24.04 .

build-debian-kernel:
	docker build --platform $(PLATFORM) -f debian/kernel/Dockerfile -t $(IMAGE):k-debian -t $(IMAGE):k-debian12 .

build-debian-rom:
	docker build --platform $(PLATFORM) -f debian/rom/Dockerfile -t $(IMAGE):r-debian -t $(IMAGE):r-debian12 .

build-debian-toolchain:
	docker build --platform $(PLATFORM) -f debian/toolchain/Dockerfile -t $(IMAGE):t-debian -t $(IMAGE):t-debian12 .

verify:
	./scripts/verify.sh $(IMAGE)

lint:
	./scripts/lint-repository.sh
