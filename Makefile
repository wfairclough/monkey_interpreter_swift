# Makefile monkey 

lint:
	swift run swiftlint

build: lint
	swift build

test: lint
	swift test

.PHONY: lint build test

