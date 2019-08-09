#  Use the below value to increase the size of the Nomad cluster on demand.
variable "city_hosts" {
  default = 3
}


variable "cityworker_api_hosts" {
  default = 2
}

variable "cityworker_holepunch_hosts" {
  default = 2
}

variable "cityworker_userland_hosts" {
  default = 2
}
