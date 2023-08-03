
#!/bin/bash

# Define the Kubernetes node name as a variable

K8S_NODE=${NODE_NAME}

# Get a list of all resource-intensive pods on the node

PODS=$(kubectl top pods --no-headers | grep $K8S_NODE | awk '$3 > 90 {print $1}')

# Loop through the list of pods and terminate them

for POD in $PODS

do

    kubectl delete pod $POD --force --grace-period=0

done