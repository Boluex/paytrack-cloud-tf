# paytrack-cloud-tf infrastructure

Terraform roots: `environments/dev`, `environments/staging`, `environments/prod`, `global/bootstrap`, `global/github-oidc`.

Run `make fmt` and `make validate`. Validation initializes providers with the remote backend disabled and does not deploy resources.

Local emulation roots expose `use_local_emulator`, `ec2_endpoint` and `aws_endpoint`. The existing Ministack defaults are EC2 on port 5003 and other APIs on port 4566. Emulator coverage varies; a successful validate does not prove ECS or load-balancer execution. For AWS, set `use_local_emulator=false` where available and use the normal AWS credential chain.

Keep real tfvars and state out of Git. Configure and initialize a remote backend before shared AWS use. Review a saved plan before applying. Existing resource addresses are preserved; inspect replacement actions before changing networks or databases.

Cloud plans need your image references, region, network settings and any required secrets. Existing environment tfvars on this workstation are not published. Application repositories and Kubernetes manifests are separate from this infrastructure.
