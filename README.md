# Terraform Monorepo

This repository contains all of our Terraform infrastructure as code.

## Repository Structure

The repository is organized as a monorepo which hosts all of the Terraform modules and projects required to run
everything in OnlineWeb and featured first-party applications built by Dotkom.

- `modules/` contains all of the reusable Terraform modules.
- `ow4` contains legacy Terraform code related to the production environment of OnlineWeb4
- `bootstrap` contains a bootstrap project for setting up the initial infrastructure for a new project. Please see the
  [README](bootstrap/README.md) for why the bootstrap exists, and why you should not touch it.
- `online-infra` contains core infrastructure for OnlineWeb, which is independent of the application code. This includes
  things like DNS, VPC, and other shared resources.

Each project is organized as a separate directory in the root of the repository, with each environment a project is
available in, having the `-prod` or `-staging` suffix.
[Please read the rationale for this decision](#separating-and-duplicating-configuration-for-each-environment).

- `dashboard-prod` & `dashboard-staging` contains code for the OnlineWeb Dashboard.
- `rad-rif-prod` & `rad-rif-staging` contains code for the report interest form application.
- `web-prod` & `web-staging` contains code for the OnlineWeb web app.

## Contributing

To format the entire codebase, use the built-in Terraform formatter from the root of the repository:

```bash
terraform fmt -recursive
```

TFLint is automatically ran in GitHub Actions, but you can also run it locally. Note that you do not want to run TFLint
against the `ow4/` directory, as it's legacy code and is currently not maintained.

## Architectural Decisions

### Separating and duplicating configuration for each environment

There are a few Terraform-native ways to handle multiple environments (staging, prod, etc). The most common way is to
use Terraform workspaces, but these prove annoying, misleading or problematic in a few ways:

- Workspaces are not that obvious to use, and it's easy to forget to switch between them. You don't want to accidentally
  apply changes to the wrong environment.
- Not all resources want to be deployed to all environments. For example, we don't want a `vercel_project` resource for
  an application to be deployed to both staging and prod. This makes the build queue twice as long, and it's just
  unnecessary.
    - One workaround is to use `count` or `for_each` to conditionally deploy resources, but this is not ideal, and is
      not really the intended use of these features. This also requires all conditional resources to be accessed using
      the lookup operator, which is both misleading and annoying.
- It simplifies code significantly. Gone are the days of having ternary operators all over the place to conditionally
  choose domain name, or instance count.
