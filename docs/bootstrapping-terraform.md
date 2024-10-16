# Bootstrapping Terraform

_Also consider reading [bootstrap/README.md](/bootstrap/README.md)._

This document's purpose is to explain how to bootstrap Terraform for a new
organization, or a new AWS account. Because our goal is to explicitly manage
everything in Terraform, we somehow need to create the S3 bucket that is used
for storing the state files of all of our other projects.

The bootstrap project is a simple Terraform project that uses the local backend
with a state file that is commited to Git. That is the sole purpose of this
Terraform project, and everything else should therefore use the remote S3 backend
using this bucket as the state file bucket.
