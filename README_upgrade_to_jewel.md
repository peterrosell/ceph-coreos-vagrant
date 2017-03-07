# Upgrade hammer to jewel

update CEPH_VERSION to 10.2.5 in all service templates files

0. make sure that docker images are built and pushed

   make sure all docker images are pre fetched on each host.

   You might not be able to fetch them as the docker registry is
   running on the ceph cluster.

   docker pull registry.emendatus.com/ceph-monitor:10.2.5
   docker pull registry.emendatus.com/ceph-osd:10.2.5
   docker pull registry.emendatus.com/ceph-metadata:10.2.5

1. make generate-services-from-templates

2. Upgrade Ceph on monitor hosts

   cd gen/services
   fleetctl destroy ceph-monitor@1
   fleetctl start ceph-monitor@1

   Wait for monitor to go up and join cluster and make sure that 
   it isn't looping with restarts

   Repeat for all monitors

3. Set noout::
   ceph osd set noout

4. Upgrade Ceph on all OSD hosts

   fleetctl destroy ceph-osd_disk_1@1
   fleetctl start ceph-osd_disk_1@1

   Wait for osd to go up and join cluster and make sure that
   it isn't looping with restarts

   Repeat for all OSDs

5. Let the cluster settle

6. Unset noout::
   ceph osd unset noout

7. Fix crush map

   ceph osd crush tunables optimal

8. Lock OSD upgrade to jewel
  
   ceph osd set require_jewel_osds

7. Upgrade all metadata servers (mds)

   fleetctl destroy ceph-metadata@2
   fleetctl start ceph-metadata@2
 
   Wait for mds to go up and join cluster and make sure that
   it isn't looping with restarts

   Repeat for all DMSes

8. Validate that everything is working and all containers are 
   running without boot looping.
