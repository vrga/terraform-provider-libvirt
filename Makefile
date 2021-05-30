LDFLAGS += -X main.version=$$(git describe --always --abbrev=40 --dirty)

# default  args for tests
TEST_ARGS_DEF := -covermode=count -coverprofile=profile.cov

default: build

terraform-provider-libvirt:
	go build -ldflags "${LDFLAGS}"

build: fmt-check lint-check vet-check terraform-provider-libvirt


local_install:
	cp ./terraform-provider-libvirt $HOME/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.0-test/linux_amd64/terraform-provider-libvirt

local_build: clean build local_install

install:
	go install -ldflags "${LDFLAGS}"

# unit tests
# usage:
# - run all the unit tests: make test
# - run some particular test: make test TEST_ARGS="-run TestAccLibvirtDomain_Cpu"
test:
	go test -v $(TEST_ARGS_DEF) $(TEST_ARGS) ./libvirt

# acceptance tests
# usage:
#
# - run all the acceptance tests:
#   make testacc
#
# - run some particular test:
#   make testacc TEST_ARGS="-run TestAccLibvirtDomain_Cpu"
#
# - run all the network test with a verbose loglevel:
#   TF_LOG=DEBUG make testacc TEST_ARGS="-run TestAccLibvirtNet*"
#
testacc:
	./travis/run-tests-acceptance $(TEST_ARGS)

vet-check:
	go vet ./libvirt

lint-check:
	go run golang.org/x/lint/golint -set_exit_status ./libvirt .

fmt-check:
	go fmt ./libvirt .

tf-check:
	terraform fmt -write=false -check=true -diff=true examples/

clean:
	rm -f terraform-provider-libvirt

cleanup:
	./travis/cleanup.sh

.PHONY: build install test testacc vet-check fmt-check lint-check
