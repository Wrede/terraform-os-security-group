##################################
# Get ID of created Security Group
##################################
locals {
  this_sg_id = openstack_networking_secgroup_v2.this.*.id[0]
}


resource "openstack_networking_secgroup_v2" "this" {
  name                 = var.name
  description          = var.description
  delete_default_rules = var.delete_default_rules
}


###################################
# Ingress - List of rules (simple)
###################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "openstack_networking_secgroup_rule_v2" "ingress_rules" {
  count = var.create ? length(var.ingress_rules) : 0
  security_group_id = local.this_sg_id
  direction         = "ingress"
  ethertype         = "IPv4" 

  #note: OS only takes a single CIDR  
  remote_ip_prefix  = var.ingress_cidr_blocks
  description       = var.rules[var.ingress_rules[count.index]][3]

  port_range_min    = var.rules[var.ingress_rules[count.index]][0]
  port_range_max    = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}

# Computed - Security group rules with "cidr_blocks" and it uses list of rules names
resource "openstack_networking_secgroup_rule_v2" "computed_ingress_rules" {
  count = var.create ? var.number_of_computed_ingress_rules : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv4" 

  remote_ip_prefix      = var.ingress_cidr_blocks
  description      = var.rules[var.computed_ingress_rules[count.index]][3]

  port_range_min = var.rules[var.computed_ingress_rules[count.index]][0]
  port_range_max   = var.rules[var.computed_ingress_rules[count.index]][1]
  protocol  = var.rules[var.computed_ingress_rules[count.index]][2]
}

