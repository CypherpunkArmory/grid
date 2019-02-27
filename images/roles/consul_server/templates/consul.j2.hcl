bind_addr = "0.0.0.0"
data_dir = "/var/lib/consul/"
datacenter = "{{ district }}"

ui = true

server = true
bootstrap_expect = {{ cluster_size }}

raft_protocol = 3

advertise_addr = "0.0.0.0"

addresses {
  dns = "0.0.0.0"
}

recursors = ["8.8.8.8"]

retry_join = ["provider=aws tag_key=District tag_value={{ district }}"]

ports {
  dns = 53
}

telemetry {
  dogstatsd_addr = "127.0.0.1:8125"
}
