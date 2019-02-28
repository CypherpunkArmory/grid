bind_addr = "0.0.0.0"
data_dir = "/var/lib/nomad/"
datacenter = "{{ district }}"

{% raw %}
advertise {
  # This should be the IP of THIS MACHINE and must be routable by every node
  # in your cluster
  http = "{{ GetPrivateIP }}"
  rpc  = "{{ GetPrivateIP }}"
  serf = "{{ GetPrivateIP }}"
}
{% endraw %}

vault {
  enabled = true
  address = "http://vault:8200"
  create_from_role = "nomad-cluster"
  token = "<TOKEN>"
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  datadog_address = "127.0.0.1:8125"
  disable_hostname = true
}

client {
  enabled = true
  options {
    "docker.auth.config" = "/home/nomad/.docker/config.json"
  }
}

server {
  enabled = true
  bootstrap_expect = {{ cluster_size }}
  raft_protocol = 3
}
