resource "shoreline_notebook" "kubernetes_memory_usage_alert" {
  name       = "kubernetes_memory_usage_alert"
  data       = file("${path.module}/data/kubernetes_memory_usage_alert.json")
  depends_on = [shoreline_action.invoke_cordon_drain_delete_node,shoreline_action.invoke_k8s_terminate_pod]
}

resource "shoreline_file" "cordon_drain_delete_node" {
  name             = "cordon_drain_delete_node"
  input_file       = "${path.module}/data/cordon_drain_delete_node.sh"
  md5              = filemd5("${path.module}/data/cordon_drain_delete_node.sh")
  description      = "Reove node from cluster"
  destination_path = "/agent/scripts/cordon_drain_delete_node.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "k8s_terminate_pod" {
  name             = "k8s_terminate_pod"
  input_file       = "${path.module}/data/k8s_terminate_pod.sh"
  md5              = filemd5("${path.module}/data/k8s_terminate_pod.sh")
  description      = "Identify and terminate any resource-intensive pods on the impacted node(s) to free up memory."
  destination_path = "/agent/scripts/k8s_terminate_pod.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cordon_drain_delete_node" {
  name        = "invoke_cordon_drain_delete_node"
  description = "Reove node from cluster"
  command     = "`chmod +x /agent/scripts/cordon_drain_delete_node.sh && /agent/scripts/cordon_drain_delete_node.sh`"
  params      = ["NODE_NAME"]
  file_deps   = ["cordon_drain_delete_node"]
  enabled     = true
  depends_on  = [shoreline_file.cordon_drain_delete_node]
}

resource "shoreline_action" "invoke_k8s_terminate_pod" {
  name        = "invoke_k8s_terminate_pod"
  description = "Identify and terminate any resource-intensive pods on the impacted node(s) to free up memory."
  command     = "`chmod +x /agent/scripts/k8s_terminate_pod.sh && /agent/scripts/k8s_terminate_pod.sh`"
  params      = ["NODE_NAME"]
  file_deps   = ["k8s_terminate_pod"]
  enabled     = true
  depends_on  = [shoreline_file.k8s_terminate_pod]
}

