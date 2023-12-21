##Variables for Terraform root

variable "region" {
  type = string
}
variable "server_port" {
  type = number
}

variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}