variable "vultr_seattle" {
  description = "Vultr Seattle Region"
  default = "4"
}

# variable "vultr_seattle" {
#   description = "Vultr Seattle Region"
#   default = "6"
# }

variable "ubuntu_os" {
  description = "Docker on CentOS 7"
  default = 215
}
# variable "one_cpu_one_gb_ram" {
#   description = "1024 MB RAM,25 GB SSD,1.00 TB BW"
#   default = 200
# }
variable "one_cpu_one_gb_ram" {
  description = "1024 MB RAM,25 GB SSD,1.00 TB BW"
  default = 201
}
variable "host_name" {
  description = "the hostname for the vps"
  default = "kampos"
}
variable "api_key" {
  default = "test"
}

variable "ssh_key" {
  default = "test"
}