##########################
# Ingress - Maps of rules
##########################
# Security group rules with "source_security_group_id", but without "cidr_blocks" and "self"
resource "openstack_networking_secgroup_rule_v2" "ingress_with_source_security_group_id" {
  count = var.create ? length(var.ingress_with_source_security_group_id) : 0

  security_group_id = local.this_sg_id
  direction         = "ingress"
  ethertype         = lookup(
    var.ingress_with_source_security_group_id[count.index],
    "ethertype",
    "IPv4",
  )

  remote_group_id   = var.ingress_with_source_security_group_id[count.index]["source_security_group_id"]
  description       = lookup(
    var.ingress_with_source_security_group_id[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.ingress_with_source_security_group_id[count.index],
    "from_port",
    var.rules[lookup(
      var.ingress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.ingress_with_source_security_group_id[count.index],
    "to_port",
    var.rules[lookup(
      var.ingress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.ingress_with_source_security_group_id[count.index],
    "protocol",
    var.rules[lookup(
      var.ingress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Computed - Security group rules with "source_security_group_id", but without "cidr_blocks" and "self"
resource "openstack_networking_secgroup_rule_v2" "computed_ingress_with_source_security_group_id" {
  count = var.create ? var.number_of_computed_ingress_with_source_security_group_id : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = lookup(
    var.computed_ingress_with_source_security_group_id[count.index],
    "ethertype",
    "IPv4",
  )

  remote_group_id   = var.computed_ingress_with_source_security_group_id[count.index]["source_security_group_id"]
  description       = lookup(
    var.computed_ingress_with_source_security_group_id[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.computed_ingress_with_source_security_group_id[count.index],
    "from_port",
    var.rules[lookup(
      var.computed_ingress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.computed_ingress_with_source_security_group_id[count.index],
    "to_port",
    var.rules[lookup(
      var.computed_ingress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.computed_ingress_with_source_security_group_id[count.index],
    "protocol",
    var.rules[lookup(
      var.computed_ingress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "ingress_with_cidr_blocks" {
  count = var.create ? length(var.ingress_with_cidr_blocks) : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv4" 
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

# Computed - Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "computed_ingress_with_cidr_blocks" {
  count = var.create ? var.number_of_computed_ingress_with_cidr_blocks : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv4"

  remote_ip_prefix = lookup(
      var.computed_ingress_with_cidr_blocks[count.index],
      "cidr_blocks",
      var.ingress_cidr_blocks
  )
  description = lookup(
    var.computed_ingress_with_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.computed_ingress_with_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(
      var.computed_ingress_with_cidr_blocks[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.computed_ingress_with_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(
      var.computed_ingress_with_cidr_blocks[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.computed_ingress_with_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(
      var.computed_ingress_with_cidr_blocks[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Security group rules with "ipv6_cidr_blocks", but without "cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "ingress_with_ipv6_cidr_blocks" {
  count = var.create ? length(var.ingress_with_ipv6_cidr_blocks) : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv6"
  remote_ip_prefix = lookup(
      var.ingress_with_ipv6_cidr_blocks[count.index],
      "cidr_blocks",
      var.ingress_ipv6_cidr_blocks
  )
  description = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )
  port_range_min = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(var.ingress_with_ipv6_cidr_blocks[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(var.ingress_with_ipv6_cidr_blocks[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(var.ingress_with_ipv6_cidr_blocks[count.index], "rule", "_")][2],
  )
}

# Computed - Security group rules with "ipv6_cidr_blocks", but without "cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "computed_ingress_with_ipv6_cidr_blocks" {
  count = var.create ? var.number_of_computed_ingress_with_ipv6_cidr_blocks : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv6"

  remote_ip_prefix = lookup(
      var.computed_ingress_with_ipv6_cidr_blocks[count.index],
      "cidr_blocks",
      var.ingress_ipv6_cidr_blocks
  )
  description = lookup(
    var.computed_ingress_with_ipv6_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.computed_ingress_with_ipv6_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(
      var.computed_ingress_with_ipv6_cidr_blocks[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.computed_ingress_with_ipv6_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(
      var.computed_ingress_with_ipv6_cidr_blocks[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.computed_ingress_with_ipv6_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(
      var.computed_ingress_with_ipv6_cidr_blocks[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Security group rules with "self", but without "cidr_blocks" and "source_security_group_id"
resource "openstack_networking_secgroup_rule_v2" "ingress_with_self" {
  count = var.create ? length(var.ingress_with_self) : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = lookup(
    var.ingress_with_self[count.index],
    "ethertype",
    "IPv4",
  )

  #remove:
  #self            = lookup(var.ingress_with_self[count.index], "self", true)
  #add:
  remote_group_id = lookup(var.ingress_with_self[count.index], "self", true) ? local.this_sg_id : ""
  description = lookup(
    var.ingress_with_self[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.ingress_with_self[count.index],
    "from_port",
    var.rules[lookup(var.ingress_with_self[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.ingress_with_self[count.index],
    "to_port",
    var.rules[lookup(var.ingress_with_self[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.ingress_with_self[count.index],
    "protocol",
    var.rules[lookup(var.ingress_with_self[count.index], "rule", "_")][2],
  )
}

# Computed - Security group rules with "self", but without "cidr_blocks" and "source_security_group_id"
resource "openstack_networking_secgroup_rule_v2" "computed_ingress_with_self" {
  count = var.create ? var.number_of_computed_ingress_with_self : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = lookup(
    var.computed_ingress_with_self[count.index],
    "ethertype",
    "IPv4",
  )

  #remove:
  #self            = lookup(var.computed_ingress_with_self[count.index], "self", true)
  #add:
  remote_group_id = lookup(var.computed_ingress_with_self[count.index], "self", true) ? local.this_sg_id : ""
  description = lookup(
    var.computed_ingress_with_self[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.computed_ingress_with_self[count.index],
    "from_port",
    var.rules[lookup(var.computed_ingress_with_self[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.computed_ingress_with_self[count.index],
    "to_port",
    var.rules[lookup(var.computed_ingress_with_self[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.computed_ingress_with_self[count.index],
    "protocol",
    var.rules[lookup(var.computed_ingress_with_self[count.index], "rule", "_")][2],
  )
}

#################
# End of ingress
#################

##################################
# Egress - List of rules (simple)
##################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "openstack_networking_secgroup_rule_v2" "egress_rules" {
  count = var.create ? length(var.egress_rules) : 0

  security_group_id = local.this_sg_id
  direction         = "egress"
  ethertype         = "IPv4" 
  remote_ip_prefix       = var.egress_cidr_blocks
  description       = var.rules[var.egress_rules[count.index]][3]

  port_range_min = var.rules[var.egress_rules[count.index]][0]
  port_range_max   = var.rules[var.egress_rules[count.index]][1]
  protocol  = var.rules[var.egress_rules[count.index]][2]
}

# Computed - Security group rules with "cidr_blocks" and it uses list of rules names
resource "openstack_networking_secgroup_rule_v2" "computed_egress_rules" {
  count = var.create ? var.number_of_computed_egress_rules : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = "IPv4" 

  remote_ip_prefix      = var.egress_cidr_blocks
  description      = var.rules[var.computed_egress_rules[count.index]][3]

  port_range_min = var.rules[var.computed_egress_rules[count.index]][0]
  port_range_max   = var.rules[var.computed_egress_rules[count.index]][1]
  protocol  = var.rules[var.computed_egress_rules[count.index]][2]
}

#########################
# Egress - Maps of rules
#########################
# Security group rules with "source_security_group_id", but without "cidr_blocks" and "self"
resource "openstack_networking_secgroup_rule_v2" "egress_with_source_security_group_id" {
  count = var.create ? length(var.egress_with_source_security_group_id) : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = lookup(
    var.egress_with_source_security_group_id[count.index],
    "ethertype",
    "IPv4",
  )

  remote_group_id = var.egress_with_source_security_group_id[count.index]["source_security_group_id"]
  description = lookup(
    var.egress_with_source_security_group_id[count.index],
    "description",
    "Egress Rule",
  )

  port_range_min = lookup(
    var.egress_with_source_security_group_id[count.index],
    "from_port",
    var.rules[lookup(
      var.egress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.egress_with_source_security_group_id[count.index],
    "to_port",
    var.rules[lookup(
      var.egress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.egress_with_source_security_group_id[count.index],
    "protocol",
    var.rules[lookup(
      var.egress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Computed - Security group rules with "source_security_group_id", but without "cidr_blocks" and "self"
resource "openstack_networking_secgroup_rule_v2" "computed_egress_with_source_security_group_id" {
  count = var.create ? var.number_of_computed_egress_with_source_security_group_id : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = lookup(
    var.computed_egress_with_source_security_group_id[count.index],
    "ethertype",
    "IPv4",
  ) 

  remote_group_id = var.computed_egress_with_source_security_group_id[count.index]["source_security_group_id"]
  description = lookup(
    var.computed_egress_with_source_security_group_id[count.index],
    "description",
    "Egress Rule",
  )

  port_range_min = lookup(
    var.computed_egress_with_source_security_group_id[count.index],
    "from_port",
    var.rules[lookup(
      var.computed_egress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.computed_egress_with_source_security_group_id[count.index],
    "to_port",
    var.rules[lookup(
      var.computed_egress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.computed_egress_with_source_security_group_id[count.index],
    "protocol",
    var.rules[lookup(
      var.computed_egress_with_source_security_group_id[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "egress_with_cidr_blocks" {
  count = var.create ? length(var.egress_with_cidr_blocks) : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix = lookup(
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
  port_range_max = lookup(
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

# Computed - Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "computed_egress_with_cidr_blocks" {
  count = var.create ? var.number_of_computed_egress_with_cidr_blocks : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = "IPv4" 

  remote_ip_prefix = lookup(
      var.computed_egress_with_cidr_blocks[count.index],
      "cidr_blocks",
      var.egress_cidr_blocks
  )
  description = lookup(
    var.computed_egress_with_cidr_blocks[count.index],
    "description",
    "Egress Rule",
  )

  port_range_min = lookup(
    var.computed_egress_with_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(
      var.computed_egress_with_cidr_blocks[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.computed_egress_with_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(
      var.computed_egress_with_cidr_blocks[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.computed_egress_with_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(
      var.computed_egress_with_cidr_blocks[count.index],
      "rule",
      "_",
    )][2],
  )
}

# Security group rules with "ipv6_cidr_blocks", but without "cidr_blocks", "source_security_group_id" and "self
# Not supported in OS
# TODO:

# Computed - Security group rules with "ipv6_cidr_blocks", but without "cidr_blocks", "source_security_group_id" and "self"
# Not supported in OS
# TODO:

# Security group rules with "ipv6_cidr_blocks", but without "cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "egress_with_ipv6_cidr_blocks" {
  count = var.create ? length(var.egress_with_ipv6_cidr_blocks) : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv6"
  remote_ip_prefix = lookup(
      var.egress_with_ipv6_cidr_blocks[count.index],
      "cidr_blocks",
      var.egress_ipv6_cidr_blocks
  )
  description = lookup(
    var.egress_with_ipv6_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )
  port_range_min = lookup(
    var.egress_with_ipv6_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(var.egress_with_ipv6_cidr_blocks[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.egress_with_ipv6_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(var.egress_with_ipv6_cidr_blocks[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.egress_with_ipv6_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(var.egress_with_ipv6_cidr_blocks[count.index], "rule", "_")][2],
  )
}

# Computed - Security group rules with "ipv6_cidr_blocks", but without "cidr_blocks", "source_security_group_id" and "self"
resource "openstack_networking_secgroup_rule_v2" "computed_egress_with_ipv6_cidr_blocks" {
  count = var.create ? var.number_of_computed_egress_with_ipv6_cidr_blocks : 0

  security_group_id = local.this_sg_id
  direction              = "ingress"
  ethertype         = "IPv6"

  remote_ip_prefix = lookup(
      var.computed_egress_with_ipv6_cidr_blocks[count.index],
      "cidr_blocks",
      var.egress_ipv6_cidr_blocks
  )
  description = lookup(
    var.computed_egress_with_ipv6_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )

  port_range_min = lookup(
    var.computed_egress_with_ipv6_cidr_blocks[count.index],
    "from_port",
    var.rules[lookup(
      var.computed_egress_with_ipv6_cidr_blocks[count.index],
      "rule",
      "_",
    )][0],
  )
  port_range_max = lookup(
    var.computed_egress_with_ipv6_cidr_blocks[count.index],
    "to_port",
    var.rules[lookup(
      var.computed_egress_with_ipv6_cidr_blocks[count.index],
      "rule",
      "_",
    )][1],
  )
  protocol = lookup(
    var.computed_egress_with_ipv6_cidr_blocks[count.index],
    "protocol",
    var.rules[lookup(
      var.computed_egress_with_ipv6_cidr_blocks[count.index],
      "rule",
      "_",
    )][2],
  )
}


# Security group rules with "self", but without "cidr_blocks" and "source_security_group_id"
resource "openstack_networking_secgroup_rule_v2" "egress_with_self" {
  count = var.create ? length(var.egress_with_self) : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = lookup(
    var.egress_with_self[count.index],
    "ethertype",
    "IPv4",
  )

  #remove:
  #self            = lookup(var.egress_with_self[count.index], "self", true)
  #add:
  remote_group_id = lookup(var.egress_with_self[count.index], "self", true) ? local.this_sg_id : ""
  description = lookup(
    var.egress_with_self[count.index],
    "description",
    "Egress Rule",
  )

  port_range_min = lookup(
    var.egress_with_self[count.index],
    "from_port",
    var.rules[lookup(var.egress_with_self[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.egress_with_self[count.index],
    "to_port",
    var.rules[lookup(var.egress_with_self[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.egress_with_self[count.index],
    "protocol",
    var.rules[lookup(var.egress_with_self[count.index], "rule", "_")][2],
  )
}

# Computed - Security group rules with "self", but without "cidr_blocks" and "source_security_group_id"
resource "openstack_networking_secgroup_rule_v2" "computed_egress_with_self" {
  count = var.create ? var.number_of_computed_egress_with_self : 0

  security_group_id = local.this_sg_id
  direction              = "egress"
  ethertype         = lookup(
    var.computed_egress_with_self[count.index],
    "ethertype",
    "IPv4",
  ) 

  #remove:
  #self            = lookup(var.egress_with_self[count.index], "self", true)
  #add:
  remote_group_id = lookup(var.computed_egress_with_self[count.index], "self", true) ? local.this_sg_id : ""
  description = lookup(
    var.computed_egress_with_self[count.index],
    "description",
    "Egress Rule",
  )

  port_range_min = lookup(
    var.computed_egress_with_self[count.index],
    "from_port",
    var.rules[lookup(var.computed_egress_with_self[count.index], "rule", "_")][0],
  )
  port_range_max = lookup(
    var.computed_egress_with_self[count.index],
    "to_port",
    var.rules[lookup(var.computed_egress_with_self[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.computed_egress_with_self[count.index],
    "protocol",
    var.rules[lookup(var.computed_egress_with_self[count.index], "rule", "_")][2],
  )
}

################
# End of egress
################