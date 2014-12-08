#!/bin/bash
export SERVICE=$1
fleetctl stop $SERVICE
fleetctl destroy $SERVICE
fleetctl submit $SERVICE
fleetctl start $SERVICE
fleetctl journal -f $SERVICE
