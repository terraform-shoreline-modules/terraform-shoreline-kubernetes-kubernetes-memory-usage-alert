#!/bin/bash

# Set variables

node_name=${NODE_NAME}

# Cordon the node

kubectl cordon $node_name 

# Get the pods running on the node

pods=$(kubectl get pods --field-selector spec.nodeName=$node_name -o json  | jq -r '.items[].metadata.name')

# Drain the pods from the node

kubectl drain $node_name --ignore-daemonsets --delete-local-data --force --delete-emptydir-data --grace-period=30 --timeout=300s --eviction-timeout=30s --pod-selector='!' -l node-role.kubernetes.io/master --delete-local-data

# Delete the node

kubectl delete node $node_name