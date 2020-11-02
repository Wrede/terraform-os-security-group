# Openstack Security Group Terraform module
Terraform module for creating security groups using Openstack (private cloud) provider.
This module is an Openstack translation of [AWS EC2-VPC Security Group Terraform module](https://github.com/terraform-aws-modules/terraform-aws-security-group). Many thanks goes to the contributors of the aws module! 

TODO:
- add var.create for conditional sec groups
- enable multi CIDR (cidr_blocks)
- enable mix of ethertype (IPv4 and IPv6)
- update github links in update_groups.sh and in README.md

These types of resources are supported:

* [Openstack Security Group v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2)
* [Openstack Security Group Rule v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2)

## Current features supported in comparison with AWS module

* :heavy_check_mark: IPv4 CIDR blocks. Currently only support a single cidr per rule.
* :white_check_mark: IPv6 CIDR blocks. Currently not supported, associated resources and variables in main.tf and variables.tf has been removed. This might cause failure in some modules. 

Note: [Openstack Security Group Rule v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) uses the argument ```ethertype``` to specify either IPv4 or IPv6 per rule, i.e there is no specific argument for IPv6 CIDR blocks. ```ethertype``` should be added in the rules mapping, it is currently a global variable. 

Note: [Openstack Security Group Rule v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) uses argument ```remote_ip_prefix``` for single CIDR blocks (string and not list of strings as in AWS). To my knowledge if multiple CIDR blocks are desired, copies of resource rules per CIDR has to be computed. This is currently not implemented.    

* :heavy_check_mark: Access from source security groups
* :heavy_check_mark: Access from self

Note: [Openstack Security Group Rule v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) does not have a similar argument ```self``` as in [EC2-VPC Security Group Rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html). To my knowledge, self reference is instead possible directly via ```remote_group_id```. The "self" key in associated variables in this module (postfix ```_with_self```) has been kept but instead act in a condition to decide if ```remote_group_id``` should be set to ```local.this_sg_id```. 

* :heavy_check_mark: Named rules ([see the rules here](https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf))
* :heavy_check_mark: Named groups of rules with ingress (inbound) and egress (outbound) ports open for common scenarios (eg, [ssh](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules/ssh), [http-80](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules/http-80), [mysql](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules/mysql), see the whole list [here](https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/modules/README.md))
* :white_check_mark: Conditionally create security group and all required security group rules ("single boolean switch").

Note: will be added soon

Ingress and egress rules can be configured in a variety of ways. See [inputs section](#inputs) for all supported arguments and [complete example](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/complete) for the complete use-case.


## Terraform versions

Use Terraform 0.13

## Usage

OBS! This module has not been added to the Terraform registry yet. Thus, git clone this module to make use of it until it has been added. ```source``` will then be the absolute path to the module.

Some differences of this Openstack translation module and [AWS EC2-VPC Security Group Terraform module](https://github.com/terraform-aws-modules/terraform-aws-security-group) are demonstrated below.

There are two ways to create security groups using this module:

1. [Specifying predefined rules (HTTP, SSH, etc)](https://github.com/terraform-aws-modules/terraform-aws-security-group#security-group-with-predefined-rules)
1. [Specifying custom rules](https://github.com/terraform-aws-modules/terraform-aws-security-group#security-group-with-custom-rules)

### Security group with predefined rules

```hcl
module "web_server_sg" {
  source = "/path/to/this/repo//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  #vpc_id      = "vpc-12345678" #AWS EC2-VPC Security Group
                                #Plans to add Openstack Subnet or 
                                #Network resource id instead

  #ingress_cidr_blocks = ["10.10.0.0/16"] #AWS EC2-VPC Security Group
  ingress_cidr_blocks = "10.10.0.0/16"
}
```

### Security group with custom rules

```hcl
module "vote_service_sg" {
  source = "/path/to/this/repo"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  #vpc_id      = "vpc-12345678" #AWS EC2-VPC Security Group

  #ingress_cidr_blocks      = ["10.10.0.0/16"] #AWS EC2-VPC Security Group
  ingress_cidr_blocks      = "10.10.0.0/16"
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
```

## Conditional creation

Note: will be added soon

Sometimes you need to have a way to create security group conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create`.

```hcl
# This security group will not be created
module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  create = false
  # ... omitted
}
```

## Examples

* [HTTP Security Group example](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/http) shows more applicable security groups for common web-servers.

TODO: 

* [Complete Security Group example](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/complete) shows all available parameters to configure security group.
* [Disable creation of Security Group example](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/disabled) shows how to disable creation of security group.
* [Dynamic values inside Security Group rules example](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/dynamic) shows how to specify values inside security group rules (data-sources and variables are allowed).
* [Computed values inside Security Group rules example](https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/computed) shows how to specify computed values inside security group rules (solution for `value of 'count' cannot be computed` problem).

## How to add/update rules/groups?

Rules and groups are defined in [rules.tf](https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf). Run `update_groups.sh` when content of that file has changed to recreate content of all automatic modules.


## Authors

[AWS EC2-VPC Security Group Terraform module](https://github.com/terraform-aws-modules/terraform-aws-security-group) is managed by [Anton Babenko](https://github.com/antonbabenko).

This Openstack translation was made by [Fredrik Wrede](https://github.com/Wrede)

## License

Working on it! 