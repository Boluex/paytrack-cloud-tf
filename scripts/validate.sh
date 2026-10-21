#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
validation_dir=$(mktemp -d)
trap 'rm -rf "$validation_dir"' EXIT
terraform fmt -check -recursive
export TF_DATA_DIR="$validation_dir/environments_dev"
terraform -chdir=environments/dev init -backend=false -input=false
terraform -chdir=environments/dev validate
export TF_DATA_DIR="$validation_dir/environments_staging"
terraform -chdir=environments/staging init -backend=false -input=false
terraform -chdir=environments/staging validate
export TF_DATA_DIR="$validation_dir/environments_prod"
terraform -chdir=environments/prod init -backend=false -input=false
terraform -chdir=environments/prod validate
export TF_DATA_DIR="$validation_dir/global_bootstrap"
terraform -chdir=global/bootstrap init -backend=false -input=false
terraform -chdir=global/bootstrap validate
export TF_DATA_DIR="$validation_dir/global_github-oidc"
terraform -chdir=global/github-oidc init -backend=false -input=false
terraform -chdir=global/github-oidc validate
