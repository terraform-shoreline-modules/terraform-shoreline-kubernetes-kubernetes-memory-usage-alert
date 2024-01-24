resource "shoreline_notebook" "kubernetes_memory_usage_alert" {
  name       = "kubernetes_memory_usage_alert"
  data       = file("${path.module}/data/kubernetes_memory_usage_alert.json")
  depends_on = [shoreline_action.invoke_cordon_and_drain_nodes,shoreline_action.invoke_terminate_pods_on_node]
}

resource "shoreline_file" "cordon_and_drain_nodes" {
  name             = "cordon_and_drain_nodes"
  input_file       = "${path.module}/data/cordon_and_drain_nodes.sh"
  md5              = filemd5("${path.module}/data/cordon_and_drain_nodes.sh")
  description      = "Remove node from cluster."
  destination_path = "/tmp/cordon_and_drain_nodes.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "terminate_pods_on_node" {
  name             = "terminate_pods_on_node"
  input_file       = "${path.module}/data/terminate_pods_on_node.sh"
  md5              = filemd5("${path.module}/data/terminate_pods_on_node.sh")
  description      = "Identify and terminate any resource-intensive pods on the impacted node(s) to free up memory."
  destination_path = "/tmp/terminate_pods_on_node.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cordon_and_drain_nodes" {
  name        = "invoke_cordon_and_drain_nodes"
  description = "Remove node from cluster."
  command     = "`chmod +x /tmp/cordon_and_drain_nodes.sh && /tmp/cordon_and_drain_nodes.sh`"
  params      = ["NODE_NAME"]
  file_deps   = ["cordon_and_drain_nodes"]
  enabled     = true
  depends_on  = [shoreline_file.cordon_and_drain_nodes]
}

resource "shoreline_action" "invoke_terminate_pods_on_node" {
  name        = "invoke_terminate_pods_on_node"
  description = "Identify and terminate any resource-intensive pods on the impacted node(s) to free up memory."
  command     = "`chmod +x /tmp/terminate_pods_on_node.sh && /tmp/terminate_pods_on_node.sh`"
  params      = ["NODE_NAME"]
  file_deps   = ["terminate_pods_on_node"]
  enabled     = true
  depends_on  = [shoreline_file.terminate_pods_on_node]
}

