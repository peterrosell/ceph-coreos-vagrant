#!/bin/bash
vagrant ssh -c "sudo netstat -np --listen | grep `ps -ef | grep 'ceph-osd -d' | grep -v grep | awk '{print $2}'`" core-0${1}
