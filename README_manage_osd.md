*Remove one OSD*

https://access.redhat.com/documentation/en/red-hat-ceph-storage/version-1.3/red-hat-ceph-storage-13-red-hat-ceph-administration-guide/#removing-osds-manual

Take OSD out and remove it from usage. It will start remapping blocks.

	ceph osd out 0
	ceph osd crush remove osd.0
	ceph auth del osd.0

Stop osd deamon for that osd.
	
	fleetctl stop ceph-osd-disk_X@Y

Remove osd from cluster

	ceph osd rm 0

*Show OSD* 

	ceph osd tree

*Reweight OSDs in crush map*

https://ceph.com/planet/ceph-osd-reweight/

	ceph osd getcrushmap -o crush
	crushtool -d crush -o crush.txt

Edit crush.txt file and adjust weights for OSDs and host

	crushtool -c crush.txt -o new_crush
	ceph osd setcrushmap -i new_crush

