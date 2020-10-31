output "this_security_group_id" {
  description = "The ID of the security group"
  value = openstack_networking_secgroup_v2.this.*.id
}

output "this_security_group_tenant_id" {
  description = "The owner ID"
  value = openstack_networking_secgroup_v2.this.*.tenant_id
}

output "this_security_group_name" {
  description = "The name of the security group"
  value = openstack_networking_secgroup_v2.this.*.name
}

output "this_security_group_description" {
  description = "The description of the security group"
  value = openstack_networking_secgroup_v2.this.*.description
}