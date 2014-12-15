#!/bin/bash
vagrant ssh -c "docker exec -it ceph-monitor-1 ceph $@" core-01
