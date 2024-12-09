variable "name" {
  description = "Name of the security group"
}

variable "description" {
  description = "Description of utilization of the security group."
}

variable "vpc_id" {
  description = "The VPC Id"
}

variable "ingress_rules" {
  description = "List of Ingress Rules"
}

variable "egress_rules" {
  description = "List of Egress Rules"
}

variable "tags" {
  description = "tagging"
  default     = {}
}