SHELL := /usr/bin/env bash

.PHONY: help build checksum clean

help:
	@echo "AETHER OS developer commands"
	@echo "  make build      Build the live ISO (Arch Linux + archiso)"
	@echo "  make checksum   Print the ISO SHA-256 checksum"
	@echo "  make clean      Remove local build output"

build:
	bash scripts/build-iso.sh

checksum:
	bash scripts/check-iso.sh

clean:
	rm -rf .work out
