bind_addr = "0.0.0.0"
data_dir = "/var/lib/consul/"
datacenter = "{{ consul_district }}"

ui = true

raft_protocol = 3

{% raw %}
advertise_addr = "{{ GetPrivateIP }}"
{% endraw %}

client_addr = "0.0.0.0"

addresses {
  dns = "0.0.0.0"
}

recursors = ["8.8.8.8"]

retry_join = ["provider=aws tag_key=District tag_value={{ consul_district }}"]

ports {
  dns = 53
}

telemetry {
  dogstatsd_addr = "127.0.0.1:8125"
}
