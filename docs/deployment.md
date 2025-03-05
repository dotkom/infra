# Deployment of ECS services

Docker images can be automatically deployed to AWS ECS using a set of GitHub Actions. Because our infrastructure lives inside a private repository, we have to do cross-repository Action dispatches. This workflow and the necessary code is explained in this document.

## Prerequisites

- An application that can be built into a Docker image
- An existing ECR repository for the image
- An existing AWS ECS service (through Evergreen) that the service runs on.

The goal now is to automaitcally re-deploy the ECS service when we push to the main branch on GitHub. The steps are as follows:

1. Code push to `main` triggers a GitHub Action that:
    1. Builds the Docker image
    1. Pushes it to AWS ECR
    1. Triggers the Apply GitHub Action in the `dotkom/terraform-monorepo` repository using GitHub's workflow_dispatch with `environment`, `project`, and `targets` inputs.
1. Apply workflow is triggered from code repository which:
    1. Initializes the terraform project in question
    1. Runs apply with auto-approve with the targeted resources.

## Cross-repository Actions

In order to trigger a GitHub Action cross-repository, the target workflow must support `workflow_dispatch`, and the calling repository must have a Personal Access Token that is permitted to trigger workflows on the target repository (terraform-monorepo).

<details>
  <summary>Creating the Personal Access Token</summary>
  The token needs to have a couple permissions. Start off by creating a Fine-Grained GH Personal Access Token.

  1. Set the owner to `dotkom`
  1. Select the following scopes
      - Actions: read/write
      - Commit statuses: read/write
      - Contents: read/write
      - Issues: read
      - Pull Requests: read
      - Metadata: read
</details>

This token is stored in the Terraform Doppler project and is named `TERRAFORM_GITHUB_TOKEN`. This token can be added as a GitHub secret on the calling repository.

## Example

The following is an example on how the deploy workflow should look for the calling repository.

```yaml
name: Staging deployment
on:
  push:
    branches:
      - main

permissions:
  id-token: write   
  contents: read
jobs:
  deploy-rpc:
    name: Deploy monoweb/rpc
    runs-on: ubuntu-24.04
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: eu-north-1
          role-to-assume: arn:aws:iam::891459268445:role/MonowebStagingRPCCIRole
      - uses: aws-actions/amazon-ecr-login@v2
      - uses: actions/checkout@v4
        with:
          fetch-depth: 1
      - uses: docker/build-push-action@v6
        with:
          platforms: linux/amd64
          content: .
          file: apps/rpc/Dockerfile
          tags: 891459268445.dkr.ecr.eu-north-1.amazonaws.com/monoweb/staging/rpc:latest
          push: true
      - uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.TERRAFORM_WORKFLOW_TOKEN }}
          script: |
            await github.rest.actions.createWorkflowDispatch({
              owner: 'dotkom',
              repo: 'terraform-monorepo',
              workflow_id: 'apply.yml',
              ref: 'main',
              inputs: {
                environment: 'staging',
                project: 'monoweb-rpc',
                targets: 'module.rpc_evergreen_service',
              },
            });
```

As seen, the `actions/github-script` step triggers a workflow dispatch with the necessary resources. This will translate to the following command invocation in the Terraform monorepo:

```bash
pushd staging/monoweb-rpc
  terraform init
  terraform apply -auto-approve -target=module.rpc_evergreen_service
popd
```

If you need multiple targets, you can comma-separate them when calling createWorkflowDispatch (e.g: `module.foo,module.bar`)

