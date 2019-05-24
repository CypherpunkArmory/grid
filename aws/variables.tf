variable "city_hosts" {
  default = 3
}
#after lowering the citywork number and terraforming be sure to run GC
#curl     --request PUT     http://nomad.service.city.consul:4646/v1/system/gc

variable "cityworker_hosts" {
  default = 0 
}

#  Use the below value to increase the size of the Nomad cluster on demand.
#  After lowering the citywork number and terraforming be sure to run GC
#  curl     --request PUT     http://nomad.service.city.consul:4646/v1/system/gc

variable "cityworker_hosts" {
  default = 0 
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

variable "dmz_version" {
  default = "most_recent"
}
