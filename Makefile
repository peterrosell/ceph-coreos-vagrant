include includes.mk

FLEET_VERSION=0.8.3

TEMPLATE_IMAGES=monitor osd gateway
BUILT_IMAGES=base $(TEMPLATE_IMAGES)

DAEMON_IMAGE = $(IMAGE_PREFIX)ceph-daemon:$(BUILD_TAG)
DAEMON_DEV_IMAGE = $(DEV_REGISTRY)/$(DAEMON_IMAGE)
MONITOR_IMAGE = $(IMAGE_PREFIX)ceph-monitor:$(BUILD_TAG)
MONITOR_DEV_IMAGE = $(DEV_REGISTRY)/$(MONITOR_IMAGE)
GATEWAY_IMAGE = $(IMAGE_PREFIX)ceph-gateway:$(BUILD_TAG)
GATEWAY_DEV_IMAGE = $(DEV_REGISTRY)/$(GATEWAY_IMAGE)

TEMPLATES := $(shell cd services/templates && find *)
SERVERS :=1 2

#		cat user-data.template | sed -e "s,# discovery: https://discovery.etcd.io/,discovery: https://discovery.etcd.io/)," | sed -e "s,discovery: https://discovery.etcd.io/.*,discovery: $$(cat discovery.url)," > \user-data-$(I) ; \

discovery-url:
	@curl -s -w '\n' https://discovery.etcd.io/new > discovery.url
	$(foreach I, $(SERVERS), \
		cat user-data.template | \
		sed -e "s,# discovery: https://discovery.etcd.io/,discovery: https://discovery.etcd.io/," | \
		sed -e "s,discovery: https://discovery.etcd.io/.*,discovery: $$(cat discovery.url)," | \
		sed -e "s/__ID__/$(I)/" \
		> user-data-$(I) ; \
	)

build: check-docker
	@# Build base first due to dependencies
	docker build -t ceph-base:$(BUILD_TAG) base/
	$(foreach I, $(TEMPLATE_IMAGES), \
		sed -e "s/#FROM is generated dynamically by the Makefile/FROM ceph-base:${BUILD_TAG}/g" $(I)/Dockerfile.template > $(I)/Dockerfile ; \
		docker build -t ceph-$(I):$(BUILD_TAG) $(I)/ ; \
	)
#		rm $(I)/Dockerfile ; \

push: check-docker check-registry 
	$(foreach I, $(BUILT_IMAGES), \
		docker tag ceph-$(I):$(BUILD_TAG) $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
		docker push $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
		docker tag ceph-$(I):$(BUILD_TAG) $(IMAGE_PREFIX)ceph-$(I):latest ; \
		docker push $(IMAGE_PREFIX)ceph-$(I):latest ; \
	)

clean: check-docker check-registry
	$(foreach I, $(BUILT_IMAGES), \
		docker rmi $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
		docker rmi $(IMAGE_PREFIX)ceph-$(I):$(BUILD_TAG) ; \
	)

full-clean: check-docker check-registry
	$(foreach I, $(BUILT_IMAGES), \
		docker images -q $(IMAGE_PREFIX)ceph-$(I) | xargs docker rmi -f ; \
		docker images -q $(IMAGE_PREFIX)ceph-$(I) | xargs docker rmi -f ; \
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

cloud-init:
	vagrant ssh -c "sudo /usr/bin/coreos-cloudinit --from-file /var/lib/coreos-vagrant/vagrantfile-user-data"

services-from-templates: check-awk
	@$(foreach I, $(TEMPLATES), \
		awk '{while(match($$0,"[$$][$$]{[^}]*}")) {var=substr($$0,RSTART+3,RLENGTH -4);gsub("[$$][$$]{"var"}",ENVIRON[var])}}1' < services/templates/$I > services/$I.service && \
		echo 'Created service file: $I.service' ; \
	)

install-fleet:
	URL=$$(curl https://github.com/coreos/fleet/releases/download/v$(FLEET_VERSION)/fleet-v$(FLEET_VERSION)-linux-amd64.tar.gz | \
		sed 's/.*href="\(.*\)".*/\1/g' | sed 's/\&amp\;/\&/g') ; \
		curl "$$URL" | \
		tar -zOx fleet-v$(FLEET_VERSION)-linux-amd64/fleetctl > \
		/usr/local/bin/fleetctl \
		&& chmod +x /usr/local/bin/fleetctl

register-ssh-key:
	vagrant ssh-config | sed -n "s/IdentityFile//gp" | xargs ssh-add

show-environment:
	@echo '   Set these environment variables:'
	@echo 'export FLEETCTL_TUNNEL=$(shell vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"):$(shell vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")'
	@echo 'export DOCKER_REGISTRY="registry.emendatus.com:5000/"'

dev-environment: register-ssh-key show-environment

clean-old-run:
	@rm $(HOME)/.fleetctl/known_hosts

start-services:
	@(cd services && fleetctl start ceph-monitor.service)
	@(cd services && fleetctl start ceph-osd_disk_a.service) 
	@(cd services && fleetctl start ceph-osd_disk_b.service) 

start-cluster:
	vagrant up
#	rm user-data

run-all: discovery-url start-cluster services-from-templates start-services

