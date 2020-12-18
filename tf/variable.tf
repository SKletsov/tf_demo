variable "owner" {
  default = "Demo"
  type    = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "allow_ports_external" {
  description = "List of Ports to open for server"
  type        = list
  default     = ["80", "443"]
}

variable "allow_ports_internal" {
  description = "List of Ports to open for server"
  type        = list
  default     = ["80", "443", "22", "5432"]
}


variable "vpc_cidr_internal" {
  description = "CIDR for the Int subnet"
  default     = "10.10.0.0/24"
}
