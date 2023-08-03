
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Memory Usage Alert
---

This incident type is related to an alert triggered when the available memory on a Kubernetes node drops below a certain threshold (in this case, 90%). The alert is designed to monitor the memory usage percentage and notify the relevant teams when the threshold is breached. This incident type is critical as it helps ensure that Kubernetes clusters are operating within acceptable memory usage levels and that potential issues are identified and resolved promptly.

### Parameters
```shell
# Environment Variables

export NODE_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

```

## Debug

### Get the list of Kubernetes nodes
```shell
kubectl get nodes
```

### Describe a specific node to check its resource usage
```shell
kubectl describe node ${NODE_NAME}
```

### Get the list of Kubernetes pods in a specific node
```shell
kubectl get pods -A  --field-selector spec.nodeName=${NODE_NAME}
```

### Describe a specific pod to check its resource usage
```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Get the logs of a specific container in a specific pod
```shell
kubectl logs ${POD_NAME} ${CONTAINER_NAME} -n ${NAMESPACE}
```

### 8. Check the Kubernetes events for any memory-related issues
```shell
kubectl get events
```

## Repair

### Reove node from cluster 
```shell
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
```

### Identify and terminate any resource-intensive pods on the impacted node(s) to free up memory.
```shell

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
```