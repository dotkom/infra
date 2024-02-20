# Terraform monorepo
This contains dotkoms terraform IaC. Every folder contains an independent Terraform projects, except for *modules* which contains local terraform modules. Applying locally should rarely be done, and only if you know what you're doing. Terraform apply should instead be done through atlantis in a pull request so that we have more control of what plans are applied and things can be checked by multiple people. 

## How to change infrastructure

Change the relevant code and run ```terraform plan```. Go through the plan and make sure it's correct.
When creating a pull request to main, Atlantis will receive a webhook and trigger a build for the terraform projects corresponding to the changed code. This can be further managed and configured in ```atlantis.yaml```. See Ataltis' documentation for how to use. The most important commads are ```atlantis plan``` and ```atlantis apply```. These commands are issued as Github comments on pull requests.