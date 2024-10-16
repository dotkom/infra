# Basic Cloud Networking

This document outlines the basics of cloud networking, so that you can learn
and understand how to configure your own networking. This guide focuses on AWS,
but the principles are more or less applicable to other cloud providers.

This guide assumes you have some basic knowledge of how networks work, e.g.,
how IP addresses work, CIDR, network routing, etc.
[NTNU's TTM4100][ttm4100] is a good starting point for learning about networking
as it's also required for the bachelor's degree in informatics at NTNU.

## Table of Contents

- [Virtual Private Clouds](#virtual-private-clouds)
- [VPC Blocks](#vpc-blocks)
- [Subnets](#subnets)
- [Security Groups](#security-groups)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Virtual Private Clouds

In AWS, a Virtual Private Cloud (VPC) is a logically isolated area of the cloud
where you can deploy your resources. You can think of it as a private network
where only the servers (or other resources) that are deployed within the VPC can
communicate with each other. This is in contrast to the public internet, where
anybody can communicate with a server, given they know the IP (v4 or v6) address
of the target server.

You can compare a VPC to your home network, where you can have multiple devices
(computers, phones, etc.) connected to the same network. These devices are able
to communicate with each other, but the outside world cannot, because they are
in a private network (read: there is no public IP address to your home laptop).

Internet traffic is routed from one source IP to one destination IP. Since our
servers are in a private network, there is also no public IP address, which
means that there should also be no way for the servers in the VPC to reach the
public internet. This actually also applies to your home network, but your
internet service provider has a public IP address that your traffic is proxied
through. This is called a NAT (Network Address Translation) gateway.

### Network Address Translation

Network address translation is the process of translating the source IP address
of a packet to a destination IP address. When your computer sends a request to
browse Wikipedia, the source IP address is the private IP address of your
computer. Naturally, this is a private IP address and it has no public IP
address associated with it, so you are unable to reach the public internet.

The NAT gateway has a public IP attached to it (in AWS lingo, this is an Elastic
IP address, or EIP). Because the NAT gateway is connected to the public
internet, we can use it to route traffic from the other servers in the VPC to
the public internet.

A natural consequence of this, is that any requests that are sent to the public
internet, will be received as coming from the NAT gateway. This can be less
fortunate if you have many services querying some external API $x$, then the
server for $x$ will believe that all requests are coming from the NAT gateway.
Perhaps $x$ applies an IP-based rate limiting, meaning all your services get
punished for making too many requests because they all appear to come from the
same IP address.

## VPC Blocks

The VPC is registered with a CIDR block, which is a range of IP addresses that
services within the VPC can receive. A classic default value for this CIDR block
is for example `10.0.0.0/16`, which means that the VPC can assign services IPs
from the range of IP addresses `10.0.0.0` to `10.255.255.255`. (65536 addresses)

This is important to understand in the context of subnets.

## Subnets

A subnet is a logically isolated area within the VPC. It is a subset of the CIDR
block that is assigned to the VPC. A standard paradigm is to have a set of
private and public subnets.

A private subnet is a subnet that is only accessible from within the VPC, in
other words, there is no public IP address assigned to any host within the
subnet. As previously mentioned, the hosts inside of the private subnet can
reach the public internet through a NAT gateway, but the NAT gateway itself
is not deployed within the private subnet, but instead in a public subnet.

A public subnet is a subnet that is accessible from the public internet. This
means that there is a public IP address assigned to any host within the subnet.
In AWS, this is done with an Internet Gateway (IGW), where all the traffic is
routed to the Internet Gateway through a Route Table.

Additionally, it's very common practice to deploy one public and one private
subnet per availability zone in the region the VPC is deployed in. This is
to allow for redundancy and enable high availability. If one of the availability
zones were to fail, the services can be redeployed into the other availability
zone.

> In practice, this means that we should have one NAT gateway per availability
> zone, and one IGW per availability zone. We in dotkom don't do this at the
> moment to reduce costs, but it's generally the best practice to do so.

## Security Groups

Security groups are one of three ways you can control access to services within
your VPC. (The other two are Network ACLs, or host firewalls). A security group
consists of a set of rules that define what ingress and egress traffic is
allowed to pass through the security group.

Security groups are attached to resources, such as EC2 instances, or load
balancers, and determine what traffic is allowed to reach an instance. This
means that even though an EC2 instance is deployed in a public subnet, we can
still restrict access to it by attaching a security group to the instance
forbids all traffic from the public internet.

Security groups can also be attached to a load balancer, which means that the
will for example only allow traffic from the public internet, or only from
within the VPC itself.

## Summary

- VPCs are logically isolated areas of the cloud, where you can deploy your
  resources.
- VPCs are registered with a CIDR block, which is a range of IP addresses that
  services within the VPC can receive.
- Within a VPC, you can create subnets, that are logically isolated areas within
  your VPC.
- Private subnets are intended to only be reachable from within the VPC, and
  public subnets are intended to be reachable from the public internet.
- Security groups are used to control access to resources within a VPC.

## Further Reading

- [What is Amazon VPC?][vpc-docs]
- [Terraform documentation for VPC resources][vpc-terraform]

[ttm4100]: https://www.ntnu.no/studier/emner/TTM4100
[vpc-docs]: [https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html]
[vpc-terraform]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
