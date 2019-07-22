#  Use the below value to increase the size of the Nomad cluster on demand.
variable "city_hosts" {
  default = 3
}


variable "cityworker_hosts" {
  default = 3
}

variable "city_version" {
  default = "most_recent"
}

variable "cityworker_version" {
  default = "most_recent"
}

variable "lb_version" {
  default = "most_recent"
}

variable "tcplb_version" {
  default = "most_recent"
}

variable "dmz_version" {
  default = "most_recent"
}
