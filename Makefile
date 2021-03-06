.PHONY: build run-dev build-docker clean

GIT_BRANCH := $(subst heads/,,$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null))
DEV_IMAGE := tent-dev$(if $(GIT_BRANCH),:$(subst /,-,$(GIT_BRANCH)))
DEV_DOCKER_IMAGE := tent-bin-dev$(if $(GIT_BRANCH),:$(subst /,-,$(GIT_BRANCH)))

default: clean install coverage crossbinary

clean:
	rm -rf dist/

binary: install
	GOOS=linux CGO_ENABLED=0 GOGC=off GOARCH=amd64 go build -a -tags netgo -ldflags '-w' -o "$(CURDIR)/dist/tent"

crossbinary: binary
	GOOS=linux GOARCH=amd64 go build -o "$(CURDIR)/dist/tent-linux-amd64"
	GOOS=linux GOARCH=386 go build -o "$(CURDIR)/dist/tent-linux-386"
	GOOS=darwin GOARCH=amd64 go build -o "$(CURDIR)/dist/tent-darwin-amd64"
	GOOS=darwin GOARCH=386 go build -o "$(CURDIR)/dist/tent-darwin-386"
	GOOS=windows GOARCH=amd64 go build -o "$(CURDIR)/dist/tent-windows-amd64.exe"
	GOOS=windows GOARCH=386 go build -o "$(CURDIR)/dist/tent-windows-386.exe"

install: clean
	go mod download
	go mod tidy
	go mod verify
	go mod vendor
	go generate

test:
	go test ./...

coverage:
	"$(CURDIR)/script/coverage.sh"

dist:
	mkdir dist

run-dev:
	go generate
	go test ./...
	go build -o "tent"
	./tent

build-docker:
	docker build -t "$(DEV_DOCKER_IMAGE)" .
