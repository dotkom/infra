# Infra & Evergreen

This repository contains all of our Terraform infrastructure as code. Evergreen is our internal application platform built on AWS ECS, ECR, EC2 and S3.

See the [documentation](docs/) for more information.

## Repository Structure

The repository is organized as a monorepo which hosts all of the Terraform modules and projects required to run
everything in OnlineWeb and featured first-party applications built by Dotkom.

- `modules/` contains all of the reusable Terraform modules.
- `bootstrap` contains a bootstrap project for setting up the initial infrastructure for a new project. Please see the
  [README](bootstrap/README.md) for why the bootstrap exists, and why you should not touch it.
- `online-infra` contains core infrastructure for OnlineWeb, which is independent of the application code. This includes
  things like DNS, global KMS keys, and other shared resources.

Each project is organized as a separate directory in the root of the repository, with each environment a project is
available in, located in the `prod` or `staging` directories.

## Contributing

To format the entire codebase, use the built-in Terraform formatter from the root of the repository:

```bash
terraform fmt -recursive
tflint --recursive
```

TFLint is automatically ran in GitHub Actions, but you can also run it locally.
