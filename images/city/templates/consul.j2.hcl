bind_addr = "0.0.0.0"
data_dir = "/var/lib/consul/"
datacenter = "city"
server = true

raft_protocol = 3

advertise_addr = "{{ ansible_default_ipv4.address }}"

bootstrap_expect = {{ cluster_size }}

retry_join = ["provider=aws tag_key=District tag_value=city"]

ports {
  dns = 53
}

telemetry {
  dogstatsd_addr = "127.0.0.1:8125"
}
