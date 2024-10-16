# Code Organization

This document outlines choices that we made when structuring the monorepo, and
explains why we made them, their alternatives, and why we believe the choices
were the best fit for our needs.

## Separating and duplicating configuration for each environment

There is generally speaking two methods of managing multiple environments for
a service. By service we mean an application or workload that is deployed to
multiple environments, managed by Terraform.

- Terraform workspaces: Terraform workspaces are a way to manage multiple
  "instantiations" of the same Terraform codebase. Each workspace is
  essentially a copy of the Terraform state, and we can use a magical
  `terraform.workspace` variable to perform conditional operations based on
  which workspace we are in. This can for example be used to deploy a t3.small
  instance to staging, and a c6g.large to production. See the [Terraform
  documentation][workspaces] for more information on workspaces.
- Multiple Terraform projects with code duplication: We write the Terraform and
  duplicate the code for each environment, creating a new Terraform project for
  each environment. This is the approach we took, and below I explain why so.

We are often taught that we should avoid duplicating code, so it might seem
unintuitive to write the same Terraform code multiple times. However, this
is not necessarily a bad idea when working with Terraform.

Terraform workspaces requires us to do ternary conditions, `for_each`, or
`count` operations, which can be quite verbose. When we managed three
environments, we often resort to declaring local variable maps, and pick one
based on the current workspace. This leads to quite verbose code, it harms
readability, but at the same time it's quite easy to understand.

A larger problem arises when we have resources that should be conditionally
deployed. For example, we might not want to deploy a service, or create
CloudWatch metrics for a staging environment. (Think resources that are quite
costly that we can't justify provisioning in all environments). In this case,
we're forced to use `count` or `for_each` to conditionally deploy resources.

This on its own is okay, but it's not ideal as conditionally provisioning a
resource affects its Terraform address, and that cascades all the way down to
each resource that depends on it. The following terraform code example shows
why this becomes harder to manage.

```terraform
resource "aws_s3_bucket" "example" {
  count = terraform.workspace == "production" ? 1 : 0
  
  bucket = "example-${terraform.workspace}"
}

module "some_dependency" {
  source = "./some-dependency"
  
  bucket = terraform.workspace == "production" ? aws_s3_bucket.example[0].bucket : null
}
```

Suddenly, the conditional address of the `aws_s3_bucket` resource is cascaded
onto each consumer, greatly affecting the readability of the code. Therefore
it is more preferable to duplicate code, and instead make heavy use of
Terraform modules to reduce the number of stray resources in each project.

### Conclusion

Because conditional resources might significantly affect the readability of
the code, we decided to duplicate the code for each environment.

In the future it might be worth looking into [Terragrunt][terragrunt], which
is a lightweight wrapper around Terraform that aims to keep Terraform code
DRY.

[workspaces]: https://developer.hashicorp.com/terraform/language/state/workspaces
[terragrunt]: https://terragrunt.gruntwork.io/
