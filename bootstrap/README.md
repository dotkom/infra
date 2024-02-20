# Terraform Monorepo Bootstrap

This terraform project contains the bootstrap S3 bucket for the monorepo. It's used to provision the root S3 bucket that
will be used as a remote backend for all other terraform projects in the monorepo.

You are most likely not supposed to touch this subdirectory again, unless you are deleting all of OnlineWeb.

## What is this?

This is a single terraform project that uses the local backend with a state file that is commited to Git. The reason the
state file is commited, is because otherwise we would have a chicken-and-egg problem.

Yes, you could change the backend to use a remote state file after the initial creation with local, but that just makes
it more complicated if you ever plan to delete the monorepo.
