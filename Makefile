
# Check at https://developer.garmin.com/downloads/connect-iq/sdks/sdks.xml
VERSION := 3.2

all: build

build:
	@echo "+++ Building docker image +++"
	docker pull ubuntu:18.04
	docker build --build-arg VERSION=$(VERSION) -t kopa/connectiq:$(VERSION) .
	docker tag kopa/connectiq:$(VERSION) kopa/connectiq:latest

run:
	./run.bash ~/dev/workspace
