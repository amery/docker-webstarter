.PHONY: all clean fmt build dev run pull

all: build

# load customizations
#
include config.mk

MAIN_MODULE ?= github.com/amery/go-webpack-starter
EXTRA_MODULES ?=
MODULES = $(MAIN_MODULE) $(subst :, ,$(EXTRA_MODULES))

SERVER_PORT ?= 8080
GODOC_PORT ?= 9090

# clean
#
clean:
	@cd $(GOPATH); git ls-files -o bin/ pkg/ lib/ | xargs -rt rm
	-$(MAKE) -C src/$(MAIN_MODULE) clean

# fmt
#
fmt:
	@find $(addprefix src/, $(MODULES)) -name '*.go' \
		| sed -e 's|/[^/]\+\.go$$||' -e 's|^src/||' \
		| sort -uV | xargs -rt go fmt -x

# build
#
.PHONY: npm-build go-build

build: npm-build go-build

npm-build:
	cd src/$(MAIN_MODULE); npm run build

go-build:
	go get -v $(MAIN_MODULE)/...

# dev (run backend and webpack-dev-server)
# 
dev:
	$(MAKE) -C src/$(MAIN_MODULE) PORT=$(SERVER_PORT) dev

# run (run only backend)
#
run:
	$(MAKE) -C src/$(MAIN_MODULE) PORT=$(SERVER_PORT) run
	
# pull
#
pull:
	sed -n -e 's|^[ \t]*FROM[ \t]\+\([^ ]\+\)[^ \t]*$$|\1|p' $(CURDIR)/docker/Dockerfile \
		| xargs -rt docker pull