#Using a makefile instead of something fancy because I dont plan to touch this too often

imagefile := image.txt
IMAGE := $(shell cat ${imagefile})
BUILD_DIR := build/
.PHONY: build

build:
	docker build -t $(IMAGE) $(BUILD_DIR) --no-cache
shell:
	docker run -it --rm $(IMAGE) /bin/bash
push:
	docker image push $(IMAGE)
