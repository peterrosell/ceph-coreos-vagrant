
## Set up your own docker registry

	docker run -d registry 

Run this to set your docker registry. It will be used by the makefile.

	export MY_DOCKER_REGISTRY=my-docker-server:5000

Tips: Add it to your ~/.profile

A new cluster always needs a unique discovery-url. You can't reuse it so if you destroy the cluster and recreates it you must generate a new url by running the command again. It must be added to a config file that is provided to CoreOS. It can easily be created by running this command:

``` bash
make discovery-url
```

To start the cluster, 3 servers. Run the following command:

``` bash
make create-cluster
```

This command will not be able to contact the cluster the first time you run it due to missing config. Source the env-file to get it set. Each terminal that you use and where you want to use fleetctl you need to source the env-file.

	. ./env

Ceph's different services are installed and managed with fleetctl. To generate the service files from template run the command:

``` bash
make services-from-templates
```

Before you can start the services you need to register ssh key and set two environment variables. The command below registers the ssh key and creates and shows the environment variables to set. This is the env-file that must be sourced to be able to run. 

``` bash
make dev-environment
```

##Trobleshoting
If fleetctl complains about bad ssh keys they can be removed with this command.
``` bash
ssh-keygen -f "~/.fleectl/known_hosts" -R "[127.0.0.1]:2222"
```
Or just delete the ```known_hosts``` file
``` bash
rm ~/.fleetctl/known_hosts
```
## Amazon S3 API

### Create a user

	vagrant ssh core-03 -- -t docker exec -it ceph-gateway bash
	root@core-03:/app# radosgw-admin user create --uid=johndoe --display-name="John Doe" --email=john@example.com 

### Access gateway

To test Ceph Object Gateway we can use a nice tool named DragonDisk. It's freeware and available here, http://www.dragondisk.com. Download and unzip it.

Start DragonDisk with the start script, ./dragondisk. Then add an account via the File-menu. Change the Provider to "Other S3 compatible service" and enter 172.21.13.103 as Service Endpoint. Fill in the username, access key and secret key and save the account.

NOTE! If you have any backslash in the key then you need to remove it, it's just an escape character for representing slashes in json.
