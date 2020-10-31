variable name {
  type        = string
  description = "Name of security group"
  default     = "default_secgroup"
}

variable description {
  type        = string
  description = "Description of security group"
  default     = ""
}

##########
# Ingress
##########
variable "ingress_rules" {
  description = "List of ingress rules to create by name"
  type        = list(string)
  default     = []
}

variable "ethertype" {
  description = "The layer 3 protocol type, valid values are IPv4 or IPv6"
  type        = string
  default     = "IPv4"
}

variable "ingress_with_cidr_blocks" {
  description = "List of ingress rules to create where 'cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}


# OS only support a single CIDR to be used for one rule 
# TODO: enable list of CIDRs, possibly using remote_group_id (source) instead 
variable "ingress_cidr_blocks" {
  description = "IPv4 CIDR ranges to use on all ingress rules"
  type        = string
  default     = ""
}

#########
# Egress
#########
variable "egress_rules" {
  description = "List of egress rules to create by name"
  type        = list(string)
  default     = []
}

variable "egress_with_cidr_blocks" {
  description = "List of egress rules to create where 'cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}

variable "egress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all egress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}