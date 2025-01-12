NAME := docker-ps
VERSION := $$(make -s show-version)
VERSION_PATH := cmd/$(NAME)
CURRENT_REVISION := $(sh git rev-parse --short HEAD)
BUILD_LDFLAGS := "-s -w -X main.revision=$(CURRENT_REVISION)"
GONAME ?= $(sh go env GOPATH)/bin
export GO111MODULE=on

.PHONY: all
all: clean build

.PHONY: build
build:
	go build -ldflags=$(BUILD_LDFLAGS) -o $(NAME) ./cmd/$(NAME)

.PHONY: install
install:
	go install -ldflags=$(BUILD_LDFLAGS) ./...

.PHONY: show-version
show-version: $(GOBIN)/gobump
	@gobump show -r $(VERSION_PATH)

$(GOBIN)/gobump:
	@cd && go install github.com/x-motemen/gobump/cmd/gobump@latest

.PHONY: cross
cross: $(GONAME)/goxz
	goxz -n $(NAME) -pv=v$(VERSION) -build-ldflags=$(BUILD_LDFLAGS) ./cmd/$(NAME)

$(GONAME)/goxz:
	cd && go install github.com/Songmu/goxz/cmd/goxz@latest

.PHONY: test
test: build
	go test -v ./...

.PHONY: lint
lint: $(GONAME)/golint
	go vet ./...
	golint -set_exit_status ./...

$(GONAME)/golint:
	cd && go install golang.org/x/lint/golint@latest

.PHONY: clean
clean:
	rm -rf $(NAME) goxz
	go clean

.PHONY: upload
upload: $(GONAME)/ghr
	ghr "v$(VERSION)" goxz

$(GONAME)/ghr:
	cd && go install github.com/tcnksm/ghr@latest
