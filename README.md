
## Set up your own docker registry

	docker run -d registry 

Run this to set your docker registry. It will be used by the makefile.

	export MY_DOCKER_REGISTRY=my-docker-server:5000

Tips: Add it to your ~/.profile

### Quick setup

Add this line to your ```/etc/hosts``` file

	172.21.13.103    ceph-gateway bucket.ceph-gateway


It will give errors until the cluster is up and answered yes to the ssh question

Run the following commands

	make create-cluster    # Answer yes to ssh question
	. ./env

In a separate shell run

	. ./env
	make watch-cluster

Continue with

	make generate-services-from-templates
	make start-services
	make create-s3-test-user  # save the result
	make install-dragondisk
	make start-dragondisk	

Add an account with the data from the saved result


## Detailed setup

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
make generate-services-from-templates
```

Before you can start the services you need to register ssh key and set two environment variables. The command below registers the ssh key and creates and shows the environment variables to set. This is the env-file that must be sourced to be able to run. 

``` bash
make dev-environment
```

##Known issues

When running on virtualbox there sometimes, quite often, occur problem with partitioning and formating a disk. Maybe this happens due to the disks are virtual on the same hardware disk. Haven't seen this on a physical disk.
To verify the status use ```df``` to check that you have three disks mounted.
Use command ```journalctl -u prepare-disks``` to search for error. Anyway, the errors looks like this

    Error: Error informing the kernel about modifications to partition /dev/sdd1 -- Device or re
    Error: Failed to add partition 1 (Device or resource busy)

The workaround is to run fdisk and delete all partitions. Sometimes the softlink ```disk_journal/disk_<id>``` must be deleted too. When the disk state is cleared you can run the prepare_disks.sh script manually, ```sudo /tools/prepare_disks.sh perform```. It is also possible to restart the instance and hope the partitioning works better. There might be some problem with that due to the disks in virtualbox seems to change location between boots.

    core@core-01 ~ $ sudo fdisk /dev/sdd

    Welcome to fdisk (util-linux 2.26.1).
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.


    Command (m for help): p
    Disk /dev/sdd: 11.9 GiB, 12721324032 bytes, 24846336 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: gpt
    Disk identifier: 6E362C03-0425-4A36-A437-83A4F7BC30AD

    Device       Start      End  Sectors  Size Type
    /dev/sdd1     2048  9764863  9762816  4.7G Microsoft basic data
    /dev/sdd2  9764864 24846302 15081439  7.2G Microsoft basic data

    Command (m for help): d
    Partition number (1,2, default 2):  

    Partition 2 has been deleted.

    Command (m for help): d
    Selected partition 1
    Partition 1 has been deleted.

    Command (m for help): 


    Command (m for help): w

    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.

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
