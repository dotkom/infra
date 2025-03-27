#!/usr/bin/env bash

set -euo pipefail

aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 891459268445.dkr.ecr.eu-north-1.amazonaws.com
docker build -t 891459268445.dkr.ecr.eu-north-1.amazonaws.com/monoweb/prod/gatus:latest --platform linux/amd64 -f Dockerfile .
docker push 891459268445.dkr.ecr.eu-north-1.amazonaws.com/monoweb/prod/gatus:latest
