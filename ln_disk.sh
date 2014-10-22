#!/bin/bash
/usr/bin/ln -s $(/usr/bin/readlink -f /dev/disk/by-id/*$1*) $2
