bind_addr = "0.0.0.0"
data_dir = "/var/lib/nomad/"
datacenter = "city"

advertise {
  # This should be the IP of THIS MACHINE and must be routable by every node
  # in your cluster
  http = "{{ ansible_default_ipv4.address }}"
  rpc  = "{{ ansible_default_ipv4.address }}"
  serf = "{{ ansible_default_ipv4.address }}"
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  datadog_address = "127.0.0.1:8125"
  disable_hostname = true
}

client {
  enabled = true
}

server {
  enabled = true
  bootstrap_expect = {{ cluster_size }}
  raft_protocol = 3
}
