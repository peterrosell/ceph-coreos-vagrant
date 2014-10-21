include includes.mk

TEMPLATE_IMAGES=osd
# monitor gateway
BUILT_IMAGES=base $(TEMPLATE_IMAGES)

DAEMON_IMAGE = $(IMAGE_PREFIX)ceph-daemon:$(BUILD_TAG)
DAEMON_DEV_IMAGE = $(DEV_REGISTRY)/$(DAEMON_IMAGE)
MONITOR_IMAGE = $(IMAGE_PREFIX)ceph-monitor:$(BUILD_TAG)
MONITOR_DEV_IMAGE = $(DEV_REGISTRY)/$(MONITOR_IMAGE)
GATEWAY_IMAGE = $(IMAGE_PREFIX)ceph-gateway:$(BUILD_TAG)
GATEWAY_DEV_IMAGE = $(DEV_REGISTRY)/$(GATEWAY_IMAGE)


discovery-url:
	@cat user-data.template | \
	sed -e "s,# discovery: https://discovery.etcd.io/,discovery: https://discovery.etcd.io/)," | \
	sed -e "s,discovery: https://discovery.etcd.io/.*,discovery: $$(curl -s -w '\n' https://discovery.etcd.io/new)," > \
	user-data

build: check-docker
	@# Build base first due to dependencies
	docker build -t $(IMAGE_PREFIX)ceph-base:$(BUILD_TAG) base/
	$(foreach I, $(TEMPLATE_IMAGES), \
		sed -e "s/#FROM is generated dynamically by the Makefile/FROM ${REPOSITORY}\/ceph-base:${BUILD_TAG}/" $(I)/Dockerfile.template > $(I)/Dockerfile ; \
		docker build -t $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) $(I)/ ; \
		rm $(I)/Dockerfile ; \
	)

push: check-docker check-registry 
	$(foreach I, $(BUILT_IMAGES), \
		docker tag $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) $(REGISTRY)/$(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
		docker push $(REGISTRY)/$(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
	)

clean: check-docker check-registry
	$(foreach I, $(BUILT_IMAGES), \
		docker rmi $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
		docker rmi $(REGISTRY)/$(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
	)

full-clean: check-docker check-registry
	$(foreach I, $(BUILT_IMAGES), \
		docker images -q $(IMAGE_PREFIX)ceph-$(I) | xargs docker rmi -f ; \
		docker images -q $(REGISTRY)/$(IMAGE_PREFIX)ceph-$(I) | xargs docker rmi -f ; \
	)

dev-release: push set-image

release:
	docker push $(DAEMON_IMAGE)
	docker push $(MONITOR_IMAGE)
	docker push $(GATEWAY_IMAGE)

deploy: build dev-release restart

test: test-unit test-functional

test-unit:
	@echo no unit tests

test-functional:
	@docker history deis/test-etcd >/dev/null 2>&1 || docker pull deis/test-etcd:latest
	GOPATH=$(CURDIR)/../tests/_vendor:$(GOPATH) go test -v ./tests/...
