#!/bin/bash
/usr/bin/ln -s $(ls /dev/disk/by-id/*$1*) $2
