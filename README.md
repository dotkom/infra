# Terraform Monorepo

This repository contains all of our Terraform infrastructure as code.

See the [documentation](docs/) for more information.

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
available in, located in the `prod` or `staging` directories.
[Please read the rationale for this decision](#separating-and-duplicating-configuration-for-each-environment).

- `prod/dashboard` & `staging/dashboard` contains code for the OnlineWeb Dashboard.
- `prod/rad-rif` & `staging/rad-rif` contains code for the report interest form application.
- `prod/web` & `staging/web` contains code for the OnlineWeb web app.
- `prod/brevduen` & `staging/brevduen` contains code for the email api gateway application.

## Contributing

To format the entire codebase, use the built-in Terraform formatter from the root of the repository:

```bash
terraform fmt -recursive
```

TFLint is automatically ran in GitHub Actions, but you can also run it locally. Note that you do not want to run TFLint
against the `ow4/` directory, as it's legacy code and is currently not maintained.
