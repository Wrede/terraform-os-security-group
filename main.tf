##################################
# Get ID of created Security Group
##################################
locals {
  this_sg_id = openstack_networking_secgroup_v2.this.*.id[0]
}


resource "openstack_networking_secgroup_v2" "this" {
  name        = var.name
  description = var.description
}


###################################
# Ingress - List of rules (simple)
###################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "openstack_networking_secgroup_rule_v2" "ingress_rules" {
  count = length(var.ingress_rules)
  security_group_id = local.this_sg_id
  direction         = "ingress"
  ethertype         = var.ethertype 

  #note: OS only takes a single CIDR  
  remote_ip_prefix  = var.ingress_cidr_blocks
  description       = var.rules[var.ingress_rules[count.index]][3]

  port_range_min    = var.rules[var.ingress_rules[count.index]][0]
  port_range_max    = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}

resource "openstack_networking_secgroup_rule_v2" "ingress_with_cidr_blocks" {
  count = length(var.ingress_with_cidr_blocks)

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = var.ethertype 
  remote_ip_prefix = lookup(
      var.ingress_with_cidr_blocks[count.index],
      "cidr_blocks",
      var.ingress_cidr_blocks
  )
  description = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )
  port_range_min = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(var.ingress_with_cidr_blocks[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(var.ingress_with_cidr_blocks[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(var.ingress_with_cidr_blocks[count.index], "rule", "_")][2],
  )
}

##################################
# Egress - List of rules (simple)
##################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "openstack_networking_secgroup_rule_v2" "egress_rules" {
  count = length(var.egress_rules)

  security_group_id = local.this_sg_id
  direction         = "egress"
  cidr_blocks       = var.egress_cidr_blocks
  description       = var.rules[var.egress_rules[count.index]][3]
  ethertype         = var.ethertype 

  port_range_min = var.rules[var.egress_rules[count.index]][0]
  port_range_max   = var.rules[var.egress_rules[count.index]][1]
  protocol  = var.rules[var.egress_rules[count.index]][2]
}

resource "openstack_networking_secgroup_rule_v2" "egress_with_cidr_blocks" {
  count = length(var.egress_with_cidr_blocks)

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = var.ethertype
  cidr_blocks = lookup(
      var.egress_with_cidr_blocks[count.index],
      "cidr_blocks",
      var.egress_cidr_blocks
  )
  description = lookup(
    var.egress_with_cidr_blocks[count.index],
    "description",
    "Egress Rule",
  )
  port_range_min = lookup(
    var.egress_with_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(var.egress_with_cidr_blocks[count.index], "rule", "_")][0],
  )
  to_port = lookup(
    var.egress_with_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(var.egress_with_cidr_blocks[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.egress_with_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(var.egress_with_cidr_blocks[count.index], "rule", "_")][2],
  )
}
